import { Injectable, Logger, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  SQSClient,
  ReceiveMessageCommand,
  DeleteMessageCommand,
} from '@aws-sdk/client-sqs';

export type SqsMessageHandler = (body: Record<string, unknown>) => Promise<void>;

@Injectable()
export class SqsConsumerService implements OnModuleDestroy {
  private readonly client: SQSClient;
  private readonly logger = new Logger(SqsConsumerService.name);
  private running = false;

  constructor(private readonly configService: ConfigService) {
    this.client = new SQSClient({
      region: configService.get<string>('AWS_REGION', 'us-east-2'),
    });
  }

  /**
   * Inicia el long-polling de una cola SQS. Llama al handler con cada mensaje.
   * Usa WaitTimeSeconds = 20 para reducir costos (long polling).
   */
  async startPolling(queueUrl: string, handler: SqsMessageHandler): Promise<void> {
    this.running = true;
    this.logger.log(`Iniciando consumo de cola: ${queueUrl}`);

    while (this.running) {
      try {
        const response = await this.client.send(
          new ReceiveMessageCommand({
            QueueUrl: queueUrl,
            MaxNumberOfMessages: 10,
            WaitTimeSeconds: 20,
            MessageAttributeNames: ['All'],
          }),
        );

        if (response.Messages && response.Messages.length > 0) {
          for (const message of response.Messages) {
            try {
              const body = JSON.parse(message.Body || '{}');
              await handler(body);

              // Borrar mensaje tras procesamiento exitoso
              await this.client.send(
                new DeleteMessageCommand({
                  QueueUrl: queueUrl,
                  ReceiptHandle: message.ReceiptHandle,
                }),
              );
            } catch (err) {
              this.logger.error(
                `Error procesando mensaje ${message.MessageId}: ${err}`,
              );
              // No se borra → va al DLQ tras maxReceiveCount intentos
            }
          }
        }
      } catch (err) {
        this.logger.error(`Error recibiendo mensajes de ${queueUrl}: ${err}`);
        // Esperar antes de reintentar
        await new Promise((resolve) => setTimeout(resolve, 5000));
      }
    }
  }

  onModuleDestroy() {
    this.running = false;
  }
}
