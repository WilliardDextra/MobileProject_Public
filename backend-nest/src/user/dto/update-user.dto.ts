import { ApiProperty } from "@nestjs/swagger";
import { IsEmail, IsNotEmpty, MinLength } from 'class-validator';


export class UpdateUserDto {
    @ApiProperty()
    @IsNotEmpty({ message: 'Name cannot be empty'})
    name: string

    @ApiProperty()
    @IsEmail({}, { message: 'Invalid email format' })
    email: string

    @ApiProperty()
    @MinLength(6, { message: 'Password must be at least 6 characters' })
    password: string

    constructor(name: string, email: string, password: string){
        this.name = name
        this.email = email
        this.password = password
    }
}