import { NotificacionesService } from './notificaciones.service';
export declare class NotificacionesController {
    private readonly notificacionesService;
    constructor(notificacionesService: NotificacionesService);
    findAll(): never[];
    findOne(id: string): {
        id: string;
    };
    create(body: object): object;
}
