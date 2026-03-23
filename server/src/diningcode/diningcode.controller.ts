import {
  Controller,
  Get,
  Query,
  BadRequestException,
  InternalServerErrorException,
  Logger,
} from '@nestjs/common';
import { DiningcodeService } from './diningcode.service';

@Controller('api/diningcode')
export class DiningcodeController {
  private readonly logger = new Logger(DiningcodeController.name);

  constructor(private readonly diningcodeService: DiningcodeService) {}

  @Get('search')
  async search(@Query('query') query: string) {
    if (!query) throw new BadRequestException('query is required');
    try {
      return await this.diningcodeService.searchRestaurant(query);
    } catch (e) {
      this.logger.error(`search failed: ${e}`);
      throw new InternalServerErrorException('Search failed');
    }
  }

  @Get('detail')
  async detail(@Query('id') id: string) {
    if (!id) throw new BadRequestException('id is required');
    try {
      return await this.diningcodeService.getRestaurantDetail(id);
    } catch (e) {
      this.logger.error(`detail failed: ${e}`);
      throw new InternalServerErrorException('Failed to get detail');
    }
  }
}
