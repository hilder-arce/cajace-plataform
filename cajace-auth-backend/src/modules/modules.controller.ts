import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { ModulesService } from './modules.service';
import { CreateModuleDto } from './dto/create-module.dto';
import { UpdateModuleDto } from './dto/update-module.dto';
import { RequirePermission } from 'src/decorators/require-permission.decorator';

@Controller('modules')
export class ModulesController {
  constructor(private readonly modulesService: ModulesService) {}

  // ==========================================
  // [ POST ] - CREACIÓN DE NUEVOS MÓDULOS
  // ==========================================
  @Post()
  @RequirePermission('crear_modulo')
  async create(@Body() createModuleDto: CreateModuleDto) {
    return await this.modulesService.create(createModuleDto);
  }

  // ==========================================
  // [ GET ] - LISTADO GLOBAL DE MÓDULOS ACTIVOS
  // ==========================================
  @Get()
  @RequirePermission('listar_modulos')
  async findAll() {
    return await this.modulesService.findAll();
  }

  // ==========================================
  // [ GET ] - LISTADO DE MÓDULOS ELIMINADOS
  // ==========================================
  @Get('deleted')
  @RequirePermission('listar_modulos')
  async findAllDeleted() {
    return await this.modulesService.findAllInactive();
  }

  // ==========================================
  // [ GET ] - OBTENER MÓDULO POR IDENTIFICADOR
  // ==========================================
  @Get(':id')
  @RequirePermission('listar_modulos')
  async findOne(@Param('id') id: string) {
    return await this.modulesService.findOne(id);
  }

  // ==========================================
  // [ PATCH ] - ACTUALIZACIÓN DE DATOS DE MÓDULO
  // ==========================================
  @Patch(':id')
  @RequirePermission('actualizar_modulo')
  async update(@Param('id') id: string, @Body() updateModuleDto: UpdateModuleDto) {
    return await this.modulesService.update(id, updateModuleDto);
  }

  // ==========================================
  // [ DELETE ] - ELIMINACIÓN LÓGICA DE MÓDULO
  // ==========================================
  @Delete(':id')
  @RequirePermission('eliminar_modulo')
  async remove(@Param('id') id: string) {
    return await this.modulesService.remove(id);
  }

  // ==========================================
  // [ PATCH ] - RESTAURACIÓN DE MÓDULO ELIMINADO
  // ==========================================
  @Patch(':id/restore')
  @RequirePermission('eliminar_modulo')
  async restore(@Param('id') id: string) {
    return await this.modulesService.restore(id);
  }

  // ==========================================
  // [ GET ] - CONSULTA DE MÓDULO INACTIVO POR ID
  // ==========================================
  @Get(':id/modulo-inactivo')
  @RequirePermission('listar_modulos')
  async findInactiveModules(@Param('id') id: string) {
    return await this.modulesService.findOneInactive(id);
  }
}
