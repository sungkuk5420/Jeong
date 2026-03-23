import {
  Injectable,
  Logger,
  OnModuleInit,
  OnModuleDestroy,
} from '@nestjs/common';
import puppeteer, { Browser, Page, HTTPResponse } from 'puppeteer';

@Injectable()
export class NaverTokenService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(NaverTokenService.name);
  private browser: Browser | null = null;
  private page: Page | null = null;
  private ready = false;

  async onModuleInit() {
    await this.initBrowser();
  }

  async onModuleDestroy() {
    await this.closeBrowser();
  }

  private async initBrowser() {
    this.logger.log('브라우저 인스턴스 시작...');

    this.browser = await puppeteer.launch({
      headless: true,
      executablePath: process.env.PUPPETEER_EXECUTABLE_PATH || undefined,
      args: [
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--disable-dev-shm-usage',
        '--disable-gpu',
        '--disable-extensions',
        '--single-process',
      ],
    });

    this.page = await this.browser.newPage();

    await this.page.setUserAgent(
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36',
    );

    // 불필요한 리소스 차단
    await this.page.setRequestInterception(true);
    this.page.on('request', (req) => {
      const type = req.resourceType();
      if (['image', 'stylesheet', 'font', 'media'].includes(type)) {
        req.abort();
      } else {
        req.continue();
      }
    });

    // 네이버 지도 접속하여 세션 확보
    await this.page.goto('https://map.naver.com/', {
      waitUntil: 'domcontentloaded',
      timeout: 30000,
    });

    this.ready = true;
    this.logger.log('브라우저 준비 완료');
  }

  private async closeBrowser() {
    if (this.browser) {
      await this.browser.close();
      this.browser = null;
      this.page = null;
      this.ready = false;
    }
  }

  private async ensureReady() {
    if (!this.ready || !this.page || !this.browser?.connected) {
      await this.closeBrowser();
      await this.initBrowser();
    }
  }

  /**
   * 네이버 지도 검색: 페이지를 검색 URL로 이동시켜
   * 네이버 JS가 토큰을 생성하고 API를 호출하면, 그 응답을 가로챈다.
   */
  async search(query: string, coords?: string): Promise<any> {
    await this.ensureReady();

    try {
      return await this.doSearch(query);
    } catch (error) {
      this.logger.warn('검색 실패 → 브라우저 재시작 후 재시도');
      await this.closeBrowser();
      await this.initBrowser();
      return this.doSearch(query);
    }
  }

  private doSearch(query: string): Promise<any> {
    return new Promise(async (resolve, reject) => {
      let resolved = false;

      const timeout = setTimeout(() => {
        if (!resolved) {
          resolved = true;
          this.page!.off('response', onResponse);
          reject(new Error('검색 응답 타임아웃 (10초)'));
        }
      }, 10000);

      const onResponse = async (res: HTTPResponse) => {
        if (resolved) return;
        try {
          if (
            res.url().includes('/p/api/search/allSearch') &&
            res.status() === 200
          ) {
            const data = await res.json();
            if (!data?.result?.ncaptcha) {
              resolved = true;
              clearTimeout(timeout);
              this.page!.off('response', onResponse);
              resolve(data);
            }
          }
        } catch {}
      };

      this.page!.on('response', onResponse);

      try {
        // SPA 내부에서 URL만 변경 → 라우터가 검색 API 호출
        const encodedQuery = encodeURIComponent(query);
        await this.page!.evaluate((q: string) => {
          location.href = `/p/search/${q}`;
        }, encodedQuery);
      } catch (err) {
        if (!resolved) {
          resolved = true;
          clearTimeout(timeout);
          this.page!.off('response', onResponse);
          reject(err);
        }
      }
    });
  }
}
