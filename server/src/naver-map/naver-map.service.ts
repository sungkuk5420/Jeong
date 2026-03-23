import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ProxyHttpService } from '../proxy/services/proxy-http.service';
import { NaverTokenService } from './naver-token.service';

@Injectable()
export class NaverMapService {
  private readonly logger = new Logger(NaverMapService.name);
  private readonly clientId: string;
  private readonly clientSecret: string;
  private readonly baseUrl = 'https://openapi.naver.com/v1';

  constructor(
    private readonly proxyHttp: ProxyHttpService,
    private readonly config: ConfigService,
    private readonly tokenService: NaverTokenService,
  ) {
    this.clientId = this.config.getOrThrow('NAVER_CLIENT_ID');
    this.clientSecret = this.config.getOrThrow('NAVER_CLIENT_SECRET');
  }

  private get openApiHeaders() {
    return {
      'X-Naver-Client-Id': this.clientId,
      'X-Naver-Client-Secret': this.clientSecret,
    };
  }

  async allSearch(query: string, coords?: string) {
    return this.tokenService.search(query, coords);
  }

  async searchLocal(query: string, display = 5, start = 1) {
    return this.proxyHttp.get(`${this.baseUrl}/search/local.json`, {
      params: { query, display, start },
      headers: this.openApiHeaders,
    });
  }

  async geocode(query: string) {
    return this.proxyHttp.get(
      'https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode',
      {
        params: { query },
        headers: {
          'X-NCP-APIGW-API-KEY-ID': this.clientId,
          'X-NCP-APIGW-API-KEY': this.clientSecret,
        },
      },
    );
  }

  async reverseGeocode(coords: string) {
    return this.proxyHttp.get(
      'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc',
      {
        params: { coords, output: 'json' },
        headers: {
          'X-NCP-APIGW-API-KEY-ID': this.clientId,
          'X-NCP-APIGW-API-KEY': this.clientSecret,
        },
      },
    );
  }
}
