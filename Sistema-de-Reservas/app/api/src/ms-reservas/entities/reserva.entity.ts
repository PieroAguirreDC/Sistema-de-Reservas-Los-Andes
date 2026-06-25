import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne } from 'typeorm';

@Entity('reservas')
export class Reserva {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column()
  usuario_id!: string;

  @Column()
  habitacion_id!: string;

  @Column({ type: 'date' })
  fecha_inicio!: Date;

  @Column({ type: 'date' })
  fecha_fin!: Date;

  @Column({ default: 'pendiente' })
  estado!: string;

  @CreateDateColumn()
  created_at!: Date;
}