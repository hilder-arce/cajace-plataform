import { IsOptional, IsString } from "class-validator";

export class UpdatePermissionDto {

  @IsOptional()
  @IsString()
  nombre?: string;

  @IsOptional()
  @IsString()
  descripcion?: string;

}
