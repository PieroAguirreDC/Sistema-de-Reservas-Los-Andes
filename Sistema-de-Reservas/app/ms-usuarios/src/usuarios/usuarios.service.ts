import {
  Injectable,
  NotFoundException,
  ConflictException,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import {
  CognitoIdentityProviderClient,
  AdminCreateUserCommand,
  AdminSetUserPasswordCommand,
  InitiateAuthCommand,
  AuthFlowType,
} from '@aws-sdk/client-cognito-identity-provider';
import { Usuario } from './entities/usuario.entity.js';
import { CreateUsuarioDto } from './dto/create-usuario.dto.js';
import { LoginDto } from './dto/login.dto.js';

const SALT_ROUNDS = 10;

@Injectable()
export class UsuariosService {
  private readonly cognitoClient: CognitoIdentityProviderClient;
  private readonly userPoolId: string;
  private readonly clientId: string;
  private readonly logger = new Logger(UsuariosService.name);

  constructor(
    @InjectRepository(Usuario)
    private readonly repo: Repository<Usuario>,
    private readonly configService: ConfigService,
  ) {
    this.cognitoClient = new CognitoIdentityProviderClient({
      region: configService.get<string>('COGNITO_REGION', 'us-east-2'),
    });
    this.userPoolId = configService.get<string>('COGNITO_USER_POOL_ID', '');
    this.clientId = configService.get<string>('COGNITO_CLIENT_ID', '');
  }

  findAll(): Promise<Omit<Usuario, 'password'>[]> {
    return this.repo.find({
      select: { id: true, nombre: true, email: true, rol: true, created_at: true },
    });
  }

  async findOne(id: string): Promise<Omit<Usuario, 'password'>> {
    const user = await this.repo.findOne({
      where: { id },
      select: { id: true, nombre: true, email: true, rol: true, created_at: true },
    });
    if (!user) throw new NotFoundException(`Usuario ${id} no encontrado`);
    return user;
  }

  async register(dto: CreateUsuarioDto): Promise<Omit<Usuario, 'password'>> {
    const existe = await this.repo.findOne({ where: { email: dto.email } });
    if (existe) throw new ConflictException('El email ya está registrado');

    // Guardar en BD local
    const usuario = this.repo.create({
      ...dto,
      rol: dto.rol || 'cliente',
      password: await bcrypt.hash(dto.password, SALT_ROUNDS),
    });
    const saved = await this.repo.save(usuario);

    // Registrar en Cognito
    if (this.userPoolId) {
      try {
        await this.cognitoClient.send(
          new AdminCreateUserCommand({
            UserPoolId: this.userPoolId,
            Username: dto.email,
            UserAttributes: [
              { Name: 'email', Value: dto.email },
              { Name: 'email_verified', Value: 'true' },
              { Name: 'given_name', Value: dto.nombre },
              { Name: 'custom:rol', Value: dto.rol || 'cliente' },
            ],
            MessageAction: 'SUPPRESS',
          }),
        );
        await this.cognitoClient.send(
          new AdminSetUserPasswordCommand({
            UserPoolId: this.userPoolId,
            Username: dto.email,
            Password: dto.password,
            Permanent: true,
          }),
        );
        this.logger.log(`Usuario registrado en Cognito: ${dto.email}`);
      } catch (err) {
        this.logger.error(`Error registrando en Cognito: ${err}`);
        // No se revierte la BD — Cognito es secondary
      }
    }

    const { password: _pw, ...rest } = saved;
    return rest;
  }

  async login(dto: LoginDto) {
    // Verificar contra BD local
    const usuario = await this.repo.findOne({ where: { email: dto.email } });
    if (!usuario || !(await bcrypt.compare(dto.password, usuario.password))) {
      throw new UnauthorizedException('Credenciales incorrectas');
    }

    // Obtener JWT de Cognito
    let tokens = { accessToken: '', idToken: '', refreshToken: '' };
    if (this.userPoolId && this.clientId) {
      try {
        const authResult = await this.cognitoClient.send(
          new InitiateAuthCommand({
            AuthFlow: AuthFlowType.USER_PASSWORD_AUTH,
            ClientId: this.clientId,
            AuthParameters: {
              USERNAME: dto.email,
              PASSWORD: dto.password,
            },
          }),
        );
        tokens = {
          accessToken: authResult.AuthenticationResult?.AccessToken || '',
          idToken: authResult.AuthenticationResult?.IdToken || '',
          refreshToken: authResult.AuthenticationResult?.RefreshToken || '',
        };
      } catch (err) {
        this.logger.error(`Error autenticando en Cognito: ${err}`);
      }
    }

    const { password: _pw, ...userWithoutPw } = usuario;
    return { ...tokens, usuario: userWithoutPw };
  }

  async update(id: string, data: Partial<CreateUsuarioDto>): Promise<Omit<Usuario, 'password'>> {
    const usuario = await this.repo.findOne({ where: { id } });
    if (!usuario) throw new NotFoundException(`Usuario ${id} no encontrado`);
    if (data.password) data.password = await bcrypt.hash(data.password, SALT_ROUNDS);
    Object.assign(usuario, data);
    const saved = await this.repo.save(usuario);
    const { password: _pw, ...rest } = saved;
    return rest;
  }

  async remove(id: string): Promise<{ message: string }> {
    const usuario = await this.repo.findOne({ where: { id } });
    if (!usuario) throw new NotFoundException(`Usuario ${id} no encontrado`);
    await this.repo.remove(usuario);
    return { message: `Usuario ${id} eliminado` };
  }
}
