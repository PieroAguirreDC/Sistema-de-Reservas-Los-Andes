// app/api/src/app.module.ts
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReservasModule } from './ms-reservas/reservas.module';
import { HabitacionesModule } from './ms-habitaciones/habitaciones.module';
import { UsuariosModule } from './ms-usuarios/usuarios.module';
import { PagosModule } from './ms-pagos/pagos.module';
import { NotificacionesModule } from './ms-notificaciones/notificaciones.module';

// Entities
import { Usuario } from './ms-usuarios/entities/usuario.entity';
import { Habitacion } from './ms-habitaciones/entities/habitacion.entity';
import { Reserva } from './ms-reservas/entities/reserva.entity';
import { Pago } from './ms-pagos/entities/pago.entity';
import { Notificacion } from './ms-notificaciones/entities/notificacion.entity';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRoot({
  type: 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  username: process.env.DB_USERNAME || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  database: process.env.DB_NAME || 'reservas_db',
  entities: [Usuario, Habitacion, Reserva, Pago, Notificacion],
  synchronize: process.env.NODE_ENV !== 'production',
  ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
}),
    UsuariosModule,
    HabitacionesModule,
    ReservasModule,
    PagosModule,
    NotificacionesModule,
  ],
})
export class AppModule {}