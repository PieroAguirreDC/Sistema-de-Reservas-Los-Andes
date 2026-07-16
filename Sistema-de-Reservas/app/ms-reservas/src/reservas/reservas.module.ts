import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReservasController } from './reservas.controller.js';
import { ReservasService } from './reservas.service.js';
import { Reserva } from './entities/reserva.entity.js';
import { SnsService } from '@reservas/common';

@Module({
  imports: [TypeOrmModule.forFeature([Reserva])],
  controllers: [ReservasController],
  providers: [ReservasService, SnsService],
  exports: [ReservasService],
})
export class ReservasModule {}