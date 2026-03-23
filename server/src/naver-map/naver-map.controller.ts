import {
  Controller,
  Get,
  Query,
  BadRequestException,
  InternalServerErrorException,
  Logger,
} from '@nestjs/common';
import { NaverMapService } from './naver-map.service';

@Controller('api/naver-map')
export class NaverMapController {
  private readonly logger = new Logger(NaverMapController.name);

  constructor(private readonly naverMapService: NaverMapService) {}

  @Get('all-search')
  async allSearch(
    @Query('query') query: string,
    @Query('coords') coords?: string,
  ) {
    if (!query) throw new BadRequestException('query is required');
    try {
      return await this.naverMapService.allSearch(query, coords);
    } catch (e) {
      this.logger.error(`all-search failed: ${e}`);
      throw new InternalServerErrorException('Search failed');
    }
  }

  @Get('search')
  async searchLocal(
    @Query('query') query: string,
    @Query('display') display?: number,
    @Query('start') start?: number,
  ) {
    if (!query) throw new BadRequestException('query is required');
    try {
      return await this.naverMapService.searchLocal(query, display, start);
    } catch (e) {
      this.logger.error(`search failed: ${e}`);
      throw new InternalServerErrorException('Search failed');
    }
  }

  @Get('geocode')
  async geocode(@Query('query') query: string) {
    if (!query) throw new BadRequestException('query is required');
    try {
      return await this.naverMapService.geocode(query);
    } catch (e) {
      this.logger.error(`geocode failed: ${e}`);
      throw new InternalServerErrorException('Geocode failed');
    }
  }

  @Get('reverse-geocode')
  async reverseGeocode(@Query('coords') coords: string) {
    if (!coords) throw new BadRequestException('coords is required');
    try {
      return await this.naverMapService.reverseGeocode(coords);
    } catch (e) {
      this.logger.error(`reverse-geocode failed: ${e}`);
      throw new InternalServerErrorException('Reverse geocode failed');
    }
  }
}
