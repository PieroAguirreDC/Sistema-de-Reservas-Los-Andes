import {
  Injectable,
  NotFoundException,
  ConflictException,
  UnauthorizedException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { createHash } from 'crypto';
import { Usuario } from './entities/usuario.entity';
import { CreateUsuarioDto } from './dto/create-usuario.dto';
import { LoginDto } from './dto/login.dto';

function hashPassword(plain: string): string {
  return createHash('sha256').update(plain).digest('hex');
}

@Injectable()
export class UsuariosService {
  constructor(
    @InjectRepository(Usuario)
    private readonly repo: Repository<Usuario>,
  ) {}

  findAll(): Promise<Omit<Usuario, 'password'>[]> {
  return this.repo.find({
    select: {
      id: true,
      nombre: true,
      email: true,
      rol: true,
      created_at: true,
    },
  });
}

  async findOne(id: string): Promise<Omit<Usuario, 'password'>> {
  const user = await this.repo.findOne({
    where: { id },
    select: {
      id: true,
      nombre: true,
      email: true,
      rol: true,
      created_at: true,
    },
  });
  if (!user) throw new NotFoundException(`Usuario ${id} no encontrado`);
  return user;
}

  async register(dto: CreateUsuarioDto): Promise<Omit<Usuario, 'password'>> {
    const existe = await this.repo.findOne({ where: { email: dto.email } });
    if (existe) throw new ConflictException('El email ya está registrado');
    const usuario = this.repo.create({
      ...dto,
      rol: dto.rol || 'cliente',
      password: hashPassword(dto.password),
    });
    const saved = await this.repo.save(usuario);
    const { password: _pw, ...rest } = saved;
    return rest;
  }

  async login(dto: LoginDto): Promise<Omit<Usuario, 'password'>> {
    const usuario = await this.repo.findOne({ where: { email: dto.email } });
    if (!usuario || usuario.password !== hashPassword(dto.password)) {
      throw new UnauthorizedException('Credenciales incorrectas');
    }
    const { password: _pw, ...rest } = usuario;
    return rest;
  }

  async update(id: string, data: Partial<CreateUsuarioDto>): Promise<Omit<Usuario, 'password'>> {
    const usuario = await this.repo.findOne({ where: { id } });
    if (!usuario) throw new NotFoundException(`Usuario ${id} no encontrado`);
    if (data.password) data.password = hashPassword(data.password);
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