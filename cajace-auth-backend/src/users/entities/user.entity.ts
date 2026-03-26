import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';
import { Role } from 'src/roles/entities/role.entity';

@Schema({
  timestamps: true,
})
export class User extends Document {
  @Prop({ required: true })
  nombre: string;

  @Prop({ required: true, unique: true })
  email: string;

  @Prop({ required: true, select: false })
  password: string;

  @Prop({ type: Types.ObjectId, ref: Role.name, required: true })
  rol: Types.ObjectId;

  @Prop({ default: true })
  estado: boolean;
}

export const UserSchema = SchemaFactory.createForClass(User);
