import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, ExtractJwt } from 'passport-jwt';
import { passportJwtSecret } from 'jwks-rsa';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(configService: ConfigService) {
    const cognitoRegion = configService.get<string>('COGNITO_REGION', 'us-east-2');
    const userPoolId = configService.get<string>('COGNITO_USER_POOL_ID', '');

    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      audience: configService.get<string>('COGNITO_CLIENT_ID', ''),
      issuer: `https://cognito-idp.${cognitoRegion}.amazonaws.com/${userPoolId}`,
      algorithms: ['RS256'],
      secretOrKeyProvider: passportJwtSecret({
        cache: true,
        rateLimit: true,
        jwksRequestsPerMinute: 10,
        jwksUri: `https://cognito-idp.${cognitoRegion}.amazonaws.com/${userPoolId}/.well-known/jwks.json`,
      }),
    });
  }

  validate(payload: {
    sub: string;
    email?: string;
    'custom:rol'?: string;
    'cognito:username'?: string;
  }) {
    return {
      userId: payload.sub,
      email: payload.email || payload['cognito:username'] || '',
      rol: payload['custom:rol'] || 'cliente',
    };
  }
}
