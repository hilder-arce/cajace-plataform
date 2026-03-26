import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Document, Types } from "mongoose";
import { Permission } from "src/permissions/entities/permission.entity";

@Schema({
    timestamps: true //AGREGA CAMPOS DE CREATED_AT Y UPDATED_AT AUTOMATICAMENTE
})
export class Role extends Document {
    @Prop({ required: true, unique: true })
    nombre: string;

    @Prop({ required: true })
    descripcion: string;

    @Prop({ type: [Types.ObjectId], ref: Permission.name, default: [] })
    permisos: string[];

    @Prop({ default: true })
    estado: boolean;
}

export const RoleSchema = SchemaFactory.createForClass(Role)