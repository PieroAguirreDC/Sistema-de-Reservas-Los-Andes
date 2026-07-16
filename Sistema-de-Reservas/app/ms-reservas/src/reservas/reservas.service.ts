import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { Repository } from 'typeorm';
import { Reserva } from './entities/reserva.entity.js';
import { CreateReservaDto } from './dto/create-reserva.dto.js';
import { SnsService } from '@reservas/common';

@Injectable()
export class ReservasService {
  private readonly logger = new Logger(ReservasService.name);
  private readonly topicArn: string;
  private readonly habitacionesUrl: string;

  constructor(
    @InjectRepository(Reserva)
    private readonly reservaRepo: Repository<Reserva>,
    private readonly snsService: SnsService,
    private readonly configService: ConfigService,
  ) {
    this.topicArn = this.configService.get<string>('SNS_TOPIC_RESERVAS_ARN', '');
    this.habitacionesUrl = this.configService.get<string>(
      'MS_HABITACIONES_URL',
      'http://localhost:3002/api/v1/habitaciones',
    );
  }

  findAll(usuario_id?: string) {
    if (usuario_id) {
      return this.reservaRepo.find({ where: { usuario_id } });
    }
    return this.reservaRepo.find();
  }

  async findOne(id: string): Promise<Reserva> {
    const reserva = await this.reservaRepo.findOne({ where: { id } });
    if (!reserva) throw new NotFoundException(`Reserva ${id} no encontrada`);
    return reserva;
  }

  async create(dto: CreateReservaDto): Promise<Reserva> {
    // Check availability synchronously via HTTP
    try {
      const response = await fetch(`${this.habitacionesUrl}/${dto.habitacion_id}`);
      if (!response.ok) {
        if (response.status === 404) throw new NotFoundException('Habitación no encontrada');
        throw new BadRequestException('Error verificando habitación');
      }
      const habitacion = await response.json();
      if (!habitacion.disponible) {
        throw new BadRequestException('La habitación no está disponible');
      }
    } catch (error) {
      if (error instanceof NotFoundException || error instanceof BadRequestException) {
        throw error;
      }
      this.logger.error(`Error de red verificando habitación: ${error}`);
      throw new BadRequestException('No se pudo verificar la disponibilidad de la habitación');
    }

    const reserva = this.reservaRepo.create({ ...dto, estado: 'pendiente' });
    const saved = await this.reservaRepo.save(reserva);

    // Publish event
    if (this.topicArn) {
      await this.snsService.publish(this.topicArn, {
        tipo: 'RESERVA_CREADA',
        reserva_id: saved.id,
        habitacion_id: saved.habitacion_id,
        usuario_id: saved.usuario_id,
        estado: saved.estado,
      });
    }

    return saved;
  }

  async update(id: string, data: Partial<Reserva>): Promise<Reserva> {
    const reserva = await this.findOne(id);
    const estadoAnterior = reserva.estado;
    Object.assign(reserva, data);
    const saved = await this.reservaRepo.save(reserva);

    if (this.topicArn) {
      if (data.estado === 'confirmada' && estadoAnterior !== 'confirmada') {
        await this.snsService.publish(this.topicArn, {
          tipo: 'RESERVA_CONFIRMADA',
          reserva_id: saved.id,
          habitacion_id: saved.habitacion_id,
        });
      } else if (data.estado === 'cancelada' && estadoAnterior !== 'cancelada') {
        await this.snsService.publish(this.topicArn, {
          tipo: 'RESERVA_CANCELADA',
          reserva_id: saved.id,
          habitacion_id: saved.habitacion_id,
        });
      }
    }

    return saved;
  }

  async remove(id: string): Promise<{ message: string }> {
    const reserva = await this.findOne(id);
    await this.reservaRepo.remove(reserva);

    if (this.topicArn && reserva.estado !== 'cancelada') {
      await this.snsService.publish(this.topicArn, {
        tipo: 'RESERVA_CANCELADA',
        reserva_id: id,
        habitacion_id: reserva.habitacion_id,
      });
    }

    return { message: `Reserva ${id} eliminada` };
  }
}