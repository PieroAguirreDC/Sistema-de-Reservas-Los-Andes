import { PagosService } from './pagos.service';
export declare class PagosController {
    private readonly pagosService;
    constructor(pagosService: PagosService);
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
