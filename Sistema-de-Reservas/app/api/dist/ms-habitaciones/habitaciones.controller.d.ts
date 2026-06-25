import { HabitacionesService } from './habitaciones.service';
export declare class HabitacionesController {
    private readonly habitacionesService;
    constructor(habitacionesService: HabitacionesService);
    findAll(): never[];
    findOne(id: string): {
        id: string;
    };
    create(body: object): object;
    update(id: string, body: object): {
        id: string;
    };
    remove(id: string): {
        id: string;
    };
}
