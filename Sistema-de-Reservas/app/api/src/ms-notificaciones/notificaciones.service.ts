import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Notificacion } from './entities/notificacion.entity';
import { CreateNotificacionDto } from './dto/create-notificacion.dto';

@Injectable()
export class NotificacionesService {
  constructor(
    @InjectRepository(Notificacion)
    private readonly repo: Repository<Notificacion>,
  ) {}

  findAll() {
    return this.repo.find({ order: { created_at: 'DESC' } });
  }

  findByUsuario(usuario_id: string) {
    return this.repo.find({
      where: { usuario_id },
      order: { created_at: 'DESC' },
    });
  }

  async findOne(id: string): Promise<Notificacion> {
    const notif = await this.repo.findOne({ where: { id } });
    if (!notif) throw new NotFoundException(`Notificación ${id} no encontrada`);
    return notif;
  }

  create(dto: CreateNotificacionDto): Promise<Notificacion> {
    const notif = this.repo.create(dto);
    return this.repo.save(notif);
  }

  async marcarLeida(id: string): Promise<Notificacion> {
    const notif = await this.findOne(id);
    notif.leida = true;
    return this.repo.save(notif);
  }
}