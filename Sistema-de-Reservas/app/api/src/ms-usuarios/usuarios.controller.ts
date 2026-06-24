import { Controller, Get, Post, Put, Delete, Param, Body } from '@nestjs/common';
import { UsuariosService } from './usuarios.service';

@Controller('usuarios')
export class UsuariosController {
  constructor(private readonly usuariosService: UsuariosService) {}

  @Get()
  findAll() {
    return this.usuariosService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.usuariosService.findOne(id);
  }

  @Post()
  create(@Body() body: object) {
    return this.usuariosService.create(body);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() body: object) {
    return this.usuariosService.update(id, body);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.usuariosService.remove(id);
  }
}