import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SNSClient, PublishCommand } from '@aws-sdk/client-sns';

@Injectable()
export class SnsService {
  private readonly client: SNSClient;
  private readonly logger = new Logger(SnsService.name);

  constructor(private readonly configService: ConfigService) {
    this.client = new SNSClient({
      region: configService.get<string>('AWS_REGION', 'us-east-2'),
    });
  }

  async publish(topicArn: string, message: object): Promise<void> {
    try {
      await this.client.send(
        new PublishCommand({
          TopicArn: topicArn,
          Message: JSON.stringify(message),
          MessageAttributes: {
            eventType: {
              DataType: 'String',
              StringValue: (message as { tipo?: string }).tipo || 'UNKNOWN',
            },
          },
        }),
      );
      this.logger.log(`Evento publicado a ${topicArn}: ${JSON.stringify(message)}`);
    } catch (error) {
      this.logger.error(`Error publicando a SNS: ${error}`);
      throw error;
    }
  }
}
