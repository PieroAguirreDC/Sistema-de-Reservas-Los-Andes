import { Controller, Get, Post, Put, Delete, Param, Body } from '@nestjs/common';
import { PagosService } from './pagos.service';

@Controller('pagos')
export class PagosController {
  constructor(private readonly pagosService: PagosService) {}

  @Get()
  findAll() {
    return this.pagosService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.pagosService.findOne(id);
  }

  @Post()
  create(@Body() body: object) {
    return this.pagosService.create(body);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() body: object) {
    return this.pagosService.update(id, body);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.pagosService.remove(id);
  }
}