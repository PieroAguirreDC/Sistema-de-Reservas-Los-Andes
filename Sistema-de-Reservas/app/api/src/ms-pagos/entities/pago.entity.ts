import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('pagos')
export class Pago {
  @PrimaryGeneratedColumn('uuid')
  id: string = '';

  @Column()
  reserva_id: string = '';

  @Column('decimal', { precision: 10, scale: 2 })
  monto: number = 0;

  @Column({ default: 'pendiente' })
  estado: string = 'pendiente';

  @Column({ nullable: true })
  metodo_pago: string = '';

  @CreateDateColumn()
  created_at: Date = new Date();
}