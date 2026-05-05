import { ApiProperty } from "@nestjs/swagger"
import { IsNotEmpty, MinLength } from "class-validator"

export class ChangePasswordDto {
    @ApiProperty()
    @IsNotEmpty({ message: 'Old password is required' })
    oldPassword: string

    @ApiProperty()
    @IsNotEmpty({ message: 'New password is required' })
    @MinLength(6, { message: 'New password must be at least 6 characters' })
    newPassword: string

    constructor (oldPassword: string, newPassword: string){
        this.oldPassword = oldPassword
        this.newPassword = newPassword
    }
}