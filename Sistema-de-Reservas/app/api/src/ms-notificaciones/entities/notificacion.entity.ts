import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('notificaciones')
export class Notificacion {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column()
  usuario_id!: string;

  @Column()
  mensaje!: string;

  @Column({ default: false })
  leida!: boolean;

  @CreateDateColumn()
  created_at!: Date;
}