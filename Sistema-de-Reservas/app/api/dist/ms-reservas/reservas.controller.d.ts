import { ReservasService } from './reservas.service';
export declare class ReservasController {
    private readonly reservasService;
    constructor(reservasService: ReservasService);
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
