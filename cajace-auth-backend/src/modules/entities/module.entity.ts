import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Document } from "mongoose";

@Schema({
    timestamps: true //AGREGA CAMPOS DE CREATED_AT Y UPDATED_AT AUTOMATICAMENTE
})
export class Module extends Document {
    @Prop({ required: true, unique: true })
    nombre: string;

    @Prop({ required: true })
    descripcion: string;

    @Prop({ default: true })
    estado: boolean;
}

export const ModuleSchema = SchemaFactory.createForClass(Module)    