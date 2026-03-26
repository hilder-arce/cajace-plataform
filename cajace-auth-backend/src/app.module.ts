import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { APP_GUARD } from '@nestjs/core';

import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { RolesModule } from './roles/roles.module';
import { PermissionsModule } from './permissions/permissions.module';
import { ModulesModule } from './modules/modules.module';
import { NotificationsModule } from './notifications/notifications.module';

import { AuthGuard } from './guards/auth.guard';
import { PermissionsGuard } from './guards/permissions.guard';

@Module({
  imports: [
    // ==========================================
    // CONFIGURACIÓN GLOBAL Y VARIABLES DE ENTORNO
    // ==========================================
    ConfigModule.forRoot({
      isGlobal: true,
    }),

    // ==========================================
    // INFRAESTRUCTURA DE PERSISTENCIA (MONGODB)
    // ==========================================
    MongooseModule.forRootAsync({
      useFactory: (configService: ConfigService) => ({
        uri: configService.get<string>('MONGODB_URI'),
      }),
      inject: [ConfigService],
    }),

    // ==========================================
    // MÓDULOS DE NEGOCIO DEL SISTEMA
    // ==========================================
    AuthModule, 
    UsersModule, 
    RolesModule, 
    PermissionsModule, 
    ModulesModule, 
    NotificationsModule
  ],
  controllers: [],
  providers: [
    // ==========================================
    // GUARDS GLOBALES DE SEGURIDAD
    // ==========================================
    { 
      provide: APP_GUARD, 
      useClass: AuthGuard 
    },
    { 
      provide: APP_GUARD, 
      useClass: PermissionsGuard 
    },
  ]
})
export class AppModule {}
