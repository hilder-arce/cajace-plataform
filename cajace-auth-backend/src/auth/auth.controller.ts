import { Controller, Get, Post, Body, Param, Delete, Req, Res } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { VerifyCodeDto } from './dto/verify-code.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { Public } from 'src/decorators/public.decorator';
import type { Request, Response } from 'express';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  // ==========================================
  // [ POST ] - AUTENTICACIÓN Y LOGIN
  // ==========================================
  @Public()
  @Post('login')
  async login(@Body() dto: LoginDto, @Req() req: Request, @Res() res: Response) {
    return await this.authService.login(dto, req, res);
  }

  // ==========================================
  // [ POST ] - CIERRE DE SESIÓN ACTUAL
  // ==========================================
  @Post('logout')
  async logout(@Req() req: Request, @Res() res: Response) {
    return await this.authService.logout(req, res);
  }

  // ==========================================
  // [ POST ] - CIERRE DE TODAS LAS SESIONES
  // ==========================================
  @Post('logout-all')
  async logoutAll(@Req() req: Request, @Res() res: Response) {
    const usuarioId = (req as any).user?.sub;
    return await this.authService.logoutAll(usuarioId, res);
  }

  // ==========================================
  // [ GET ] - PERFIL DEL USUARIO AUTENTICADO
  // ==========================================
  @Get('me')
  async me(@Req() req: Request) {
    const usuarioId = (req as any).user?.sub;
    return await this.authService.me(usuarioId);
  }

  // ==========================================
  // [ GET ] - SESIONES ACTIVAS DEL USUARIO
  // ==========================================
  @Get('sessions')
  async mySessions(@Req() req: Request) {
    const usuarioId = (req as any).user?.sub;
    return await this.authService.mySessions(usuarioId);
  }
  
  // ==========================================
  // [ GET ] - TODAS LAS SESIONES DEL SISTEMA (ADMIN)
  // ==========================================
  @Get('sessions/all')
  async allSessions() {
    return await this.authService.allSessions();
  }

  // ==========================================
  // [ DELETE ] - REVOCACIÓN DE SESIÓN ESPECÍFICA
  // ==========================================
  @Delete('sessions/:id')
  async revokeSession(
    @Param('id') id: string, 
    @Req() req: Request, 
    @Res() res: Response
  ) {
    const usuarioId = (req as any).user?.sub;
    const esAdmin = (req as any).user?.rol === 'Administrador';
    return await this.authService.revokeSession(id, usuarioId, esAdmin, req, res);
  }

  // ==========================================
  // [ POST ] - GESTIÓN DE OLVIDO DE CONTRASEÑA
  // ==========================================
  @Public()
  @Post('forgot-password')
  async forgotPassword(@Body() dto: ForgotPasswordDto) {
    return await this.authService.forgotPassword(dto);
  }

  // ==========================================
  // [ POST ] - VERIFICACIÓN DE CÓDIGO DE RECUPERACIÓN
  // ==========================================
  @Public()
  @Post('verify-code')
  async verifyCode(@Body() dto: VerifyCodeDto) {
    return await this.authService.verifyCode(dto);
  }

  // ==========================================
  // [ POST ] - RESTABLECIMIENTO DE CONTRASEÑA
  // ==========================================
  @Public()
  @Post('reset-password')
  async resetPassword(@Body() dto: ResetPasswordDto) {
    return await this.authService.resetPassword(dto);
  }
}
