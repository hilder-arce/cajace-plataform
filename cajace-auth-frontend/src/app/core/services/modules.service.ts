import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';

import {
  AppModuleItem,
  CreateModulePayload,
  UpdateModulePayload,
} from '../models/module.models';

const API_BASE_URL = 'http://localhost:3000/v1';

@Injectable({
  providedIn: 'root',
})
export class ModulesService {
  private readonly http = inject(HttpClient);

  // ==========================================
  // [ GET ] - LISTADO DE MODULOS ACTIVOS O INACTIVOS
  // ==========================================
  getModules(includeInactive = false): Observable<AppModuleItem[]> {
    const endpoint = includeInactive ? 'deleted' : '';
    const url = endpoint ? `${API_BASE_URL}/modules/${endpoint}` : `${API_BASE_URL}/modules`;
    return this.http.get<AppModuleItem[]>(url, { withCredentials: true });
  }

  // ==========================================
  // [ GET ] - OBTENER UN MODULO POR IDENTIFICADOR
  // ==========================================
  getModuleById(id: string, inactive = false): Observable<AppModuleItem> {
    const suffix = inactive ? '/modulo-inactivo' : '';
    return this.http.get<AppModuleItem>(`${API_BASE_URL}/modules/${id}${suffix}`, {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ POST ] - CREAR UN NUEVO MODULO
  // ==========================================
  createModule(payload: CreateModulePayload): Observable<AppModuleItem> {
    return this.http.post<AppModuleItem>(`${API_BASE_URL}/modules`, payload, {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ PATCH ] - ACTUALIZAR UN MODULO EXISTENTE
  // ==========================================
  updateModule(id: string, payload: UpdateModulePayload): Observable<AppModuleItem> {
    return this.http.patch<AppModuleItem>(`${API_BASE_URL}/modules/${id}`, payload, {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ DELETE ] - DESACTIVAR UN MODULO
  // ==========================================
  deleteModule(id: string): Observable<AppModuleItem> {
    return this.http.delete<AppModuleItem>(`${API_BASE_URL}/modules/${id}`, {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ PATCH ] - RESTAURAR UN MODULO INACTIVO
  // ==========================================
  restoreModule(id: string): Observable<AppModuleItem> {
    return this.http.patch<AppModuleItem>(`${API_BASE_URL}/modules/${id}/restore`, {}, {
      withCredentials: true,
    });
  }
}
