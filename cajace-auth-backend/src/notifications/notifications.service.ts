import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Resend } from 'resend';

import { Notification } from './entities/notification.entity';
import { User } from 'src/users/entities/user.entity';
import { NotificationsGateway } from './notifications.gateway';
import { NotifyPayload } from './interfaces/notify.interface';

import { loginTemplate } from './templates/login.template';
import { newUserTemplate } from './templates/new-user.template';
import { revokeSessionTemplate } from './templates/revoke-session.template';
import { changePasswordTemplate } from './templates/change-password.template';
import { verifyCodeTemplate } from './templates/verify-code.template';

@Injectable()
export class NotificationsService {
  private readonly resend: Resend;
  private readonly from = 'CAJACE SYSTEMS <notificaciones@hilderarce.com>';//DEBE SER CAMBIADO EN PRODUCCIÓN POR UNA DIRECCIÓN VÁLIDA Y VERIFICADA EN RESEND

  constructor(
    @InjectModel(Notification.name) private readonly notificationModel: Model<Notification>,
    @InjectModel(User.name) private readonly userModel: Model<User>,  
    private readonly configService: ConfigService,
    private readonly gateway: NotificationsGateway,
  ) {
    this.resend = new Resend(this.configService.get('RESEND_API_KEY'));
  }

  // ======================================================
  // [ CORE ] - PROCESADOR CENTRAL DE NOTIFICACIONES
  // ======================================================
  private async notify(usuarioId: string, payload: NotifyPayload) {
    // 1. PERSISTENCIA EN BASE DE DATOS
    const notification = await this.notificationModel.create({
      usuario: new Types.ObjectId(usuarioId),
      tipo: payload.tipo,
      titulo: payload.titulo,
      mensaje: payload.mensaje,
      data: payload.data ?? {}
    });

    // 2. EMISIÓN EN TIEMPO REAL VÍA WEBSOCKETS
    this.gateway.emitToUser(usuarioId, 'notification', {
      _id: notification._id,
      tipo: notification.tipo,
      titulo: notification.titulo,
      mensaje: notification.mensaje,
      data: notification.data,
      leida: notification.leida,
      createdAt: notification.createdAt,
    });

    // 3. DESPACHO DE CORREO ELECTRÓNICO (SI APLICA)
    if (payload.email) {
      const user = await this.userModel.findById(usuarioId).select('email').exec();
      if (user?.email) {
        await this.enviarEmail(user.email, payload.email.subject, payload.email.html);
      }
    }

    return notification;
  }

  // ======================================================
  // [ CORE ] - NOTIFICACIONES MASIVAS A GRUPOS
  // ======================================================
  private async notifyMany(usuarioIds: string[], payload: NotifyPayload) {
    await Promise.all(usuarioIds.map(id => this.notify(id, payload)));
  }

  // ======================================================
  // [ HELPERS ] - UTILIDADES DE SEGURIDAD Y COMUNICACIÓN
  // ======================================================
  private async getAdminIds(excluir?: string): Promise<string[]> {
    const admins = await this.userModel.find({ estado: true })
      .populate({ path: 'rol', match: { nombre: 'Administrador' } })
      .select('_id')
      .exec();

    return admins
      .filter((u: any) => u.rol !== null && u._id.toString() !== excluir)
      .map((u: any) => u._id.toString());
  }

  private async getUserIdsByRole(roleId: string): Promise<string[]> {
    const users = await this.userModel.find({ estado: true })
      .select('_id rol nombre email estado')
      .exec();

    const relatedUsers = users.filter((user: any) => user.rol?.toString() === roleId);

    return relatedUsers.map((user: any) => user._id.toString());
  }

  private async enviarEmail(to: string, subject: string, html: string) {
    try {
      await this.resend.emails.send({ from: this.from, to, subject, html });
    } catch {}
  }

  // ======================================================
  // [ EVENTS ] - NOTIFICACIONES DE INICIO DE SESIÓN
  // ======================================================
  async notificarLogin(
    usuarioId: string,
    nombre: string,
    email: string,
    dispositivo: string,
    ip: string,
    ubicacion: string,
  ) {
    const fecha = new Date().toLocaleString('es-PE');
    const data = { nombre, dispositivo, ip, ubicacion, fecha };

    // ALERTA AL USUARIO AFECTADO
    await this.notify(usuarioId, {
      tipo: 'login',
      titulo: '🔐 Nuevo inicio de sesión detectado',
      mensaje: `Acceso exitoso desde el dispositivo: ${dispositivo}`,
      data,
      email: {
        subject: '🔐 Alerta de Seguridad: Nuevo inicio de sesión',
        html: loginTemplate({ nombre, dispositivo, ip, ubicacion, fecha }),
      },
    });

    this.gateway.emitToUser(usuarioId, 'update_sessions', { refresh: true });

  }

  // ======================================================
  // [ EVENTS ] - NOTIFICACIONES DE GESTIÓN DE USUARIOS
  // ======================================================
  async notificarNuevoUsuario(
    usuarioId: string,
    nombre: string,
    rol: string,
    creadoPor: string,
  ) {
    const fecha = new Date().toLocaleString('es-PE');
    const data = { nombre, rol, creadoPor, fecha };

    // BIENVENIDA AL USUARIO
    await this.notify(usuarioId, {
      tipo: 'nuevo_usuario',
      titulo: '👤 Bienvenido a CAJACE SYSTEMS',
      mensaje: `Su cuenta ha sido habilitada satisfactoriamente con el rol: ${rol}`,
      data,
      email: {
        subject: '👤 Bienvenido: Cuenta de acceso creada',
        html: newUserTemplate({ nombre, rol, creadoPor, fecha }),
      },
    });

    // AVISO DE AUDITORÍA PARA ADMINISTRADORES
    const adminIds = await this.getAdminIds(usuarioId);
    await this.notifyMany(adminIds, {
      tipo: 'nuevo_usuario',
      titulo: '👤 Registro de Usuario: Alta en el Sistema',
      mensaje: `Se ha registrado a ${nombre} con el perfil de ${rol}`,
      data,
      email: {
        subject: `👤 Auditoría: Alta de usuario ${nombre}`,
        html: newUserTemplate({ nombre, rol, creadoPor, fecha }),
      },
    });
  }

