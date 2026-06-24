import { Controller, Get, Post, Put, Delete, Param, Body } from '@nestjs/common';
import { HabitacionesService } from './habitaciones.service';

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
  create(@Body() body: object) {
    return this.habitacionesService.create(body);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() body: object) {
    return this.habitacionesService.update(id, body);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.habitacionesService.remove(id);
  }
}