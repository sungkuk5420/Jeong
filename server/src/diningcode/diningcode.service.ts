import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ProxyHttpService } from '../proxy/services/proxy-http.service';

@Injectable()
export class DiningcodeService {
  private readonly baseUrl: string;

  constructor(
    private readonly proxyHttp: ProxyHttpService,
    private readonly config: ConfigService,
  ) {
    this.baseUrl = this.config.getOrThrow('DININGCODE_BASE_URL');
  }

  async searchRestaurant(query: string) {
    return this.proxyHttp.get(`${this.baseUrl}/api/is498List.php`, {
      params: { query },
    });
  }

  async getRestaurantDetail(id: string) {
    return this.proxyHttp.get(`${this.baseUrl}/api/is498Detail.php`, {
      params: { rid: id },
    });
  }
}
