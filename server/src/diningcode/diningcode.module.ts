import { Module } from '@nestjs/common';
import { ProxyModule } from '../proxy/proxy.module';
import { DiningcodeController } from './diningcode.controller';
import { DiningcodeService } from './diningcode.service';

@Module({
  imports: [ProxyModule],
  controllers: [DiningcodeController],
  providers: [DiningcodeService],
})
export class DiningcodeModule {}
