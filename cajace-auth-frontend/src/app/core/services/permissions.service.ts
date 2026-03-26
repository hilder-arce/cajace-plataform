import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';

import {
  AppPermission,
  CreatePermissionPayload,
  UpdatePermissionPayload,
} from '../models/permission.models';

const API_BASE_URL = 'http://localhost:3000/v1';

@Injectable({
  providedIn: 'root',
})
export class PermissionsService {
  private readonly http = inject(HttpClient);

  // ==========================================
  // [ GET ] - LISTADO DE PERMISOS ACTIVOS O INACTIVOS
  // ==========================================
  getPermissions(includeInactive = false): Observable<AppPermission[]> {
    const endpoint = includeInactive ? 'deleted' : '';
    const url = endpoint ? `${API_BASE_URL}/permissions/${endpoint}` : `${API_BASE_URL}/permissions`;
    return this.http.get<AppPermission[]>(url, { withCredentials: true });
  }

  // ==========================================
  // [ GET ] - OBTENER UN PERMISO POR IDENTIFICADOR
  // ==========================================
  getPermissionById(id: string, inactive = false): Observable<AppPermission> {
    const suffix = inactive ? '/permiso-inactivo' : '';
    return this.http.get<AppPermission>(`${API_BASE_URL}/permissions/${id}${suffix}`, {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ POST ] - CREAR UN NUEVO PERMISO
  // ==========================================
  createPermission(payload: CreatePermissionPayload): Observable<AppPermission> {
    return this.http.post<AppPermission>(`${API_BASE_URL}/permissions`, payload, {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ PATCH ] - ACTUALIZAR UN PERMISO EXISTENTE
  // ==========================================
  updatePermission(id: string, payload: UpdatePermissionPayload): Observable<AppPermission> {
    return this.http.patch<AppPermission>(`${API_BASE_URL}/permissions/${id}`, payload, {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ DELETE ] - DESACTIVAR UN PERMISO
  // ==========================================
  deletePermission(id: string): Observable<AppPermission> {
    return this.http.delete<AppPermission>(`${API_BASE_URL}/permissions/${id}`, {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ PATCH ] - RESTAURAR UN PERMISO INACTIVO
  // ==========================================
  restorePermission(id: string): Observable<AppPermission> {
    return this.http.patch<AppPermission>(`${API_BASE_URL}/permissions/${id}/restore`, {}, {
      withCredentials: true,
    });
  }
}
