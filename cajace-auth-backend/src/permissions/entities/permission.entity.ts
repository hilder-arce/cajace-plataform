import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Document, Types } from "mongoose";
import { Module } from "src/modules/entities/module.entity";

@Schema({
    timestamps: true //AGREGA CAMPOS DE CREATED_AT Y UPDATED_AT AUTOMATICAMENTE
})
export class Permission extends Document {
    @Prop({ required: true, unique: true })
    nombre: string;

    @Prop({ required: true })
    descripcion: string;

    @Prop({ type: Types.ObjectId, ref: Module.name, required: true })
    modulo: Types.ObjectId;//REFERENCIA AL MODULO AL QUE PERTENECE EL PERMISO (RELACION CON LA COLECCION DE MODULOS)

    @Prop({ default: true })
    estado: boolean;
}

export const PermissionSchema = SchemaFactory.createForClass(Permission)