import { IsArray, IsMongoId, IsNotEmpty, IsOptional, IsString } from "class-validator";

export class CreateRoleDto {

    @IsString()
    @IsNotEmpty()
    nombre: string;

    @IsString()
    @IsNotEmpty()
    descripcion: string;

    @IsArray()
    @IsMongoId({ each: true })
    @IsOptional()
    permisos?: string[]; //ARRAY DE IDS DE PERMISOS QUE PERTENECEN A ESTE ROL

}
