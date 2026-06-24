import { Injectable } from '@nestjs/common';

@Injectable()
export class NotificacionesService {
  findAll() {
    return [];
  }

  findOne(id: string) {
    return { id };
  }

  create(data: object) {
    return data;
  }
}