import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('pagos')
export class Pago {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  reserva_id: string;

  @Column('decimal', { precision: 10, scale: 2 })
  monto: number;

  @Column({ default: 'pendiente' })
  estado: string;

  @Column({ nullable: true })
  metodo_pago: string;

  @CreateDateColumn()
  created_at: Date;
}