import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';

import { ROLES_ENDPOINTS } from '../constants/api-routes.const';
import { CreateRolePayload, Role, UpdateRolePayload } from '../models/role.models';

@Injectable({
  providedIn: 'root',
})
export class RolesService {
  private readonly http = inject(HttpClient);

  // ==========================================
  // [ GET ] - LISTAR ROLES ACTIVOS O INACTIVOS
  // ==========================================
  getRoles(includeInactive = false): Observable<Role[]> {
    const url = includeInactive ? ROLES_ENDPOINTS.DELETED : ROLES_ENDPOINTS.BASE;
    return this.http.get<Role[]>(url, {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ GET ] - OBTENER UN ROL POR ID
  // ==========================================
  getRoleById(id: string, inactive = false): Observable<Role> {
    const url = inactive ? ROLES_ENDPOINTS.INACTIVE(id) : ROLES_ENDPOINTS.BY_ID(id);
    return this.http.get<Role>(url, { withCredentials: true });
  }

  // ==========================================
  // [ POST ] - CREAR UN NUEVO ROL
  // ==========================================
  createRole(payload: CreateRolePayload): Observable<Role> {
    return this.http.post<Role>(ROLES_ENDPOINTS.BASE, payload, { withCredentials: true });
  }

  // ==========================================
  // [ PATCH ] - ACTUALIZAR UN ROL
  // ==========================================
  updateRole(id: string, payload: UpdateRolePayload): Observable<Role> {
    return this.http.patch<Role>(ROLES_ENDPOINTS.BY_ID(id), payload, { withCredentials: true });
  }

  // ==========================================
  // [ DELETE ] - DESACTIVAR UN ROL
  // ==========================================
  deleteRole(id: string): Observable<Role> {
    return this.http.delete<Role>(ROLES_ENDPOINTS.BY_ID(id), { withCredentials: true });
  }

  // ==========================================
  // [ PATCH ] - RESTAURAR UN ROL INACTIVO
  // ==========================================
  restoreRole(id: string): Observable<Role> {
    return this.http.patch<Role>(ROLES_ENDPOINTS.RESTORE(id), {}, { withCredentials: true });
  }
}
