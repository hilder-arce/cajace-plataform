export const API_BASE_URL = 'https://cajace-auth-backend.onrender.com/v1';
export const SOCKET_URL = 'https://cajace-auth-backend.onrender.com';

export const AUTH_ENDPOINTS = {
  LOGIN: `${API_BASE_URL}/auth/login`,
  ME: `${API_BASE_URL}/auth/me`,
  FORGOT_PASSWORD: `${API_BASE_URL}/auth/forgot-password`,
  VERIFY_CODE: `${API_BASE_URL}/auth/verify-code`,
  RESET_PASSWORD: `${API_BASE_URL}/auth/reset-password`,
  SESSIONS: `${API_BASE_URL}/auth/sessions`,
  LOGOUT: `${API_BASE_URL}/auth/logout`,
  LOGOUT_ALL: `${API_BASE_URL}/auth/logout-all`,
};

export const USERS_ENDPOINTS = {
  BASE: `${API_BASE_URL}/users`,
  ME_UPDATE: `${API_BASE_URL}/users/me/update`,
  ME_CHANGE_PASSWORD: `${API_BASE_URL}/users/me/change-password`,
};

export const ROLES_ENDPOINTS = {
  BASE: `${API_BASE_URL}/roles`,
  DELETED: `${API_BASE_URL}/roles/deleted`,
  BY_ID: (id: string) => `${API_BASE_URL}/roles/${id}`,
  RESTORE: (id: string) => `${API_BASE_URL}/roles/${id}/restore`,
  INACTIVE: (id: string) => `${API_BASE_URL}/roles/${id}/role-inactivo`,
};

export const PERMISSIONS_ENDPOINTS = {
  BASE: `${API_BASE_URL}/permissions`,
  DELETED: `${API_BASE_URL}/permissions/deleted`,
  BY_ID: (id: string) => `${API_BASE_URL}/permissions/${id}`,
  RESTORE: (id: string) => `${API_BASE_URL}/permissions/${id}/restore`,
  INACTIVE: (id: string) => `${API_BASE_URL}/permissions/${id}/permiso-inactivo`,
};

export const MODULES_ENDPOINTS = {
  BASE: `${API_BASE_URL}/modules`,
  DELETED: `${API_BASE_URL}/modules/deleted`,
  BY_ID: (id: string) => `${API_BASE_URL}/modules/${id}`,
  RESTORE: (id: string) => `${API_BASE_URL}/modules/${id}/restore`,
  INACTIVE: (id: string) => `${API_BASE_URL}/modules/${id}/modulo-inactivo`,
};

export const NOTIFICATIONS_ENDPOINTS = {
  MY_NOTIFICATIONS: `${API_BASE_URL}/notifications/mias`,
  UNREAD_COUNT: `${API_BASE_URL}/notifications/no-leidas`,
  MARK_AS_READ: (id: string) => `${API_BASE_URL}/notifications/${id}/leer`,
  MARK_ALL_AS_READ: `${API_BASE_URL}/notifications/leer-todas`,
  DELETE: (id: string) => `${API_BASE_URL}/notifications/${id}`,
};
