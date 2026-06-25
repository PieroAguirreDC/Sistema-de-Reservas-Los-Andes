import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from 'typeorm';

@Entity('habitaciones')
export class Habitacion {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  numero: string;

  @Column()
  tipo: string;

  @Column('decimal', { precision: 10, scale: 2 })
  precio_por_noche: number;

  @Column({ default: true })
  disponible: boolean;

  @Column({ nullable: true })
  descripcion: string;
}