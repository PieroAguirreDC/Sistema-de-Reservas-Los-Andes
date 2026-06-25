export class CreateHabitacionDto {
  numero!: string;
  tipo!: string;
  precio_por_noche!: number;
  disponible?: boolean;
  descripcion?: string;
}