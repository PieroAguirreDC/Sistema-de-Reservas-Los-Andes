import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SqsConsumerService } from '@reservas/common';
import { PagosService } from './pagos.service.js';

@Injectable()
export class PagosSqsConsumer implements OnModuleInit {
  private readonly logger = new Logger(PagosSqsConsumer.name);

  constructor(
    private readonly sqsConsumer: SqsConsumerService,
    private readonly configService: ConfigService,
    private readonly pagosService: PagosService,
  ) {}

  onModuleInit() {
    const queueUrl = this.configService.get<string>('SQS_RESERVAS_PAGOS_URL');
    if (!queueUrl) {
      this.logger.warn('SQS_RESERVAS_PAGOS_URL no definida. El consumer no iniciará.');
      return;
    }

    this.sqsConsumer.startPolling(queueUrl, async (body) => {
      let payload;
      try {
        payload = JSON.parse(body.Message as string);
      } catch (e) {
        payload = body;
      }

      this.logger.log(`Procesando evento SQS: ${JSON.stringify(payload)}`);

      if (payload.tipo === 'RESERVA_CREADA') {
        const fechaInicio = new Date(payload.fecha_inicio);
        const fechaFin = new Date(payload.fecha_fin);
        
        // Calcular noches (fecha_fin es exclusiva)
        const diffMs = fechaFin.getTime() - fechaInicio.getTime();
        const diffDays = diffMs / (1000 * 60 * 60 * 24);
        const noches = Math.max(1, Math.ceil(diffDays));
        
        const monto = noches * payload.precio_por_noche;
        
        await this.pagosService.create({
          reserva_id: payload.reserva_id,
          monto: monto,
        });
        this.logger.log(`Pago pendiente creado para reserva ${payload.reserva_id} por $${monto} (${noches} noches)`);
      }
    });
  }
}
