import { Controller, Get, Post, Body, Patch, Param, Delete, Req } from '@nestjs/common';
import { RolesService } from './roles.service';
import { CreateRoleDto } from './dto/create-role.dto';
import { UpdateRoleDto } from './dto/update-role.dto';
import { RequirePermission } from 'src/decorators/require-permission.decorator';
import type { Request } from 'express';

@Controller('roles')
export class RolesController {
  constructor(private readonly rolesService: RolesService) {}

  // ==========================================
  // [ POST ] - CREACIÓN DE NUEVOS ROLES
  // ==========================================
  @Post()
  @RequirePermission('crear_rol')
  async create(@Body() createRoleDto: CreateRoleDto, @Req() req: Request) {
    const userAuth = req['user'];
    return await this.rolesService.create(createRoleDto, userAuth);
  }

  // ==========================================
  // [ GET ] - LISTADO GLOBAL DE ROLES ACTIVOS
  // ==========================================
  @Get()
  @RequirePermission('listar_roles')
  async findAll() {
    return await this.rolesService.findAll();
  }

  // ==========================================
  // [ GET ] - LISTADO DE ROLES ELIMINADOS
  // ==========================================
  @Get('deleted')
  @RequirePermission('listar_roles')
  async findAllDeleted() {
    return await this.rolesService.findAllInactive();
  }

  // ==========================================
  // [ GET ] - OBTENER ROL POR IDENTIFICADOR
  // ==========================================
  @Get(':id')
  @RequirePermission('listar_roles')
  async findOne(@Param('id') id: string) {
    return await this.rolesService.findOne(id);
  }

  // ==========================================
  // [ PATCH ] - ACTUALIZACIÓN DE DATOS DE ROL
  // ==========================================
  @Patch(':id')
  @RequirePermission('actualizar_rol')
  async update(@Param('id') id: string, @Body() updateRoleDto: UpdateRoleDto, @Req() req: Request) {
    return await this.rolesService.update(id, updateRoleDto, req['user']?.nombre ?? 'Sistema');
  }

  // ==========================================
  // [ DELETE ] - ELIMINACIÓN LÓGICA DE ROL
  // ==========================================
  @Delete(':id')
  @RequirePermission('eliminar_rol')
  async remove(@Param('id') id: string) {
    return await this.rolesService.remove(id);
  }

  // ==========================================
  // [ PATCH ] - RESTAURACIÓN DE ROL ELIMINADO
  // ==========================================
  @Patch(':id/restore')
  @RequirePermission('eliminar_rol')
  async restore(@Param('id') id: string) {
    return await this.rolesService.restore(id);
  }

  // ==========================================
  // [ GET ] - CONSULTA DE ROLES INACTIVOS POR ID
  // ==========================================
  @Get(':id/role-inactivo')
  @RequirePermission('listar_roles')
  async findInactivePermissions(@Param('id') id: string) {
    return await this.rolesService.findOneInactive(id);
  }
}
