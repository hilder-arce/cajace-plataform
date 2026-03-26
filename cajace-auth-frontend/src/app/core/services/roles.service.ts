import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';

import { CreateRolePayload, Role, UpdateRolePayload } from '../models/role.models';

const API_BASE_URL = 'http://localhost:3000/v1';

@Injectable({
  providedIn: 'root',
})
export class RolesService {
  private readonly http = inject(HttpClient);

  // ==========================================
  // [ GET ] - LISTAR ROLES ACTIVOS O INACTIVOS
  // ==========================================
  getRoles(includeInactive = false): Observable<Role[]> {
    const endpoint = includeInactive ? 'deleted' : '';
    const url = endpoint ? `${API_BASE_URL}/roles/${endpoint}` : `${API_BASE_URL}/roles`;
    return this.http.get<Role[]>(url, {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ GET ] - OBTENER UN ROL POR ID
  // ==========================================
  getRoleById(id: string, inactive = false): Observable<Role> {
    const suffix = inactive ? '/role-inactivo' : '';
    return this.http.get<Role>(`${API_BASE_URL}/roles/${id}${suffix}`, { withCredentials: true });
  }

  // ==========================================
  // [ POST ] - CREAR UN NUEVO ROL
  // ==========================================
  createRole(payload: CreateRolePayload): Observable<Role> {
    return this.http.post<Role>(`${API_BASE_URL}/roles`, payload, { withCredentials: true });
  }

  // ==========================================
  // [ PATCH ] - ACTUALIZAR UN ROL
  // ==========================================
  updateRole(id: string, payload: UpdateRolePayload): Observable<Role> {
    return this.http.patch<Role>(`${API_BASE_URL}/roles/${id}`, payload, { withCredentials: true });
  }

  // ==========================================
  // [ DELETE ] - DESACTIVAR UN ROL
  // ==========================================
  deleteRole(id: string): Observable<Role> {
    return this.http.delete<Role>(`${API_BASE_URL}/roles/${id}`, { withCredentials: true });
  }

  // ==========================================
  // [ PATCH ] - RESTAURAR UN ROL INACTIVO
  // ==========================================
  restoreRole(id: string): Observable<Role> {
    return this.http.patch<Role>(`${API_BASE_URL}/roles/${id}/restore`, {}, { withCredentials: true });
  }
}
