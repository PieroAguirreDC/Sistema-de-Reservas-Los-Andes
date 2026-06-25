import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReservasModule } from './ms-reservas/reservas.module';
import { HabitacionesModule } from './ms-habitaciones/habitaciones.module';
import { UsuariosModule } from './ms-usuarios/usuarios.module';
import { PagosModule } from './ms-pagos/pagos.module';
import { NotificacionesModule } from './ms-notificaciones/notificaciones.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get('DB_HOST'),
        port: config.get<number>('DB_PORT'),
        username: config.get('DB_USERNAME'),
        password: config.get('DB_PASSWORD'),
        database: config.get('DB_NAME'),
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        synchronize: config.get('NODE_ENV') !== 'production',
      }),
      inject: [ConfigService],
    }),
    ReservasModule,
    HabitacionesModule,
    UsuariosModule,
    PagosModule,
    NotificacionesModule,
  ],
})
export class AppModule {}