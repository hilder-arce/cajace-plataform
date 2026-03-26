import { IsNotEmpty, IsString } from "class-validator";

export class CreateModuleDto {

    @IsString()
    @IsNotEmpty()
    nombre: string;

    @IsString()
    @IsNotEmpty()
    descripcion: string;
}
