import { IsEmail, IsNotEmpty, IsOptional, IsString, Min, MinLength } from "class-validator";

export class LoginDto {

    @IsEmail()
    @IsNotEmpty()
    email: string;

    @IsString()
    @IsNotEmpty()
    @MinLength(6)
    password: string;

    @IsString()
    @IsOptional()
    dispositivo?: string;

    @IsString()
    @IsOptional()
    ubicacion?: string;
}