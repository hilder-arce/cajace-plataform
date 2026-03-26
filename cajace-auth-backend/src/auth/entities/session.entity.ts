import { Prop, Schema, SchemaFactory } from "@nestjs/mongoose";
import { Document, Types } from "mongoose";
import { User } from "src/users/entities/user.entity";

@Schema({
    timestamps: true, //AGREGA LOS CAMPOS createdAt Y updatedAt AUTOMATICAMENTE 
})
export class Session extends Document {

    @Prop({ type: Types.ObjectId, ref: User.name, required: true})
    usuario: Types.ObjectId;
    
    @Prop({ required: true })
    refreshToken: string;

    @Prop({ required: true })
    dispositivo: string; //user agent

    @Prop({ required: true })
    ip: string;

    @Prop({ default: false })
    bloqueado: boolean; //look de concurrencias

    @Prop({ default: null })
    bloqueadoEn: Date; //cuando se adqirioel look

    @Prop({ required: true })
    expiraEn: Date; //cuando vence el refresh token

    @Prop({ default: true })
    estado: boolean;
}

export const SessionSchema  = SchemaFactory.createForClass(Session);