  // ======================================================
  // [ EVENTS ] - NOTIFICACIONES DE CONTROL DE ACCESO
  // ======================================================
  async notificarNuevoPermiso(nombrePermiso: string, creadoPor: string) {
    const fecha = new Date().toLocaleString('es-PE');
    const data = { nombrePermiso, creadoPor, fecha };
    const adminIds = await this.getAdminIds();

    await this.notifyMany(adminIds, {
      tipo: 'nuevo_permiso',
      titulo: '🛡️ Seguridad: Nuevo permiso registrado',
      mensaje: `Se ha definido el permiso de seguridad "${nombrePermiso}"`,
      data,
    });
  }

  async notificarNuevoRol(nombreRol: string, creadoPor: string) {
    const fecha = new Date().toLocaleString('es-PE');
    const data = { nombreRol, creadoPor, fecha };
    const adminIds = await this.getAdminIds();

    await this.notifyMany(adminIds, {
      tipo: 'nuevo_rol',
      titulo: '👥 Seguridad: Nuevo rol de acceso',
      mensaje: `Se ha configurado el rol de usuario "${nombreRol}"`,
      data,
    });
  }

  async notificarCambioRol(
    usuarioId: string,
    nombre: string,
    rolAnterior: string,
    rolNuevo: string,
    actualizadoPor: string,
  ) {
    const fecha = new Date().toLocaleString('es-PE');
    const data = { nombre, rolAnterior, rolNuevo, actualizadoPor, fecha };

    await this.notify(usuarioId, {
      tipo: 'cambio_rol',
      titulo: 'Rol actualizado',
      mensaje: `Tu cuenta ahora tiene el cargo de ${rolNuevo}`,
      data,
    });
  }

  async emitirActualizacionPermisosRol(
    roleId: string,
    roleName: string,
    permisosAgregados: string[],
    permisosEliminados: string[],
    actualizadoPor: string,
  ) {
    const usuarioIds = await this.getUserIdsByRole(roleId);
    if (usuarioIds.length === 0) {
      return;
    }

    const fecha = new Date().toLocaleString('es-PE');
    const data = {
      roleId,
      roleName,
      permisosAgregados,
      permisosEliminados,
      actualizadoPor,
      fecha,
    };

    usuarioIds.forEach((usuarioId) => {
      this.gateway.emitToUser(usuarioId, 'role_permissions_updated', data);
    });
  }

  // ======================================================
  // [ EVENTS ] - NOTIFICACIONES DE REVOCACIÓN DE ACCESO
  // ======================================================
  async notificarSesionRevocada(
    usuarioId: string,
    nombre: string,
    dispositivo: string,
    sessionId: string,
  ) {
    const fecha = new Date().toLocaleString('es-PE');
    const data = { nombre, dispositivo, fecha };

    // 1. TERMINACIÓN FORZOSA DE SOCKET DE SESIÓN
    this.gateway.emitToSession(sessionId, 'logout_session', { 
      message: 'Su sesión ha sido revocada por el administrador o el sistema de seguridad' 
    });

    // 2. ALERTA AL USUARIO AFECTADO
    await this.notify(usuarioId, {
      tipo: 'sesion_revocada',
      titulo: '⚠️ Seguridad: Sesión cerrada remotamente',
      mensaje: `Su acceso desde el dispositivo ${dispositivo} ha sido revocado`,
      data,
      email: {
        subject: '⚠️ Alerta: Revocación de acceso detectada',
        html: revokeSessionTemplate({ nombre, dispositivo, fecha }),
      },
    });

    this.gateway.emitToUser(usuarioId, 'update_sessions', { refresh: true });

  }

  // ======================================================
  // [ EVENTS ] - NOTIFICACIONES DE CAMBIO DE CREDENCIALES
  // ======================================================
  async notificarCambioPassword(usuarioId: string, nombre: string) {
    const fecha = new Date().toLocaleString('es-PE');
    const data = { nombre, fecha };

    // ALERTA DE SEGURIDAD AL USUARIO
    await this.notify(usuarioId, {
      tipo: 'cambio_password',
      titulo: '🔒 Seguridad: Contraseña actualizada',
      mensaje: 'Sus credenciales de acceso han sido modificadas exitosamente',
      data,
      email: {
        subject: '🔒 Confirmación: Actualización de contraseña',
        html: changePasswordTemplate({ nombre, fecha }),
      },
    });

  }

  // ======================================================
  // [ SECURITY ] - DESPACHO DE CÓDIGOS DE VERIFICACIÓN
  // ======================================================
  async enviarCodigoVerificacion(usuarioId: string, nombre: string, codigo: string) {
    await this.notify(usuarioId, {
      tipo: 'verificacion',
      titulo: '🔑 Seguridad: Código de Verificación',
      mensaje: `Su código de validación de identidad es: ${codigo}`,
      data: { codigo },
      email: {
        subject: '🔑 Código de Seguridad: Verificación de Identidad',
        html: verifyCodeTemplate({ nombre, codigo }),
      },
    });
  }
}




