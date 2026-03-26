import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { MongooseModule } from '@nestjs/mongoose';
import { SessionSchema } from './entities/session.entity';
import { JwtModule } from '@nestjs/jwt';
import { UserSchema } from 'src/users/entities/user.entity';
import { NotificationsModule } from 'src/notifications/notifications.module';
import { PasswordReset, PasswordResetSchema } from './entities/password-reset.entity';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: 'Session', schema: SessionSchema },
      { name: 'User', schema: UserSchema },
      { name: PasswordReset.name, schema: PasswordResetSchema }
    ]),
    JwtModule.register({}),// SIN COFIG GLOBAL CADA TOKEN  USA SU PROPIO SECRET
    NotificationsModule
  ],
  controllers: [AuthController],
  providers: [AuthService],
  exports: [
    AuthService, JwtModule
  ]
})
export class AuthModule {}
