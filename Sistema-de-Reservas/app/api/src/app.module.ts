import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ReservasModule } from './ms-reservas/reservas.module';
import { HabitacionesModule } from './ms-habitaciones/habitaciones.module';
import { UsuariosModule } from './ms-usuarios/usuarios.module';
import { PagosModule } from './ms-pagos/pagos.module';
import { NotificacionesModule } from './ms-notificaciones/notificaciones.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    // TypeOrmModule.forRootAsync({ ... }) <- comentado hasta tener DB
    ReservasModule,
    HabitacionesModule,
    UsuariosModule,
    PagosModule,
    NotificacionesModule,
  ],
})
export class AppModule {}