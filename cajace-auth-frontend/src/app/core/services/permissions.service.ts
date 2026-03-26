import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';

import { PERMISSIONS_ENDPOINTS } from '../constants/api-routes.const';
import {
  AppPermission,
  CreatePermissionPayload,
  UpdatePermissionPayload,
} from '../models/permission.models';

@Injectable({
  providedIn: 'root',
})
export class PermissionsService {
  private readonly http = inject(HttpClient);

  // ==========================================
  // [ GET ] - LISTADO DE PERMISOS ACTIVOS O INACTIVOS
  // ==========================================
  getPermissions(includeInactive = false): Observable<AppPermission[]> {
    const url = includeInactive ? PERMISSIONS_ENDPOINTS.DELETED : PERMISSIONS_ENDPOINTS.BASE;
    return this.http.get<AppPermission[]>(url, { withCredentials: true });
  }

  // ==========================================
  // [ GET ] - OBTENER UN PERMISO POR IDENTIFICADOR
  // ==========================================
  getPermissionById(id: string, inactive = false): Observable<AppPermission> {
    const url = inactive ? PERMISSIONS_ENDPOINTS.INACTIVE(id) : PERMISSIONS_ENDPOINTS.BY_ID(id);
    return this.http.get<AppPermission>(url, {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ POST ] - CREAR UN NUEVO PERMISO
  // ==========================================
  createPermission(payload: CreatePermissionPayload): Observable<AppPermission> {
    return this.http.post<AppPermission>(PERMISSIONS_ENDPOINTS.BASE, payload, {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ PATCH ] - ACTUALIZAR UN PERMISO EXISTENTE
  // ==========================================
  updatePermission(id: string, payload: UpdatePermissionPayload): Observable<AppPermission> {
    return this.http.patch<AppPermission>(PERMISSIONS_ENDPOINTS.BY_ID(id), payload, {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ DELETE ] - DESACTIVAR UN PERMISO
  // ==========================================
  deletePermission(id: string): Observable<AppPermission> {
    return this.http.delete<AppPermission>(PERMISSIONS_ENDPOINTS.BY_ID(id), {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ PATCH ] - RESTAURAR UN PERMISO INACTIVO
  // ==========================================
  restorePermission(id: string): Observable<AppPermission> {
    return this.http.patch<AppPermission>(PERMISSIONS_ENDPOINTS.RESTORE(id), {}, {
      withCredentials: true,
    });
  }
}
