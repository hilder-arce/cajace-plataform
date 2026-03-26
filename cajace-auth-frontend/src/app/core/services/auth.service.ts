import { HttpClient } from '@angular/common/http';
import { inject, Injectable, signal } from '@angular/core';
import { Observable, of } from 'rxjs';
import { catchError, map, tap } from 'rxjs/operators';

import { AUTH_ENDPOINTS } from '../constants/api-routes.const';
import {
  AuthEnvelope,
  AuthUser,
  LoginRequest,
  MessageResponse,
  UserSession,
} from '../models/auth.models';

const USER_CACHE_KEY = 'cajace_auth_user';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly http = inject(HttpClient);
  private readonly userState = signal<AuthUser | null>(this.restoreUser());

  readonly currentUser = this.userState.asReadonly();

  // ==========================================
  // [ POST ] - INICIO DE SESION
  // ==========================================
  login(payload: LoginRequest): Observable<AuthUser> {
    return this.http
      .post<AuthEnvelope>(AUTH_ENDPOINTS.LOGIN, payload, { withCredentials: true })
      .pipe(
        tap((response) => this.setSession(response.data.usuario)),
        map((response) => response.data.usuario),
      );
  }

  // ==========================================
  // [ GET ] - OBTENER USUARIO AUTENTICADO
  // ==========================================
  me(): Observable<AuthUser> {
    return this.http
      .get<{ data: { usuario: AuthUser } }>(AUTH_ENDPOINTS.ME, { withCredentials: true })
      .pipe(
        tap((response) => this.setSession(response.data.usuario)),
        map((response) => response.data.usuario),
      );
  }

  // ==========================================
  // [ POST ] - SOLICITAR RECUPERACION DE PASSWORD
  // ==========================================
  forgotPassword(email: string): Observable<MessageResponse> {
    return this.http.post<MessageResponse>(
      AUTH_ENDPOINTS.FORGOT_PASSWORD,
      { email },
      { withCredentials: true },
    );
  }

  // ==========================================
  // [ POST ] - VALIDAR CODIGO DE RECUPERACION
  // ==========================================
  verifyCode(email: string, codigo: string): Observable<MessageResponse> {
    return this.http.post<MessageResponse>(
      AUTH_ENDPOINTS.VERIFY_CODE,
      { email, codigo },
      { withCredentials: true },
    );
  }

  // ==========================================
  // [ POST ] - RESTABLECER CONTRASENA
  // ==========================================
  resetPassword(email: string, codigo: string, password: string): Observable<MessageResponse> {
    return this.http.post<MessageResponse>(
      AUTH_ENDPOINTS.RESET_PASSWORD,
      { email, codigo, password },
      { withCredentials: true },
    );
  }

  // ==========================================
  // [ GET ] - OBTENER SESIONES DEL USUARIO
  // ==========================================
  mySessions(): Observable<UserSession[]> {
    return this.http.get<UserSession[]>(AUTH_ENDPOINTS.SESSIONS, { withCredentials: true });
  }

  // ==========================================
  // [ DELETE ] - REVOCAR UNA SESION ESPECIFICA
  // ==========================================
  revokeSession(sessionId: string): Observable<MessageResponse> {
    return this.http.delete<MessageResponse>(`${AUTH_ENDPOINTS.SESSIONS}/${sessionId}`, {
      withCredentials: true,
    });
  }

  // ==========================================
  // [ POST ] - CERRAR TODAS LAS SESIONES
  // ==========================================
  logoutAll(): Observable<MessageResponse> {
    return this.http.post<MessageResponse>(AUTH_ENDPOINTS.LOGOUT_ALL, {}, { withCredentials: true });
  }

  // ==========================================
  // [ POST ] - CERRAR SESION ACTUAL
  // ==========================================
  logout(): Observable<void> {
    return this.http
      .post<MessageResponse>(AUTH_ENDPOINTS.LOGOUT, {}, { withCredentials: true })
      .pipe(
        map(() => void 0),
        tap(() => this.clearSession()),
        catchError(() => {
          this.clearSession();
          return of(void 0);
        }),
      );
  }

  // ==========================================
  // [ GET ] - VALIDAR SESION EXISTENTE
  // ==========================================
  ensureSession(): Observable<boolean> {
    if (this.userState()) {
      return of(true);
    }

    return this.me().pipe(
      map(() => true),
      catchError(() => {
        this.clearSession();
        return of(false);
      }),
    );
  }

  // ==========================================
  // [ ACCIONES ] - ESTADO LOCAL DE SESION
  // ==========================================
  clearSession(): void {
    this.userState.set(null);
    localStorage.removeItem(USER_CACHE_KEY);
  }

  hasPermission(permission: string): boolean {
    const user = this.userState();
    if (!user) return false;

    return this.getPermissionSet(user).has(permission);
  }

  hasAllPermissions(permissions: string[]): boolean {
    const user = this.userState();
    if (!user) return false;

    const grantedPermissions = this.getPermissionSet(user);
    return permissions.every((permission) => grantedPermissions.has(permission));
  }

  // ==========================================
  // [ PRIVADO ] - HELPERS INTERNOS
  // ==========================================
  private setSession(user: AuthUser): void {
    this.userState.set(user);
    localStorage.setItem(USER_CACHE_KEY, JSON.stringify(user));
  }

  private restoreUser(): AuthUser | null {
    const cached = localStorage.getItem(USER_CACHE_KEY);
    if (!cached) return null;

    try {
      return JSON.parse(cached) as AuthUser;
    } catch {
      localStorage.removeItem(USER_CACHE_KEY);
      return null;
    }
  }

  private getPermissionSet(user: AuthUser): Set<string> {
    const allPermissions = new Set<string>();

    if (user.permisos) {
      Object.values(user.permisos).forEach((perms) => {
        if (Array.isArray(perms)) {
          perms.forEach((permission) => allPermissions.add(permission));
        }
      });
    }

    return allPermissions;
  }
}
