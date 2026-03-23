import { Module } from '@nestjs/common';
import { ProxyModule } from '../proxy/proxy.module';
import { NaverMapController } from './naver-map.controller';
import { NaverMapService } from './naver-map.service';
import { NaverTokenService } from './naver-token.service';

@Module({
  imports: [ProxyModule],
  controllers: [NaverMapController],
  providers: [NaverMapService, NaverTokenService],
})
export class NaverMapModule {}
