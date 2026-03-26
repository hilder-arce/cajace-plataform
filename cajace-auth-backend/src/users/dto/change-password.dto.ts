import { IsString, MinLength } from 'class-validator';

export class ChangePasswordDto {
  @IsString()
  @MinLength(6)
  passwordActual: string; // 👈 el usuario debe confirmar su contraseña actual

  @IsString()
  @MinLength(6)
  passwordNuevo: string;
}