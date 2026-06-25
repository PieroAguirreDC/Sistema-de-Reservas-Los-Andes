import { Module } from '@nestjs/common';
<<<<<<< HEAD
import { ConfigModule } from '@nestjs/config';
=======
import { ConfigModule, ConfigService } from '@nestjs/config';
>>>>>>> 031b743a46a0270d76b1a50613f641869e7d9f6e
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReservasModule } from './ms-reservas/reservas.module';
import { HabitacionesModule } from './ms-habitaciones/habitaciones.module';
import { UsuariosModule } from './ms-usuarios/usuarios.module';
import { PagosModule } from './ms-pagos/pagos.module';
import { NotificacionesModule } from './ms-notificaciones/notificaciones.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
<<<<<<< HEAD
    TypeOrmModule.forRoot({
    type: 'postgres',
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    username: process.env.DB_USERNAME || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    database: process.env.DB_NAME || 'reservas_db',
    entities: [__dirname + '/**/*.entity{.ts,.js}'],
    synchronize: process.env.NODE_ENV !== 'production', // ← este es el único cambio
  }),
=======
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
>>>>>>> 031b743a46a0270d76b1a50613f641869e7d9f6e
    ReservasModule,
    HabitacionesModule,
    UsuariosModule,
    PagosModule,
    NotificacionesModule,
  ],
})
export class AppModule {}