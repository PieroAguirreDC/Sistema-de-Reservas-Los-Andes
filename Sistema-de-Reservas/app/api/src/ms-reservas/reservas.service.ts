import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Reserva } from './entities/reserva.entity';
import { Habitacion } from '../ms-habitaciones/entities/habitacion.entity';
import { CreateReservaDto } from './dto/create-reserva.dto';

@Injectable()
export class ReservasService {
  constructor(
    @InjectRepository(Reserva)
    private readonly reservaRepo: Repository<Reserva>,
    @InjectRepository(Habitacion)
    private readonly habitacionRepo: Repository<Habitacion>,
  ) {}

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
    const habitacion = await this.habitacionRepo.findOne({
      where: { id: dto.habitacion_id },
    });
    if (!habitacion) {
      throw new NotFoundException(`Habitación ${dto.habitacion_id} no encontrada`);
    }
    if (!habitacion.disponible) {
      throw new BadRequestException('La habitación no está disponible');
    }
    const reserva = this.reservaRepo.create({ ...dto, estado: 'pendiente' });
    const saved = await this.reservaRepo.save(reserva);
    habitacion.disponible = false;
    await this.habitacionRepo.save(habitacion);
    return saved;
  }

  async update(id: string, data: Partial<Reserva>): Promise<Reserva> {
    const reserva = await this.findOne(id);
    const estadoAnterior = reserva.estado;
    Object.assign(reserva, data);
    const saved = await this.reservaRepo.save(reserva);
    if (data.estado === 'cancelada' && estadoAnterior !== 'cancelada') {
      const habitacion = await this.habitacionRepo.findOne({
        where: { id: reserva.habitacion_id },
      });
      if (habitacion) {
        habitacion.disponible = true;
        await this.habitacionRepo.save(habitacion);
      }
    }
    return saved;
  }

  async remove(id: string): Promise<{ message: string }> {
    const reserva = await this.findOne(id);
    const habitacion = await this.habitacionRepo.findOne({
      where: { id: reserva.habitacion_id },
    });
    if (habitacion && reserva.estado !== 'cancelada') {
      habitacion.disponible = true;
      await this.habitacionRepo.save(habitacion);
    }
    await this.reservaRepo.remove(reserva);
    return { message: `Reserva ${id} eliminada` };
  }
}