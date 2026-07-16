import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Habitacion } from './entities/habitacion.entity';
import { CreateHabitacionDto } from './dto/create-habitacion.dto';

@Injectable()
export class HabitacionesService {
  constructor(
    @InjectRepository(Habitacion)
    private readonly repo: Repository<Habitacion>,
  ) {}

  findAll(): Promise<Habitacion[]> {
    return this.repo.find();
  }

  async findOne(id: string): Promise<Habitacion> {
    const hab = await this.repo.findOne({ where: { id } });
    if (!hab) throw new NotFoundException(`Habitación ${id} no encontrada`);
    return hab;
  }

  create(dto: CreateHabitacionDto): Promise<Habitacion> {
    const hab = this.repo.create({ ...dto, disponible: dto.disponible ?? true });
    return this.repo.save(hab);
  }

  async update(id: string, data: Partial<CreateHabitacionDto>): Promise<Habitacion> {
    const hab = await this.findOne(id);
    Object.assign(hab, data);
    return this.repo.save(hab);
  }

  async updateDisponibilidad(id: string, disponible: boolean): Promise<Habitacion> {
    const hab = await this.findOne(id);
    hab.disponible = disponible;
    return this.repo.save(hab);
  }

  async remove(id: string): Promise<{ message: string }> {
    const hab = await this.findOne(id);
    await this.repo.remove(hab);
    return { message: `Habitación ${id} eliminada` };
  }
}