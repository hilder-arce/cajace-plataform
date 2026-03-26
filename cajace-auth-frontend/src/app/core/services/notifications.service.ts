import { inject, Injectable, signal } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { io, Socket } from 'socket.io-client';
import { Observable, Subject, tap } from 'rxjs';
import { Notification, RolePermissionsUpdatedEvent, UnreadCountResponse } from '../models/notification.models';
import { API_BASE_URL, SOCKET_URL } from '../constants/api-routes.const';

export interface PaginatedNotifications {
  items: Notification[];
  total: number;
  page: number;
  pages: number;
}

@Injectable({ providedIn: 'root' })
export class NotificationsService {
  private readonly http = inject(HttpClient);
  private socket: Socket | null = null;
  private readonly _logoutSubject = new Subject<void>();
  private readonly _updateSessionsSubject = new Subject<void>();
  private readonly _liveNotificationSubject = new Subject<Notification>();
  private readonly _rolePermissionsUpdatedSubject = new Subject<RolePermissionsUpdatedEvent>();

  // Estados reactivos (Signals)
  private readonly _notifications = signal<Notification[]>([]);
  private readonly _unreadCount = signal<number>(0);

  readonly notifications = this._notifications.asReadonly();
  readonly unreadCount = this._unreadCount.asReadonly();
  readonly logout$ = this._logoutSubject.asObservable();
  readonly updateSessions$ = this._updateSessionsSubject.asObservable();
  readonly liveNotification$ = this._liveNotificationSubject.asObservable();
  readonly rolePermissionsUpdated$ = this._rolePermissionsUpdatedSubject.asObservable();

  connect(): void {
    if (this.socket?.connected) return;

    this.socket = io(SOCKET_URL, {
      withCredentials: true,
      transports: ['websocket', 'polling'], // Fallback a polling si websocket falla
    });

    this.socket.on('notification', (notif: Notification) => {
      // Si recibimos una nueva por socket, la agregamos al inicio de la lista local
      this._notifications.update(list => [notif, ...list]);
      this._unreadCount.update(count => count + 1);
      this._liveNotificationSubject.next(notif);
    });

    this.socket.on('logout_session', () => {
      this._logoutSubject.next();
    });

    this.socket.on('update_sessions', () => {
      this._updateSessionsSubject.next();
    });

    this.socket.on('role_permissions_updated', (payload: RolePermissionsUpdatedEvent) => {
      this._rolePermissionsUpdatedSubject.next(payload);
    });

    // Cargar las notificaciones iniciales (las 10 más recientes) al conectar
    this.getNotifications(1, 10).subscribe(res => {
      this._notifications.set(res.items);
    });

    this.getUnreadCount().subscribe(res => this._unreadCount.set(res.total));
  }

  disconnect(): void {
    this.socket?.disconnect();
    this.socket = null;
  }

  // --- MÉTODOS HTTP CON PAGINACIÓN Y BÚSQUEDA ---

  getNotifications(page = 1, limit = 10, search = ''): Observable<PaginatedNotifications> {
    let params = new HttpParams()
      .set('page', page.toString())
      .set('limit', limit.toString());
    
    if (search) {
      params = params.set('search', search);
    }

    return this.http.get<PaginatedNotifications>(`${API_BASE_URL}/notifications/mias`, { 
      params, 
      withCredentials: true 
    });
  }

  getUnreadCount(): Observable<UnreadCountResponse> {
    return this.http.get<UnreadCountResponse>(`${API_BASE_URL}/notifications/no-leidas`, { withCredentials: true });
  }

  markAsRead(id: string): Observable<void> {
    return this.http.patch<void>(`${API_BASE_URL}/notifications/${id}/leer`, {}, { withCredentials: true }).pipe(
      tap(() => {
        this._unreadCount.update(count => Math.max(0, count - 1));
        this._notifications.update(list => list.map(n => n._id === id ? { ...n, leida: true } : n));
      })
    );
  }

  markMultipleAsRead(ids: string[]): void {
    if (!ids || ids.length === 0) return;
    
    // Ejecutar todas las peticiones en paralelo
    ids.forEach(id => {
      this.markAsRead(id).subscribe();
    });
  }

  markAllAsRead(): Observable<void> {
    return this.http.patch<void>(`${API_BASE_URL}/notifications/leer-todas`, {}, { withCredentials: true }).pipe(
      tap(() => {
        this._unreadCount.set(0);
        this._notifications.update(list => list.map(n => ({ ...n, leida: true })));
      })
    );
  }

  delete(id: string): Observable<void> {
    return this.http.delete<void>(`${API_BASE_URL}/notifications/${id}`, { withCredentials: true });
  }
}

