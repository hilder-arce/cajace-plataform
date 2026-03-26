import { Module } from '@nestjs/common';
import { ModulesService } from './modules.service';
import { ModulesController } from './modules.controller';
import { MongooseModule } from '@nestjs/mongoose';
import { ModuleSchema } from './entities/module.entity';
import { PermissionsModule } from 'src/permissions/permissions.module';

@Module({
  imports: [
    //REGISTRAMOS EL ESQUEMA DE MODULO EN MONGODB
    MongooseModule.forFeature([
      { name: 'Module', schema: ModuleSchema },
    ]),
    PermissionsModule
  ],
  controllers: [ModulesController],
  providers: [ModulesService],
  exports: [ModulesService], //EXPORTAMOS EL SERVICIO PARA USARLO EN OTROS MODULOS (EJ: AUTH)
})
export class ModulesModule {}
