import { Controller, Get, Post, Put, Delete, Param, Body } from '@nestjs/common';
import { HabitacionesService } from './habitaciones.service';
import { CreateHabitacionDto } from './dto/create-habitacion.dto';

@Controller('habitaciones')
export class HabitacionesController {
  constructor(private readonly habitacionesService: HabitacionesService) {}

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
  update(@Param('id') id: string, @Body() body: Partial<CreateHabitacionDto>) {
    return this.habitacionesService.update(id, body);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.habitacionesService.remove(id);
  }
}