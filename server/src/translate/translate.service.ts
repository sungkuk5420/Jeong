import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ProxyHttpService } from '../proxy/services/proxy-http.service';

export interface TranslateResult {
  originalText: string;
  translatedText: string;
  from: string;
  to: string;
}

@Injectable()
export class TranslateService {
  private readonly logger = new Logger(TranslateService.name);
  private readonly apiKey: string;
  private readonly region: string;
  private readonly endpoint =
    'https://api.cognitive.microsofttranslator.com/translate';

  constructor(
    private readonly proxyHttp: ProxyHttpService,
    private readonly config: ConfigService,
  ) {
    this.apiKey = this.config.getOrThrow('AZURE_TRANSLATOR_KEY');
    this.region = this.config.get('AZURE_TRANSLATOR_REGION') ?? 'koreacentral';
  }

  /**
   * 단일 텍스트 번역
   */
  async translate(
    text: string,
    to: string,
    from?: string,
  ): Promise<TranslateResult> {
    const results = await this.translateBatch([text], to, from);
    return results[0];
  }

  /**
   * 여러 텍스트 일괄 번역 (최대 100개, Azure 제한)
   */
  async translateBatch(
    texts: string[],
    to: string,
    from?: string,
  ): Promise<TranslateResult[]> {
    const params: Record<string, string> = {
      'api-version': '3.0',
      to,
    };
    if (from) params.from = from;

    const body = texts.map((text) => ({ Text: text }));

    const url = new URL(this.endpoint);
    Object.entries(params).forEach(([k, v]) => url.searchParams.set(k, v));

    this.logger.debug(
      `Translating ${texts.length} text(s): ${from ?? 'auto'} → ${to}`,
    );

    const response = await this.proxyHttp.post<any[]>(url.toString(), body, {
      headers: {
        'Ocp-Apim-Subscription-Key': this.apiKey,
        'Ocp-Apim-Subscription-Region': this.region,
        'Content-Type': 'application/json',
      },
    });

    return response.map((item, i) => ({
      originalText: texts[i],
      translatedText: item.translations[0].text,
      from: item.detectedLanguage?.language ?? from ?? 'unknown',
      to,
    }));
  }

  /**
   * 언어 감지
   */
  async detectLanguage(text: string): Promise<string> {
    const url = `https://api.cognitive.microsofttranslator.com/detect?api-version=3.0`;

    const response = await this.proxyHttp.post<any[]>(url, [{ Text: text }], {
      headers: {
        'Ocp-Apim-Subscription-Key': this.apiKey,
        'Ocp-Apim-Subscription-Region': this.region,
        'Content-Type': 'application/json',
      },
    });

    return response[0].language;
  }
}
