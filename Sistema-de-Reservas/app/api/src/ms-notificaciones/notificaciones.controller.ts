import {
  Controller, Get, Post, Put,
  Param, Body,
} from '@nestjs/common';
import { NotificacionesService } from './notificaciones.service';
import { CreateNotificacionDto } from './dto/create-notificacion.dto';

@Controller('notificaciones')
export class NotificacionesController {
  constructor(private readonly notificacionesService: NotificacionesService) {}

  @Get()
  findAll() {
    return this.notificacionesService.findAll();
  }

  // GET /notificaciones/usuario/:usuario_id
  @Get('usuario/:usuario_id')
  findByUsuario(@Param('usuario_id') usuario_id: string) {
    return this.notificacionesService.findByUsuario(usuario_id);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.notificacionesService.findOne(id);
  }

  @Post()
  create(@Body() dto: CreateNotificacionDto) {
    return this.notificacionesService.create(dto);
  }

  // PUT /notificaciones/:id/leer
  @Put(':id/leer')
  marcarLeida(@Param('id') id: string) {
    return this.notificacionesService.marcarLeida(id);
  }
}