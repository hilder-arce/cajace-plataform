import { Controller, Delete, Get, Param, Patch, Query, Req } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';

import { NotificationsService } from './notifications.service';
import { Notification } from './entities/notification.entity';

@Controller('notifications')
export class NotificationsController {
  constructor(
    @InjectModel(Notification.name) private readonly notificationModel: Model<Notification>,
    private readonly notificationsService: NotificationsService
  ) {}

  // ==========================================
  // [ GET ] - MIS NOTIFICACIONES (PAGINADAS)
  // ==========================================
  @Get('mias')
  async misNotificaciones(
    @Req() req: Request,
    @Query('page') page: string = '1',
    @Query('limit') limit: string = '10',
    @Query('search') search?: string
  ) {
    const usuarioId = (req as any).user?.sub;
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    const query: any = { 
      usuario: new Types.ObjectId(usuarioId), 
      estado: true 
    };

    if (search) {
      query.$or = [
        { titulo: { $regex: search, $options: 'i' } },
        { mensaje: { $regex: search, $options: 'i' } }
      ];
    }

    const [items, total] = await Promise.all([
      this.notificationModel
        .find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .exec(),
      this.notificationModel.countDocuments(query)
    ]);

    return {
      items,
      total,
      page: parseInt(page),
      pages: Math.ceil(total / parseInt(limit))
    };
  }

  // ==========================================
  // [ GET ] - CONTEO DE NOTIFICACIONES NO LEÍDAS
  // ==========================================
  @Get('no-leidas')
  async noLeidas(@Req() req: Request) {
    const usuarioId = (req as any).user?.sub;
    const count = await this.notificationModel.countDocuments({
      usuario: new Types.ObjectId(usuarioId),
      leida: false,
      estado: true,
    });
    return { total: count };
  }

  // ==========================================
  // [ PATCH ] - MARCAR NOTIFICACIÓN COMO LEÍDA
  // ==========================================
  @Patch(':id/leer')
  async marcarLeida(@Param('id') id: string) {
    await this.notificationModel.findByIdAndUpdate(id, { leida: true });
    return { message: 'La notificación ha sido marcada como leída satisfactoriamente' };
  }

  // ==========================================
  // [ PATCH ] - MARCAR TODAS COMO LEÍDAS
  // ==========================================
  @Patch('leer-todas')
  async marcarTodasLeidas(@Req() req: Request) {
    const usuarioId = (req as any).user?.sub;
    await this.notificationModel.updateMany(
      { usuario: new Types.ObjectId(usuarioId), leida: false },
      { leida: true }
    );
    return { message: 'Todas las notificaciones han sido actualizadas a estado leído' };
  }

  // ==========================================
  // [ DELETE ] - ELIMINACIÓN LÓGICA DE NOTIFICACIÓN
  // ==========================================
  @Delete(':id')
  async eliminar(@Param('id') id: string) {
    await this.notificationModel.findByIdAndUpdate(id, { estado: false });
    return { message: 'La notificación ha sido eliminada del sistema' };
  }
}
