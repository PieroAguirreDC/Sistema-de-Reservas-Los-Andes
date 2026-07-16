import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PagosController } from './pagos.controller.js';
import { PagosService } from './pagos.service.js';
import { Pago } from './entities/pago.entity.js';
import { SnsService } from '@reservas/common';

@Module({
  imports: [TypeOrmModule.forFeature([Pago])],
  controllers: [PagosController],
  providers: [PagosService, SnsService],
  exports: [PagosService],
})
export class PagosModule {}