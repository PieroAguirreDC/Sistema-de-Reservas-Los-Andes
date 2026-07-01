import { Body, Controller, Post } from '@nestjs/common';
import { UploadsService } from './uploads.service';
import { RequestUploadDto } from './dto/request-upload.dto';

@Controller('uploads')
export class UploadsController {
  constructor(private readonly uploadsService: UploadsService) {}

  @Post('habitacion-imagen')
  habitacionImagen(@Body() dto: RequestUploadDto) {
    return this.uploadsService.presignPublicImage(dto.fileName, dto.contentType);
  }

  @Post('comprobante-pago')
  comprobantePago(@Body() dto: RequestUploadDto) {
    return this.uploadsService.presignPrivateFile(dto.fileName, dto.contentType, 'comprobantes-pago');
  }

  @Post('perfil-foto')
  perfilFoto(@Body() dto: RequestUploadDto) {
    return this.uploadsService.presignPrivateFile(
      dto.fileName,
      dto.contentType,
      'perfiles',
      ['image/jpeg', 'image/png', 'image/webp'],
    );
  }
}