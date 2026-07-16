import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HabitacionesController } from './habitaciones.controller.js';
import { HabitacionesService } from './habitaciones.service.js';
import { Habitacion } from './entities/habitacion.entity.js';
import { HabitacionesSqsConsumer } from './sqs-consumer.service.js';
import { SqsConsumerService } from '@reservas/common';

@Module({
  imports: [TypeOrmModule.forFeature([Habitacion])],
  controllers: [HabitacionesController],
  providers: [HabitacionesService, HabitacionesSqsConsumer, SqsConsumerService],
  exports: [HabitacionesService],
})
export class HabitacionesModule {}