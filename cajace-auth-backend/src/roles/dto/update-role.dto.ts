import { PartialType } from '@nestjs/mapped-types';
import { CreateRoleDto } from './create-role.dto';
import { IsArray, IsMongoId, IsOptional } from 'class-validator';

export class UpdateRoleDto extends PartialType(CreateRoleDto) {

    @IsArray()
    @IsMongoId({ each: true })
    @IsOptional()
    permisosEliminar?: string[];

}
