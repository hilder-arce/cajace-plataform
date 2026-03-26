import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';
import { User } from 'src/users/entities/user.entity';

@Schema({ timestamps: true })
export class Notification extends Document {

  @Prop({ type: Types.ObjectId, ref: User.name, required: true })
  usuario: Types.ObjectId; // a quien va dirigida

  @Prop({ required: true })
  tipo: string; // login, nuevo_usuario, nuevo_permiso, etc.

  @Prop({ required: true })
  titulo: string;

  @Prop({ required: true })
  mensaje: string;

  @Prop({ type: Object, default: {} })
  data: Record<string, any>; // info extra

  @Prop({ default: false })
  leida: boolean;

  @Prop({ default: true })
  estado: boolean;

  createdAt: Date;
  updatedAt?: Date;

}

export const NotificationSchema = SchemaFactory.createForClass(Notification);