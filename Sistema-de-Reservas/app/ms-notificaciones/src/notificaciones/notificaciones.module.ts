import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { NotificacionesController } from './notificaciones.controller.js';
import { NotificacionesService } from './notificaciones.service.js';
import { Notificacion } from './entities/notificacion.entity.js';
import { NotificacionesSqsConsumer } from './sqs-consumer.service.js';
import { SqsConsumerService } from '@reservas/common';

@Module({
  imports: [TypeOrmModule.forFeature([Notificacion])],
  controllers: [NotificacionesController],
  providers: [NotificacionesService, NotificacionesSqsConsumer, SqsConsumerService],
  exports: [NotificacionesService],
})
export class NotificacionesModule {}