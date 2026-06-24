import { Injectable } from '@nestjs/common';

@Injectable()
export class HabitacionesService {
  findAll() {
    return [];
  }

  findOne(id: string) {
    return { id };
  }

  create(data: object) {
    return data;
  }

  update(id: string, data: object) {
    return { id, ...data };
  }

  remove(id: string) {
    return { id };
  }
}