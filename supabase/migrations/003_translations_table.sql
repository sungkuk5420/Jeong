-- ═══════════════════════════════════════════
-- Translation Cache Table
-- 원문 1개 → N개 언어 번역 캐싱
-- (review_id, language) 조합으로 중복 방지
-- ═══════════════════════════════════════════

CREATE TABLE translations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
  language TEXT NOT NULL,            -- 'en', 'ja', 'zh', 'fr', etc.
  translated_text TEXT NOT NULL,
  source_language TEXT,              -- 자동 감지된 원문 언어 (e.g. 'ko')
  created_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE (review_id, language)       -- 리뷰당 언어별 1개만
);

CREATE INDEX idx_translations_review ON translations (review_id);
CREATE INDEX idx_translations_lookup ON translations (review_id, language);

-- ─── RLS ───
ALTER TABLE translations ENABLE ROW LEVEL SECURITY;

-- 누구나 읽기 가능 (번역은 공유 자원)
CREATE POLICY "Translations viewable by everyone"
  ON translations FOR SELECT USING (true);

-- 인증된 사용자만 번역 추가 가능
CREATE POLICY "Authenticated users can add translations"
  ON translations FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- 기존 reviews 테이블의 translated_content 컬럼은 유지
-- (하위 호환, 점진적 마이그레이션)
