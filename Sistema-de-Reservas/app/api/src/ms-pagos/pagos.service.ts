import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Pago } from './entities/pago.entity';
import { CreatePagoDto } from './dto/create-pago.dto';

@Injectable()
export class PagosService {
  constructor(
    @InjectRepository(Pago)
    private readonly repo: Repository<Pago>,
  ) {}

  findAll(reserva_id?: string) {
    if (reserva_id) return this.repo.find({ where: { reserva_id } });
    return this.repo.find();
  }

  async findOne(id: string): Promise<Pago> {
    const pago = await this.repo.findOne({ where: { id } });
    if (!pago) throw new NotFoundException(`Pago ${id} no encontrado`);
    return pago;
  }

  create(dto: CreatePagoDto): Promise<Pago> {
    const pago = this.repo.create({ ...dto, estado: 'pendiente' });
    return this.repo.save(pago);
  }

  async update(id: string, data: Partial<Pago>): Promise<Pago> {
    const pago = await this.findOne(id);
    Object.assign(pago, data);
    return this.repo.save(pago);
  }

  async remove(id: string): Promise<{ message: string }> {
    const pago = await this.findOne(id);
    await this.repo.remove(pago);
    return { message: `Pago ${id} eliminado` };
  }
}