import { Controller, Get, Post, Put, Patch, Delete, Param, Body } from '@nestjs/common';
import { HabitacionesService } from './habitaciones.service';
import { CreateHabitacionDto } from './dto/create-habitacion.dto';

@Controller('habitaciones')
export class HabitacionesController {
  constructor(private readonly habitacionesService: HabitacionesService) {}

  @Get('error-test')
  errorTest() {
    import('@nestjs/common').then(({ Logger, InternalServerErrorException }) => {
      const logger = new Logger('TestAlarma');
      logger.error('ERROR DE PRUEBA: Forzando alarma de CloudWatch en ms-habitaciones');
    });
    throw new Error('Endpoint de prueba para disparar la alarma');
  }

  @Get()
  findAll() {
    return this.habitacionesService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.habitacionesService.findOne(id);
  }

  @Post()
  create(@Body() dto: CreateHabitacionDto) {
    return this.habitacionesService.create(dto);
  }

  @Put(':id')
  update(
    @Param('id') id: string,
    @Body() body: Partial<CreateHabitacionDto>,
  ) {
    return this.habitacionesService.update(id, body);
  }

  @Patch(':id/disponibilidad')
  updateDisponibilidad(
    @Param('id') id: string,
    @Body('disponible') disponible: boolean,
  ) {
    return this.habitacionesService.updateDisponibilidad(id, disponible);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.habitacionesService.remove(id);
  }
}