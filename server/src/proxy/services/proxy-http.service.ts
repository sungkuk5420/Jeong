import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { AxiosRequestConfig } from 'axios';
import { firstValueFrom } from 'rxjs';

interface ScrapingGetOptions {
  params?: Record<string, string>;
  headers?: Record<string, string>;
}

@Injectable()
export class ProxyHttpService {
  private readonly logger = new Logger(ProxyHttpService.name);
  private gotScraping: any = null;

  constructor(private readonly httpService: HttpService) {}

  /** 일반 API 호출 (axios) */
  async get<T = any>(url: string, config?: AxiosRequestConfig): Promise<T> {
    this.logger.debug(`GET ${url}`);
    const { data } = await firstValueFrom(
      this.httpService.get<T>(url, config),
    );
    return data;
  }

  async post<T = any>(
    url: string,
    body?: any,
    config?: AxiosRequestConfig,
  ): Promise<T> {
    this.logger.debug(`POST ${url}`);
    const { data } = await firstValueFrom(
      this.httpService.post<T>(url, body, config),
    );
    return data;
  }

  /** anti-bot 우회 HTTP 호출 (got-scraping, 브라우저 TLS fingerprint 위장) */
  async scrapingGet<T = any>(url: string, options?: ScrapingGetOptions): Promise<T> {
    if (!this.gotScraping) {
      const mod = await (Function('return import("got-scraping")')() as Promise<any>);
      this.gotScraping = mod.gotScraping;
    }

    const searchParams = options?.params
      ? new URLSearchParams(options.params).toString()
      : '';
    const fullUrl = searchParams ? `${url}?${searchParams}` : url;

    this.logger.debug(`SCRAPING GET ${fullUrl}`);

    const response = await this.gotScraping({
      url: fullUrl,
      headers: options?.headers ?? {},
      headerGeneratorOptions: {
        browsers: [{ name: 'chrome', minVersion: 120 }],
        devices: ['desktop'],
        operatingSystems: ['windows'],
      },
    });

    return JSON.parse(response.body) as T;
  }
}
