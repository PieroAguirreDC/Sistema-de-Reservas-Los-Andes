import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { Repository } from 'typeorm';
import { Pago } from './entities/pago.entity.js';
import { CreatePagoDto } from './dto/create-pago.dto.js';
import { SnsService } from '@reservas/common';

@Injectable()
export class PagosService {
  private readonly logger = new Logger(PagosService.name);
  private readonly topicArn: string;

  constructor(
    @InjectRepository(Pago)
    private readonly repo: Repository<Pago>,
    private readonly configService: ConfigService,
    private readonly snsService: SnsService,
  ) {
    this.topicArn = this.configService.get<string>('SNS_TOPIC_PAGOS_ARN', '');
  }

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
    const estadoAnterior = pago.estado;
    Object.assign(pago, data);
    const saved = await this.repo.save(pago);

    if (this.topicArn && saved.estado === 'completado' && estadoAnterior !== 'completado') {
      await this.snsService.publish(this.topicArn, {
        tipo: 'PAGO_COMPLETADO',
        pago_id: saved.id,
        reserva_id: saved.reserva_id,
        monto: saved.monto,
      });
    }

    return saved;
  }

  async remove(id: string): Promise<{ message: string }> {
    const pago = await this.findOne(id);
    await this.repo.remove(pago);
    return { message: `Pago ${id} eliminado` };
  }
}