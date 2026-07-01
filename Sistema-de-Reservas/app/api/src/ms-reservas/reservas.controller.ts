import {
  Controller, Get, Post, Put, Delete,
  Param, Body, Query,
} from '@nestjs/common';
import { ReservasService } from './reservas.service';
import { CreateReservaDto } from './dto/create-reserva.dto';
import { Reserva } from './entities/reserva.entity';

@Controller('reservas')
export class ReservasController {
  constructor(private readonly reservasService: ReservasService) {}

  @Get()
  findAll(@Query('usuario_id') usuario_id?: string) {
    return this.reservasService.findAll(usuario_id);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.reservasService.findOne(id);
  }

  @Post()
  create(@Body() dto: CreateReservaDto) {
    return this.reservasService.create(dto);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() body: Partial<Reserva>) {
    return this.reservasService.update(id, body);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.reservasService.remove(id);
  }
}