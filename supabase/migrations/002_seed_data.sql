-- ═══════════════════════════════════════════
-- Seed Data - Official Places
-- ═══════════════════════════════════════════

INSERT INTO places (id, name, name_ko, category, district, address, phone, opening_hours, latitude, longitude, source_type, description, tags, avg_rating, jeong_rating, external_rating, review_count, jeong_review_count, external_review_count) VALUES
('11111111-1111-1111-1111-111111111111', 'Gwangjang Market', '광장시장', 'Street Food', 'Jongno-gu', '88 Changgyeonggung-ro, Jongno-gu, Seoul', '02-2267-0291', 'Open · Closes at 10:00 PM', 37.5701, 126.9996, 'official', 'Must-visit traditional market', ARRAY['Traditional', 'Budget-friendly', 'Street Food'], 4.5, 4.7, 4.4, 342, 38, 304),

('22222222-2222-2222-2222-222222222222', 'Tosokchon Samgyetang', '토속촌삼계탕', 'Korean', 'Jongno-gu', '5 Jahamun-ro 5-gil, Jongno-gu, Seoul', '02-737-7444', 'Open · Closes at 9:00 PM', 37.5768, 126.9688, 'official', 'Famous ginseng chicken soup', ARRAY['Traditional', 'Must-visit', 'Healthy'], 4.3, 4.6, 4.2, 218, 23, 195),

('33333333-3333-3333-3333-333333333333', 'Bukchon Hanok Village', '북촌한옥마을', 'Attraction', 'Jongno-gu', '37 Gyedong-gil, Jongno-gu, Seoul', NULL, 'Open 24 hours', 37.5826, 126.9831, 'official', 'Beautiful traditional Korean houses', ARRAY['Culture', 'Photography', 'Walking'], 4.4, 4.5, 4.3, 567, 67, 500),

('44444444-4444-4444-4444-444444444444', 'Myeongdong Kyoja', '명동교자', 'Korean', 'Jung-gu', '29 Myeongdong 10-gil, Jung-gu, Seoul', '02-776-5348', 'Open · Closes at 9:30 PM', 37.5636, 126.9856, 'official', 'Best kalguksu in Seoul', ARRAY['Noodles', 'Budget-friendly', 'Must-visit'], 4.2, 4.4, 4.1, 456, 45, 411),

('55555555-5555-5555-5555-555555555555', 'Namsan Seoul Tower', '남산서울타워', 'Attraction', 'Yongsan-gu', '105 Namsangongwon-gil, Yongsan-gu, Seoul', '02-3455-9277', 'Open · Closes at 11:00 PM', 37.5512, 126.9882, 'official', 'Iconic Seoul landmark with panoramic views', ARRAY['Landmark', 'Views', 'Date spot'], 4.6, 4.8, 4.5, 892, 112, 780);

-- ═══════════════════════════════════════════
-- Seed Data - Community Places
-- ═══════════════════════════════════════════

INSERT INTO places (id, name, category, district, address, opening_hours, source_type, description, tags, avg_rating, jeong_rating, review_count, jeong_review_count, registered_by_name) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Hidden Tteokbokki Spot', 'Street Food', 'Mapo-gu', 'Near Mangwon Station Exit 2', 'Open · Closes at 8:00 PM', 'community', '0% tourists, 100% flavor', ARRAY['Hidden gem', 'Spicy', 'Budget-friendly'], 4.8, 4.8, 12, 12, '@traveler_mike'),

('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Rooftop Cafe with Han River View', 'Cafe', 'Yongsan-gu', 'Near Ichon Station Exit 4', 'Open · Closes at 10:00 PM', 'community', 'Best sunset spot in Seoul', ARRAY['Views', 'Date spot', 'Instagram'], 4.7, 4.7, 8, 8, '@sarah_adventures'),

('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Grandma''s Kimbap', 'Korean', 'Seongdong-gu', 'Near Wangsimni Station Exit 7', 'Opens at 6:00 AM', 'community', 'Homemade kimbap, feels like Korean grandma made it', ARRAY['Homestyle', 'Budget-friendly', 'Comfort food'], 4.9, 4.9, 6, 6, '@berlin_backpacker');

