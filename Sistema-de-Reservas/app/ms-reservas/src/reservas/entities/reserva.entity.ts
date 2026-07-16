import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('reservas')
export class Reserva {
  @PrimaryGeneratedColumn('uuid')
  id: string = '';

  @Column()
  usuario_id: string = '';

  @Column()
  habitacion_id: string = '';

  @Column({ type: 'date' })
  fecha_inicio: Date = new Date();

  @Column({ type: 'date' })
  fecha_fin: Date = new Date();

  @Column({ default: 'pendiente' })
  estado: string = 'pendiente';

  @CreateDateColumn()
  created_at: Date = new Date();
}