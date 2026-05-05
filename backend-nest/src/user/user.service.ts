import { BadRequestException, Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import { UpdateUserDto } from './dto/update-user.dto';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UserService {
    constructor (private prisma: PrismaService) {}

    async getProfile(userId: number){
        const user = await this.prisma.user.findUnique({
            where: { id: userId},
            select: {
                id: true,
                name: true,
                email: true,
                role: true,
            },
        })

        if(!user){
            throw new NotFoundException('User not found')
        }

        return user
    }

    async updateUser(userId: number, dto: UpdateUserDto){
        const user = await this.prisma.user.findUnique({
            where: {id: userId}
        })

        if(!user){
            throw new NotFoundException('User not found')
        }

        const hashedPassword = await bcrypt.hash(dto.password,10)

        return this.prisma.user.update({
            where: {id: userId},
            data: {
                name: dto.name,
                email: dto.email,
                password: hashedPassword
            },
            select: {
                id: true,
                name: true,
                email: true,
                role: true
            }
        })
    }

    async changePassword(userId: number, oldPassword: string, newPassword: string){
        const user = await this.prisma.user.findUnique({
            where: {id: userId}
        })

        if(!user){
            throw new NotFoundException('User not found')
        }

        const isMatch = await bcrypt.compare(oldPassword, user.password)

        if(!isMatch){
            throw new UnauthorizedException('Old password is incorrect')
        }

        if(newPassword.length < 6){
            throw new BadRequestException('New password must be at least 6 characters')
        }

        const hashedPassword = await bcrypt.hash(newPassword, 10)

        return this.prisma.user.update({
            where: {id: userId},
            data: {
                password: hashedPassword
            },
            select: {
                id: true,
                name: true,
                email: true,
                role: true
            }
        })
    }
}
