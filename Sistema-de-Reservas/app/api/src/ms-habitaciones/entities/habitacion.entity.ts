import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from 'typeorm';

@Entity('habitaciones')
export class Habitacion {
  @PrimaryGeneratedColumn('uuid')
  id: string = '';

  @Column()
  numero: string = '';

  @Column()
  tipo: string = '';

  @Column('decimal', { precision: 10, scale: 2 })
  precio_por_noche: number = 0;

  @Column({ default: true })
  disponible: boolean = true;

  @Column({ nullable: true })
  descripcion: string = '';
}