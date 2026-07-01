import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HabitacionesController } from './habitaciones.controller';
import { HabitacionesService } from './habitaciones.service';
import { Habitacion } from './entities/habitacion.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Habitacion])],
  controllers: [HabitacionesController],
  providers: [HabitacionesService],
  exports: [HabitacionesService],
})
export class HabitacionesModule {}