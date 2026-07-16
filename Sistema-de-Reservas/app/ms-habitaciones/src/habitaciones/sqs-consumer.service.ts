import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SqsConsumerService } from '@reservas/common';
import { HabitacionesService } from './habitaciones.service.js';

@Injectable()
export class HabitacionesSqsConsumer implements OnModuleInit {
  private readonly logger = new Logger(HabitacionesSqsConsumer.name);

  constructor(
    private readonly sqsConsumer: SqsConsumerService,
    private readonly configService: ConfigService,
    private readonly habitacionesService: HabitacionesService,
  ) {}

  onModuleInit() {
    const queueUrl = this.configService.get<string>('SQS_RESERVAS_HABITACIONES_URL');
    if (!queueUrl) {
      this.logger.warn('SQS_RESERVAS_HABITACIONES_URL no definida. El consumer no iniciará.');
      return;
    }

    this.sqsConsumer.startPolling(queueUrl, async (body) => {
      // El body viene de SNS, así que el mensaje real está en body.Message (string)
      let payload;
      try {
        payload = JSON.parse(body.Message as string);
      } catch (e) {
        payload = body; // Fallback por si enviaron directo a SQS
      }

      this.logger.log(`Procesando evento SQS: ${JSON.stringify(payload)}`);

      if (payload.tipo === 'RESERVA_CONFIRMADA') {
        // La habitación ya debería estar ocupada, pero aseguramos
        await this.habitacionesService.updateDisponibilidad(payload.habitacion_id, false);
      } else if (payload.tipo === 'RESERVA_CANCELADA') {
        // Liberar la habitación
        await this.habitacionesService.updateDisponibilidad(payload.habitacion_id, true);
      }
    });
  }
}
