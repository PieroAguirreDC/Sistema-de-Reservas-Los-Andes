import { UsuariosService } from './usuarios.service';
export declare class UsuariosController {
    private readonly usuariosService;
    constructor(usuariosService: UsuariosService);
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