-- ═══════════════════════════════════════════
-- Seed Data - Foreigner Tips
-- ═══════════════════════════════════════════

INSERT INTO foreigner_tips (place_id, icon, text) VALUES
('11111111-1111-1111-1111-111111111111', 'menu_book', 'English menu available at some stalls'),
('11111111-1111-1111-1111-111111111111', 'credit_card', 'Cash preferred at most stalls'),
('11111111-1111-1111-1111-111111111111', 'translate', 'Limited English spoken'),
('22222222-2222-2222-2222-222222222222', 'menu_book', 'English menu available'),
('22222222-2222-2222-2222-222222222222', 'credit_card', 'Card payment accepted'),
('22222222-2222-2222-2222-222222222222', 'schedule', 'Expect 30min+ wait during peak hours'),
('33333333-3333-3333-3333-333333333333', 'volume_off', 'Please be quiet - residential area'),
('33333333-3333-3333-3333-333333333333', 'photo_camera', 'Best photo spots at viewpoint #5 and #6'),
('33333333-3333-3333-3333-333333333333', 'directions_walk', 'Wear comfortable shoes - steep hills'),
('44444444-4444-4444-4444-444444444444', 'menu_book', 'Photo menu available'),
('44444444-4444-4444-4444-444444444444', 'credit_card', 'Cash only'),
('44444444-4444-4444-4444-444444444444', 'translate', 'Basic English spoken'),
('55555555-5555-5555-5555-555555555555', 'credit_card', 'Card payment accepted'),
('55555555-5555-5555-5555-555555555555', 'schedule', 'Visit at sunset for best views'),
('55555555-5555-5555-5555-555555555555', 'directions_bus', 'Take cable car or bus #02'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'translate', 'No English spoken - use translator app'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'credit_card', 'Cash only'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'local_fire_department', 'Ask for mild if you cannot handle spicy'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'menu_book', 'English menu available'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'credit_card', 'Card payment accepted'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'schedule', 'Reserve in advance for rooftop seats'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'schedule', 'Opens early 6AM - great for breakfast'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'credit_card', 'Cash preferred');

-- ═══════════════════════════════════════════
-- Seed Data - Reviews
-- ═══════════════════════════════════════════

INSERT INTO reviews (place_id, source, author_name, nationality_flag, rating, content, translated_content, likes_count, comments_count, photo_urls) VALUES
('11111111-1111-1111-1111-111111111111', 'jeong', '@sarah_adventures', '🇺🇸', 5.0, 'Best Korean BBQ experience! The staff helped us grill and the prices were very reasonable. Must visit!', NULL, 12, 3, ARRAY['photo1.jpg', 'photo2.jpg']),
('11111111-1111-1111-1111-111111111111', 'naver', 'Naver User', NULL, 4.0, '직장인 회식 장소로 자주 갑니다. 고기 퀄리티가 좋고 가성비 최고', 'I often come here for company dinners. The meat quality is great and it''s very affordable.', 8, 1, '{}'),
('11111111-1111-1111-1111-111111111111', 'jeong', '@tokyo_foodie', '🇯🇵', 4.5, 'Amazing atmosphere! The traditional Korean setting made the meal even more special. Highly recommend the bulgogi.', NULL, 7, 2, ARRAY['photo3.jpg']),
('11111111-1111-1111-1111-111111111111', 'naver', 'Naver User', NULL, 5.0, '분위기 좋고 직원분들도 친절해요. 외국인 친구 데려갔는데 아주 만족했어요.', 'Great atmosphere and friendly staff. Brought my foreign friend here and they were very satisfied.', 15, 4, '{}'),
('22222222-2222-2222-2222-222222222222', 'jeong', '@london_eats', '🇬🇧', 4.5, 'The samgyetang here is incredible. Waited 40 minutes but totally worth it. Get the abalone version!', NULL, 9, 1, ARRAY['photo4.jpg']),
('33333333-3333-3333-3333-333333333333', 'jeong', '@paris_wanderer', '🇫🇷', 4.0, 'Beautiful village but very crowded on weekends. Go early morning for the best experience.', NULL, 14, 5, ARRAY['photo5.jpg', 'photo6.jpg']);
