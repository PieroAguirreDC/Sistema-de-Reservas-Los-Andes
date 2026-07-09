import { BadRequestException, Injectable } from '@nestjs/common';
import { S3Client } from '@aws-sdk/client-s3';
import { createPresignedPost } from '@aws-sdk/s3-presigned-post';
import { randomUUID } from 'crypto';

const IMAGE_TYPES = ['image/jpeg', 'image/png', 'image/webp'];
const PDF_TYPES = ['application/pdf'];
const PRESIGNED_URL_TTL_SECONDS = 60;

@Injectable()
export class UploadsService {
  private readonly s3 = new S3Client({ region: process.env.AWS_REGION || 'us-east-2' });

  private readonly bucketPublic = process.env.S3_BUCKET_PUBLIC || '';
  private readonly bucketPrivate = process.env.S3_BUCKET_PRIVATE || '';
  private readonly maxImageBytes = Number(process.env.S3_MAX_IMAGE_SIZE_MB || 2) * 1024 * 1024;
  private readonly maxPdfBytes = Number(process.env.S3_MAX_PDF_SIZE_MB || 5) * 1024 * 1024;

  /** Imágenes de habitaciones/catálogo -> bucket público */
  async presignPublicImage(fileName: string, contentType: string) {
    this.validarTipo(contentType, IMAGE_TYPES);
    const key = `habitaciones/${randomUUID()}-${this.sanitize(fileName)}`;

    const presigned = await createPresignedPost(this.s3, {
      Bucket: this.bucketPublic,
      Key: key,
      Conditions: [
        ['content-length-range', 0, this.maxImageBytes],
        ['eq', '$Content-Type', contentType],
      ],
      Fields: { 'Content-Type': contentType },
      Expires: PRESIGNED_URL_TTL_SECONDS,
    });

    return {
      ...presigned,
      key,
      // OJO: esta URL directa a S3 solo será visible públicamente cuando
      // exista CloudFront delante del bucket (pendiente, iac/cdn no existe
      // aún). Por ahora esta respuesta solo sirve para SUBIR.
      publicUrl: `https://${this.bucketPublic}.s3.${process.env.AWS_REGION || 'us-east-2'}.amazonaws.com/${key}`,
    };
  }

  /** Comprobantes de pago / fotos de perfil -> bucket privado */
  async presignPrivateFile(
    fileName: string,
    contentType: string,
    prefix: 'comprobantes-pago' | 'perfiles',
    allowedTypes: string[] = [...IMAGE_TYPES, ...PDF_TYPES],
  ) {
    this.validarTipo(contentType, allowedTypes);
    const maxBytes = contentType === 'application/pdf' ? this.maxPdfBytes : this.maxImageBytes;
    const key = `${prefix}/${randomUUID()}-${this.sanitize(fileName)}`;

    const presigned = await createPresignedPost(this.s3, {
      Bucket: this.bucketPrivate,
      Key: key,
      Conditions: [
        ['content-length-range', 0, maxBytes],
        ['eq', '$Content-Type', contentType],
      ],
      Fields: { 'Content-Type': contentType },
      Expires: PRESIGNED_URL_TTL_SECONDS,
    });

    return { ...presigned, key };
  }

  private validarTipo(contentType: string, permitidos: string[]) {
    if (!permitidos.includes(contentType)) {
      throw new BadRequestException(
        `Tipo de archivo no permitido: ${contentType}. Permitidos: ${permitidos.join(', ')}`,
      );
    }
  }

  private sanitize(fileName: string): string {
    return fileName.replace(/[^a-zA-Z0-9.\-_]/g, '_');
  }
}