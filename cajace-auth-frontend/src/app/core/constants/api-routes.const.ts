export const API_BASE_URL = 'http://localhost:3000/v1';
export const SOCKET_URL = 'http://localhost:3000';

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
