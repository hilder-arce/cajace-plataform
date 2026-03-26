import { Module } from '@nestjs/common';
import { PermissionsService } from './permissions.service';
import { PermissionsController } from './permissions.controller';
import { Permission, PermissionSchema } from './entities/permission.entity';
import { MongooseModule } from '@nestjs/mongoose';
import { ModuleSchema } from 'src/modules/entities/module.entity';
import { NotificationsModule } from 'src/notifications/notifications.module';
import { User, UserSchema } from 'src/users/entities/user.entity';

@Module({
  imports: [
    //REGISTRAMOS EL ESQUEMA DE PERMISO EN MONGODB
    MongooseModule.forFeature([
      { name: Permission.name, schema: PermissionSchema },
      { name: 'Module', schema: ModuleSchema },
      { name: User.name, schema: UserSchema }
    ]),
    NotificationsModule
  ],
  controllers: [PermissionsController],
  providers: [PermissionsService],
  exports: [PermissionsService], //EXPORTAMOS EL SERVICIO PARA USARLO EN OTROS MODULOS (EJ: AUTH)
})
export class PermissionsModule {}
