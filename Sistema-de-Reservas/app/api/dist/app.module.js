"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const reservas_module_1 = require("./ms-reservas/reservas.module");
const habitaciones_module_1 = require("./ms-habitaciones/habitaciones.module");
const usuarios_module_1 = require("./ms-usuarios/usuarios.module");
const pagos_module_1 = require("./ms-pagos/pagos.module");
const notificaciones_module_1 = require("./ms-notificaciones/notificaciones.module");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            reservas_module_1.ReservasModule,
            habitaciones_module_1.HabitacionesModule,
            usuarios_module_1.UsuariosModule,
            pagos_module_1.PagosModule,
            notificaciones_module_1.NotificacionesModule,
        ],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map