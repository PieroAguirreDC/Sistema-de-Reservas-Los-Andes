import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('usuarios')
export class Usuario {
  @PrimaryGeneratedColumn('uuid')
  id: string = '';

  @Column()
  nombre: string = '';

  @Column({ unique: true })
  email: string = '';

  @Column()
  password: string = '';

  @Column({ default: 'cliente' })
  rol: string = 'cliente';

  @CreateDateColumn()
  created_at: Date = new Date();
}