import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';

export const permissionDeniedInterceptor: HttpInterceptorFn = (req, next) => {
  // ==========================================
  // [ DEPENDENCIAS ] - SERVICIOS INYECTADOS
  // ==========================================
  const router = inject(Router);

  // ==========================================
  // [ STREAM REACTIVO ] - REDIRECCION 403
  // ==========================================
  return next(req).pipe(
    catchError((error: unknown) => {
      if (
        error instanceof HttpErrorResponse &&
        error.status === 403 &&
        !router.url.startsWith('/dashboard/forbidden')
      ) {
        void router.navigate(['/dashboard/forbidden'], {
          queryParams: {
            from: router.url,
          },
        });
      }

      return throwError(() => error);
    }),
  );
};
