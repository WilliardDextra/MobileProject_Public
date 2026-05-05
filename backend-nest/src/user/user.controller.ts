import { Body, Controller, Get, Put, Req } from '@nestjs/common';
import { UserService } from './user.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { ChangePasswordDto } from './dto/change-password.dto';

@Controller('user')
export class UserController {
    constructor (private readonly userService: UserService) {}

    @Get('profile')
    async getProfile(@Req() req) {
        const userId = req.user?.sub || 1 //Temporary
        return this.userService.getProfile(userId)
    }

    @Put('profile')
    async updateUser(@Req() req, @Body() dto: UpdateUserDto) {
        const userId = req.user?.sub || 1 //Temporary
        return this.userService.updateUser(userId,dto)
    }

    @Put('change-password')
    async changePassword(@Req() req, @Body() body: ChangePasswordDto) {
        const userId = req.user?.sub || 1 //Temporary

        return this.userService.changePassword(userId, body.oldPassword, body.newPassword)
    }
}
