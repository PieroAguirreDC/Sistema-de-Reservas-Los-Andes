import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PagosController } from './pagos.controller.js';
import { PagosService } from './pagos.service.js';
import { Pago } from './entities/pago.entity.js';
import { SnsService, SqsConsumerService } from '@reservas/common';
import { PagosSqsConsumer } from './sqs-consumer.service.js';

@Module({
  imports: [TypeOrmModule.forFeature([Pago])],
  controllers: [PagosController],
  providers: [PagosService, SnsService, SqsConsumerService, PagosSqsConsumer],
  exports: [PagosService],
})
export class PagosModule {}