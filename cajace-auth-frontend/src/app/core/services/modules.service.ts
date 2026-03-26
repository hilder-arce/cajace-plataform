import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';

import { MODULES_ENDPOINTS } from '../constants/api-routes.const';
import {
  AppModuleItem,
  CreateModulePayload,
  UpdateModulePayload,
} from '../models/module.models';

@Injectable({
  providedIn: 'root',
})
export class ModulesService {
  private readonly http = inject(HttpClient);

  // ==========================================
  // [ GET ] - LISTADO DE MODULOS ACTIVOS O INACTIVOS
  // ==========================================
  getModules(includeInactive = false): Observable<AppModuleItem[]> {
    const url = includeInactive ? MODULES_ENDPOINTS.DELETED : MODULES_ENDPOINTS.BASE;
    return this.http.get<AppModuleItem[]>(url, { withCredentials: true });
  }

  // ==========================================
  // [ GET ] - OBTENER UN MODULO POR IDENTIFICADOR
  // ==========================================
  getModuleById(id: string, inactive = false): Observable<AppModuleItem> {
    const url = inactive ? MODULES_ENDPOINTS.INACTIVE(id) : MODULES_ENDPOINTS.BY_ID(id);
    return this.http.get<AppModuleItem>(url, {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ POST ] - CREAR UN NUEVO MODULO
  // ==========================================
  createModule(payload: CreateModulePayload): Observable<AppModuleItem> {
    return this.http.post<AppModuleItem>(MODULES_ENDPOINTS.BASE, payload, {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ PATCH ] - ACTUALIZAR UN MODULO EXISTENTE
  // ==========================================
  updateModule(id: string, payload: UpdateModulePayload): Observable<AppModuleItem> {
    return this.http.patch<AppModuleItem>(MODULES_ENDPOINTS.BY_ID(id), payload, {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ DELETE ] - DESACTIVAR UN MODULO
  // ==========================================
  deleteModule(id: string): Observable<AppModuleItem> {
    return this.http.delete<AppModuleItem>(MODULES_ENDPOINTS.BY_ID(id), {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ PATCH ] - RESTAURAR UN MODULO INACTIVO
  // ==========================================
  restoreModule(id: string): Observable<AppModuleItem> {
    return this.http.patch<AppModuleItem>(MODULES_ENDPOINTS.RESTORE(id), {}, {
      withCredentials: true,
    });
  }
}
