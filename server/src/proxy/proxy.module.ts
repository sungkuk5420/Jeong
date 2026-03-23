import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { ProxyHttpService } from './services/proxy-http.service';

@Module({
  imports: [HttpModule],
  providers: [ProxyHttpService],
  exports: [ProxyHttpService],
})
export class ProxyModule {}
