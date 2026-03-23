import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { NaverMapModule } from './naver-map/naver-map.module';
import { DiningcodeModule } from './diningcode/diningcode.module';
import { TranslateModule } from './translate/translate.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    NaverMapModule,
    DiningcodeModule,
    TranslateModule,
  ],
})
export class AppModule {}
