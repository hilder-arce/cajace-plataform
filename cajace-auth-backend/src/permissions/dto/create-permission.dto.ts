import { IsMongoId, IsNotEmpty, IsString } from "class-validator";

export class CreatePermissionDto {

  @IsString()
  @IsNotEmpty()
  nombre: string;

  @IsString()
  @IsNotEmpty()
  descripcion: string;

  @IsMongoId()
  @IsNotEmpty()
  modulo: string;

}
