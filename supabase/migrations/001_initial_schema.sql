-- ═══════════════════════════════════════════
-- Jeong App - Supabase Database Schema
-- ═══════════════════════════════════════════

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- For text search

-- ─────────────────────────────────────
-- 1. Profiles (extends Supabase auth.users)
-- ─────────────────────────────────────
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL DEFAULT 'Jeong User',
  email TEXT,
  avatar_url TEXT,
  nationality TEXT,            -- Country code e.g. 'US', 'JP', 'FR'
  nationality_flag TEXT,       -- Emoji flag e.g. '🇺🇸'
  preferred_language TEXT DEFAULT 'en',
  fcm_token TEXT,              -- For push notifications
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────
-- 2. Places
-- ─────────────────────────────────────
CREATE TYPE place_source AS ENUM ('official', 'community');

CREATE TABLE places (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  name_ko TEXT,                -- Korean name
  category TEXT NOT NULL,      -- 'Korean', 'Cafe', 'Street Food', 'Attraction', etc.
  district TEXT NOT NULL,      -- 'Jongno-gu', 'Mapo-gu', etc.
  address TEXT,
  address_ko TEXT,
  phone TEXT,
  opening_hours TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  source_type place_source NOT NULL DEFAULT 'official',
  description TEXT,
  image_url TEXT,
  tags TEXT[] DEFAULT '{}',

  -- Ratings (cached, updated by trigger)
  avg_rating NUMERIC(2,1) DEFAULT 0,
  jeong_rating NUMERIC(2,1) DEFAULT 0,
  external_rating NUMERIC(2,1) DEFAULT 0,
  review_count INT DEFAULT 0,
  jeong_review_count INT DEFAULT 0,
  external_review_count INT DEFAULT 0,

  -- Community place fields
  registered_by UUID REFERENCES profiles(id),
  registered_by_name TEXT,
  is_verified BOOLEAN DEFAULT FALSE,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for text search
CREATE INDEX idx_places_name_trgm ON places USING gin (name gin_trgm_ops);
CREATE INDEX idx_places_category ON places (category);
CREATE INDEX idx_places_district ON places (district);
CREATE INDEX idx_places_source ON places (source_type);
CREATE INDEX idx_places_rating ON places (avg_rating DESC);

-- ─────────────────────────────────────
-- 3. Foreigner Tips
-- ─────────────────────────────────────
CREATE TABLE foreigner_tips (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  place_id UUID NOT NULL REFERENCES places(id) ON DELETE CASCADE,
  icon TEXT NOT NULL DEFAULT 'info',
  text TEXT NOT NULL,
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_tips_place ON foreigner_tips (place_id);

-- ─────────────────────────────────────
-- 4. Reviews
-- ─────────────────────────────────────
CREATE TYPE review_source AS ENUM ('jeong', 'naver', 'google');

CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  place_id UUID NOT NULL REFERENCES places(id) ON DELETE CASCADE,
  source review_source NOT NULL DEFAULT 'jeong',
  author_id UUID REFERENCES profiles(id),
  author_name TEXT NOT NULL,
  nationality TEXT,
  nationality_flag TEXT,
  rating NUMERIC(2,1) NOT NULL CHECK (rating >= 1 AND rating <= 5),
  content TEXT NOT NULL,
  translated_content TEXT,
  photo_urls TEXT[] DEFAULT '{}',
  likes_count INT DEFAULT 0,
  comments_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_reviews_place ON reviews (place_id);
CREATE INDEX idx_reviews_source ON reviews (source);
CREATE INDEX idx_reviews_author ON reviews (author_id);
CREATE INDEX idx_reviews_rating ON reviews (rating DESC);
CREATE INDEX idx_reviews_created ON reviews (created_at DESC);

-- ─────────────────────────────────────
-- 5. Review Likes
-- ─────────────────────────────────────
CREATE TABLE review_likes (
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, review_id)
);

-- ─────────────────────────────────────
-- 6. Bookmarks
-- ─────────────────────────────────────
CREATE TABLE bookmarks (
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  place_id UUID NOT NULL REFERENCES places(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, place_id)
);

CREATE INDEX idx_bookmarks_user ON bookmarks (user_id);

-- ─────────────────────────────────────
-- 7. Push Notification Subscriptions
-- ─────────────────────────────────────
CREATE TABLE notification_preferences (
  user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  new_review_on_bookmark BOOLEAN DEFAULT TRUE,
  community_picks BOOLEAN DEFAULT TRUE,
  weekly_digest BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════
-- Row Level Security (RLS)
-- ═══════════════════════════════════════════

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE places ENABLE ROW LEVEL SECURITY;
ALTER TABLE foreigner_tips ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;

-- Profiles: read by anyone, update own
CREATE POLICY "Profiles viewable by everyone"
  ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Places: read by anyone, insert by authenticated
CREATE POLICY "Places viewable by everyone"
  ON places FOR SELECT USING (true);
CREATE POLICY "Authenticated users can add places"
  ON places FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Place owners can update"
  ON places FOR UPDATE USING (auth.uid() = registered_by);

-- Tips: read by anyone, insert by authenticated
CREATE POLICY "Tips viewable by everyone"
  ON foreigner_tips FOR SELECT USING (true);
CREATE POLICY "Authenticated users can add tips"
  ON foreigner_tips FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Reviews: read by anyone, insert/update/delete own
CREATE POLICY "Reviews viewable by everyone"
  ON reviews FOR SELECT USING (true);
CREATE POLICY "Authenticated users can add reviews"
  ON reviews FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Users can update own reviews"
  ON reviews FOR UPDATE USING (auth.uid() = author_id);
CREATE POLICY "Users can delete own reviews"
  ON reviews FOR DELETE USING (auth.uid() = author_id);

-- Review Likes: read by anyone, manage own
CREATE POLICY "Likes viewable by everyone"
  ON review_likes FOR SELECT USING (true);
CREATE POLICY "Users can manage own likes"
  ON review_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can remove own likes"
  ON review_likes FOR DELETE USING (auth.uid() = user_id);

-- Bookmarks: own only
CREATE POLICY "Users can view own bookmarks"
  ON bookmarks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can add bookmarks"
  ON bookmarks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can remove bookmarks"
  ON bookmarks FOR DELETE USING (auth.uid() = user_id);

-- Notification Preferences: own only
CREATE POLICY "Users can view own notification prefs"
  ON notification_preferences FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own notification prefs"
  ON notification_preferences FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own notification prefs"
  ON notification_preferences FOR UPDATE USING (auth.uid() = user_id);

-- ═══════════════════════════════════════════
-- Functions & Triggers
-- ═══════════════════════════════════════════

-- Auto-create profile on sign up
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, display_name, email, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', 'Jeong User'),
    NEW.email,
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Update review counts & ratings on place
CREATE OR REPLACE FUNCTION update_place_ratings()
RETURNS TRIGGER AS $$
DECLARE
  p_id UUID;
BEGIN
  p_id := COALESCE(NEW.place_id, OLD.place_id);

  UPDATE places SET
    review_count = (SELECT COUNT(*) FROM reviews WHERE place_id = p_id),
    jeong_review_count = (SELECT COUNT(*) FROM reviews WHERE place_id = p_id AND source = 'jeong'),
    external_review_count = (SELECT COUNT(*) FROM reviews WHERE place_id = p_id AND source != 'jeong'),
    avg_rating = COALESCE((SELECT ROUND(AVG(rating)::numeric, 1) FROM reviews WHERE place_id = p_id), 0),
    jeong_rating = COALESCE((SELECT ROUND(AVG(rating)::numeric, 1) FROM reviews WHERE place_id = p_id AND source = 'jeong'), 0),
    external_rating = COALESCE((SELECT ROUND(AVG(rating)::numeric, 1) FROM reviews WHERE place_id = p_id AND source != 'jeong'), 0),
    updated_at = NOW()
  WHERE id = p_id;

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_review_change
  AFTER INSERT OR UPDATE OR DELETE ON reviews
  FOR EACH ROW EXECUTE FUNCTION update_place_ratings();

-- Update likes count on review
CREATE OR REPLACE FUNCTION update_review_likes()
RETURNS TRIGGER AS $$
DECLARE
  r_id UUID;
BEGIN
  r_id := COALESCE(NEW.review_id, OLD.review_id);

  UPDATE reviews SET
    likes_count = (SELECT COUNT(*) FROM review_likes WHERE review_id = r_id)
  WHERE id = r_id;

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_like_change
  AFTER INSERT OR DELETE ON review_likes
  FOR EACH ROW EXECUTE FUNCTION update_review_likes();

-- Updated_at auto-update
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at_profiles
  BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at_places
  BEFORE UPDATE ON places FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at_reviews
  BEFORE UPDATE ON reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at();
