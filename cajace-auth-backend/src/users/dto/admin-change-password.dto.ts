import { IsString, MinLength } from 'class-validator';

export class AdminChangePasswordDto {
  @IsString()
  @MinLength(6)
  passwordNuevo: string; // 👈 admin no necesita saber la contraseña actual
}