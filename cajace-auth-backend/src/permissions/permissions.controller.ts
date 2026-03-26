import { Controller, Get, Post, Body, Patch, Param, Delete, Req } from '@nestjs/common';
import { PermissionsService } from './permissions.service';
import { CreatePermissionDto } from './dto/create-permission.dto';
import { UpdatePermissionDto } from './dto/update-permission.dto';
import { RequirePermission } from 'src/decorators/require-permission.decorator';
import type { Request } from 'express';

@Controller('permissions')
export class PermissionsController {
  constructor(private readonly permissionsService: PermissionsService) {}

  // ==========================================
  // [ POST ] - CREACIÓN DE NUEVOS PERMISOS
  // ==========================================
  @Post()
  @RequirePermission('crear_permiso')
  async create(@Body() createPermissionDto: CreatePermissionDto, @Req() req: Request) {
    const usuarioAutenticado = req['user'];
    return await this.permissionsService.create(createPermissionDto, usuarioAutenticado);
  }

  // ==========================================
  // [ GET ] - LISTADO GLOBAL DE PERMISOS
  // ==========================================
  @Get()
  @RequirePermission('listar_permisos')
  async findAll() {
    return await this.permissionsService.findAll();
  }

  // ==========================================
  // [ GET ] - LISTADO DE PERMISOS ELIMINADOS
  // ==========================================
  @Get('deleted')
  @RequirePermission('listar_permisos')
  async findAllDeleted() {
    return await this.permissionsService.findAllInactive();
  }

  // ==========================================
  // [ GET ] - OBTENER PERMISO POR IDENTIFICADOR
  // ==========================================
  @Get(':id')
  @RequirePermission('listar_permisos')
  async findOne(@Param('id') id: string) {
    return await this.permissionsService.findOne(id);
  }

  // ==========================================
  // [ PATCH ] - ACTUALIZACIÓN DE DATOS DE PERMISO
  // ==========================================
  @Patch(':id')
  @RequirePermission('actualizar_permisos')
  async update(@Param('id') id: string, @Body() updatePermissionDto: UpdatePermissionDto) {
    return await this.permissionsService.update(id, updatePermissionDto);
  }

  // ==========================================
  // [ DELETE ] - ELIMINACIÓN LÓGICA DE PERMISO
  // ==========================================
  @Delete(':id')
  @RequirePermission('eliminar_permiso')
  async remove(@Param('id') id: string) {
    return await this.permissionsService.remove(id);
  }

  // ==========================================
  // [ PATCH ] - RESTAURACIÓN DE PERMISO ELIMINADO
  // ==========================================
  @Patch(':id/restore')
  @RequirePermission('eliminar_permiso')
  async restore(@Param('id') id: string) {
    return await this.permissionsService.restore(id);
  }

  // ==========================================
  // [ GET ] - CONSULTA DE PERMISOS INACTIVOS POR ID
  // ==========================================
  @Get(':id/permiso-inactivo')
  @RequirePermission('listar_permisos')
  async findInactivePermissions(@Param('id') id: string) {
    return await this.permissionsService.findOneInactive(id);
  }
}
