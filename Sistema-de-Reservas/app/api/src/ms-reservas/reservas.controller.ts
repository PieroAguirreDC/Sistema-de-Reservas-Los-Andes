import { Controller, Get, Post, Put, Delete, Param, Body } from '@nestjs/common';
import { ReservasService } from './reservas.service';

@Controller('reservas')
export class ReservasController {
  constructor(private readonly reservasService: ReservasService) {}

  @Get()
  findAll() {
    return this.reservasService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.reservasService.findOne(id);
  }

  @Post()
  create(@Body() body: object) {
    return this.reservasService.create(body);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() body: object) {
    return this.reservasService.update(id, body);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.reservasService.remove(id);
  }
}