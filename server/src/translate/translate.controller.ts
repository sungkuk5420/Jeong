import {
  Controller,
  Post,
  Body,
  BadRequestException,
  InternalServerErrorException,
  Logger,
} from '@nestjs/common';
import { TranslateService } from './translate.service';

interface TranslateBody {
  text: string;
  to: string;
  from?: string;
}

interface TranslateBatchBody {
  texts: string[];
  to: string;
  from?: string;
}

@Controller('api/translate')
export class TranslateController {
  private readonly logger = new Logger(TranslateController.name);

  constructor(private readonly translateService: TranslateService) {}

  @Post()
  async translate(@Body() body: TranslateBody) {
    if (!body.text) throw new BadRequestException('text is required');
    if (!body.to) throw new BadRequestException('to is required');

    try {
      return await this.translateService.translate(body.text, body.to, body.from);
    } catch (e) {
      this.logger.error(`translate failed: ${e}`);
      throw new InternalServerErrorException('Translation failed');
    }
  }

  @Post('batch')
  async translateBatch(@Body() body: TranslateBatchBody) {
    if (!body.texts?.length) throw new BadRequestException('texts is required');
    if (!body.to) throw new BadRequestException('to is required');
    if (body.texts.length > 100) {
      throw new BadRequestException('Max 100 texts per batch');
    }

    try {
      return await this.translateService.translateBatch(
        body.texts,
        body.to,
        body.from,
      );
    } catch (e) {
      this.logger.error(`batch translate failed: ${e}`);
      throw new InternalServerErrorException('Batch translation failed');
    }
  }
}
