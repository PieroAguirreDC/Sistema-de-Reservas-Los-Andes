import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SqsConsumerService } from '@reservas/common';
import { NotificacionesService } from './notificaciones.service.js';

@Injectable()
export class NotificacionesSqsConsumer implements OnModuleInit {
  private readonly logger = new Logger(NotificacionesSqsConsumer.name);

  constructor(
    private readonly sqsConsumer: SqsConsumerService,
    private readonly configService: ConfigService,
    private readonly notifService: NotificacionesService,
  ) {}

  onModuleInit() {
    const reservasQueueUrl = this.configService.get<string>('SQS_RESERVAS_NOTIFICACIONES_URL');
    const pagosQueueUrl = this.configService.get<string>('SQS_PAGOS_NOTIFICACIONES_URL');

    if (reservasQueueUrl) {
      this.sqsConsumer.startPolling(reservasQueueUrl, async (body) => {
        let payload;
        try { payload = JSON.parse(body.Message as string); } catch { payload = body; }
        this.logger.log(`Evento de Reserva: ${JSON.stringify(payload)}`);
        
        await this.notifService.create({
          usuario_id: payload.usuario_id || 'system',
          mensaje: `Evento de reserva: ${payload.tipo} (ID: ${payload.reserva_id})`,
        });
      });
    }

    if (pagosQueueUrl) {
      this.sqsConsumer.startPolling(pagosQueueUrl, async (body) => {
        let payload;
        try { payload = JSON.parse(body.Message as string); } catch { payload = body; }
        this.logger.log(`Evento de Pago: ${JSON.stringify(payload)}`);
        
        await this.notifService.create({
          usuario_id: 'system', // O buscar el usuario_id si viene en el payload
          mensaje: `Pago procesado: ${payload.tipo} (Reserva ID: ${payload.reserva_id}, Monto: $${payload.monto})`,
        });
      });
    }
  }
}
