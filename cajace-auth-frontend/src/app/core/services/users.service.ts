import { HttpClient, HttpParams } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';

import { USERS_ENDPOINTS } from '../constants/api-routes.const';
import {
  User,
  UserFormData,
  UserPasswordPayload,
  UsersListResponse,
} from '../models/user.models';

@Injectable({
  providedIn: 'root',
})
export class UsersService {
  private readonly http = inject(HttpClient);

  // ==========================================
  // [ GET ] - LISTAR USUARIOS PAGINADOS
  // ==========================================
  getUsers(
    page = 1,
    limit = 10,
    search = '',
    includeInactive = false,
  ): Observable<UsersListResponse> {
    const endpoint = includeInactive ? 'inactivos' : '';
    const params = new HttpParams()
      .set('page', page)
      .set('limit', limit)
      .set('search', search);

    return this.http.get<UsersListResponse>(`${USERS_ENDPOINTS.BASE}/${endpoint}`, {
      withCredentials: true,
      params,
    });
  }

  // ==========================================
  // [ GET ] - OBTENER UN USUARIO POR ID
  // ==========================================
  getUserById(id: string): Observable<User> {
    return this.http.get<User>(`${USERS_ENDPOINTS.BASE}/${id}`, { withCredentials: true });
  }

  // ==========================================
  // [ POST ] - CREAR UN NUEVO USUARIO
  // ==========================================
  createUser(data: UserFormData): Observable<User> {
    return this.http.post<User>(USERS_ENDPOINTS.BASE, data, { withCredentials: true });
  }

  // ==========================================
  // [ PATCH ] - ACTUALIZAR UN USUARIO
  // ==========================================
  updateUser(id: string, data: Partial<UserFormData>): Observable<User> {
    return this.http.patch<User>(`${USERS_ENDPOINTS.BASE}/${id}`, data, { withCredentials: true });
  }

  // ==========================================
  // [ PATCH ] - ACTUALIZAR EL PERFIL DEL USUARIO ACTUAL
  // ==========================================
  updateMe(data: Partial<UserFormData>): Observable<User> {
    return this.http.patch<User>(USERS_ENDPOINTS.ME_UPDATE, data, { withCredentials: true });
  }

  // ==========================================
  // [ PATCH ] - CAMBIAR LA CONTRASEÑA DEL USUARIO ACTUAL
  // ==========================================
  changeMyPassword(data: UserPasswordPayload): Observable<void> {
    return this.http.patch<void>(USERS_ENDPOINTS.ME_CHANGE_PASSWORD, data, { withCredentials: true });
  }

  // ==========================================
  // [ PATCH ] - CAMBIAR LA CONTRASEÑA DE UN USUARIO
  // ==========================================
  changePassword(id: string, data: UserPasswordPayload): Observable<void> {
    return this.http.patch<void>(`${USERS_ENDPOINTS.BASE}/${id}/change-password`, data, {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ PATCH ] - CAMBIAR LA CONTRASEÃ‘A DE UN USUARIO (ADMIN)
  // ==========================================
  adminChangePassword(id: string, passwordNuevo: string): Observable<void> {
    return this.http.patch<void>(`${USERS_ENDPOINTS.BASE}/${id}/admin-change-password`, { passwordNuevo }, {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ DELETE ] - DESACTIVAR UN USUARIO
  // ==========================================
  deleteUser(id: string): Observable<void> {
    return this.http.delete<void>(`${USERS_ENDPOINTS.BASE}/${id}`, { withCredentials: true });
  }

  // ==========================================
  // [ PATCH ] - RESTAURAR UN USUARIO INACTIVO
  // ==========================================
  restoreUser(id: string): Observable<void> {
    return this.http.patch<void>(`${USERS_ENDPOINTS.BASE}/${id}/restore`, {}, { withCredentials: true });
  }
}
