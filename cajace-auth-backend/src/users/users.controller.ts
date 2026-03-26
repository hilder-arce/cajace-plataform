import { Controller, Get, Post, Body, Patch, Param, Delete, Req, Query, ForbiddenException } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { AdminChangePasswordDto } from './dto/admin-change-password.dto';
import { RequirePermission } from 'src/decorators/require-permission.decorator';
import type { Request } from 'express';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  // ==========================================
  // [ POST ] - CREACIÓN DE NUEVOS USUARIOS
  // ==========================================
  @Post()
  @RequirePermission('crear_usuario')
  async create(@Body() createUserDto: CreateUserDto, @Req() req: Request) {
    const authenticatedUser = req['user'];
    return await this.usersService.create(createUserDto, authenticatedUser.nombre);
  }

  // ==========================================
  // [ GET ] - LISTADO GLOBAL DE USUARIOS
  // ==========================================
  @Get()
  @RequirePermission('listar_usuarios')
  async findAll(
    @Query('page') page: string,
    @Query('limit') limit: string,
    @Query('search') search: string
  ) {
    return await this.usersService.findAll(+page || 1, +limit || 10, search || '');
  }

  // ==========================================
  // [ GET ] - LISTADO DE USUARIOS INACTIVOS
  // ==========================================
  @Get('inactivos')
  @RequirePermission('listar_usuarios')
  async findAllInactive(
    @Query('page') page: string,
    @Query('limit') limit: string,
    @Query('search') search: string
  ) {
    return await this.usersService.findAllInactive(+page || 1, +limit || 10, search || '');
  }

  // ==========================================
  // [ GET ] - OBTENER USUARIO POR IDENTIFICADOR
  // ==========================================
  @Get(':id')
  @RequirePermission('listar_usuarios')
  async findOne(@Param('id') id: string) {
    return await this.usersService.findOne(id);
  }

  // ==========================================
  // [ GET ] - OBTENER USUARIO INACTIVO POR ID
  // ==========================================
  @Get('inactivos/:id')
  @RequirePermission('listar_usuarios')
  async findOneInactive(@Param('id') id: string) {
    return await this.usersService.findOneInactive(id);
  }

  // ==========================================
  // [ PATCH ] - ACTUALIZACIÓN DE DATOS (PROPIO)
  // ==========================================
  @Patch('me/update')
  async updateMe(@Req() req: Request, @Body() updateUserDto: UpdateUserDto) {
    const user = req['user'];
    return await this.usersService.updateOwnProfile(user.sub, updateUserDto);
  }

  // ==========================================
  // [ PATCH ] - CAMBIO DE CONTRASEÑA (PROPIO)
  // ==========================================
  @Patch('me/change-password')
  async changeMyPassword(@Req() req: Request, @Body() dto: ChangePasswordDto) {
    const user = req['user'];
    return await this.usersService.changePassword(user.sub, dto);
  }

  // ==========================================
  // [ PATCH ] - ACTUALIZACIÓN DE DATOS DE USUARIO (ADMIN)
  // ==========================================
  @Patch(':id')
  @RequirePermission('actualizar_usuario')
  async update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto, @Req() req: Request) {
    const authenticatedUser = req['user'];
    return await this.usersService.update(id, updateUserDto, authenticatedUser?.nombre);
  }

  // ==========================================
  // [ PATCH ] - RESTAURACIÓN DE USUARIO ELIMINADO
  // ==========================================
  @Patch(':id/restore')
  @RequirePermission('eliminar_usuario')
  async restore(@Param('id') id: string) {
    return await this.usersService.reactivate(id);
  }

  // ==========================================
  // [ DELETE ] - ELIMINACIÓN LÓGICA DE USUARIO
  // ==========================================
  @Delete(':id')
  @RequirePermission('eliminar_usuario')
  async remove(@Param('id') id: string) {
    return await this.usersService.remove(id);
  }

  // ==========================================
  // [ PATCH ] - CAMBIO DE CONTRASEÑA (PROPIO)
  // ==========================================
  @Patch(':id/change-password')
  async changePassword(@Param('id') id: string, @Body() dto: ChangePasswordDto, @Req() req: Request) {
    const authenticatedUser = req['user'];
    if (authenticatedUser?.sub !== id) {
      throw new ForbiddenException('Solo puedes cambiar tu propia contraseÃ±a desde esta ruta');
    }
    return await this.usersService.changePassword(id, dto);
  }

  // ==========================================
  // [ PATCH ] - CAMBIO DE CONTRASEÑA (ADMINISTRADOR)
  // ==========================================
  @Patch(':id/admin-change-password')
  @RequirePermission('cambiar_password')
  async adminChangePassword(@Param('id') id: string, @Body() dto: AdminChangePasswordDto, @Req() req: Request) {
    const authenticatedUser = req['user'];
    if (authenticatedUser?.rol !== 'Administrador') {
      throw new ForbiddenException('Solo un administrador puede cambiar la contraseÃ±a de otro usuario');
    }
    return await this.usersService.adminChangePassword(id, dto);
  }
}
