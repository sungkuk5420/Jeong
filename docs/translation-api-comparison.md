# 번역 API 비교 분석 (2026.03)

> KoreaWith(Jeong) 앱에 번역 기능 도입을 위한 API 비교

---

## 1. 전통 번역 API (NMT 기반)

| API | 무료 티어 | 유료 가격 (100만 글자당) | 지원 언어 | 한국어 품질 | 비고 |
|-----|-----------|------------------------|-----------|------------|------|
| **Google Cloud Translation** | 50만 글자/월 (영구) | $20 | 130+ | 상 | 가장 넓은 언어 지원, GCP 연동 |
| **DeepL** | 50만 글자/월 | $25 + 월 $5.49 기본료 | 33 | 중상 | 유럽어 최강, 아랍어 미지원 |
| **Azure Translator** | **200만 글자/월** | $10 | 100+ | 상 | 무료 티어 최대, Azure 연동 |
| **Amazon Translate** | 200만 글자/월 (12개월) | $15 | 75+ | 중상 | 12개월 후 무료 만료 |
| **Papago (네이버)** | 1만 글자/일 | 약 ₩15,000/100만 글자 | 15 | **최상** | 한↔일/중/영 최강 |
| **LibreTranslate** | **무제한 (셀프호스팅)** | 무료 | 45 | 중 | 오픈소스, 품질 낮음 |

### 무료 티어 승자: **Azure Translator** (200만 글자/월)

---

## 2. AI 모델 번역 (LLM 기반)

| 모델 | 가격 (100만 글자 ≈ 25만 토큰 기준) | 번역 품질 | 응답 속도 (100단어) | 비고 |
|------|--------------------------------------|-----------|-------------------|------|
| **GPT-4o** | ~$5 | 92.8% | 800ms | 품질 최고 |
| **Claude Sonnet 4.6** | ~$6 | 92.6% | 1,000ms | GPT-4o와 거의 동급 |
| **Gemini 3 Flash** | ~$2 | ~88% | 400ms | 가성비 최강 |
| **Gemini 3.1 Pro** | ~$7 | ~91% | 600ms | Flash 대비 품질 ↑ |
| **GPT-4o mini** | ~$1.5 | ~87% | 300ms | 초저가 |

### AI 번역 가성비 승자: **Gemini 3 Flash** ($2/100만 글자)

---

## 3. 핵심 비교: 전통 NMT vs AI 번역

| 항목 | 전통 NMT (Google/Azure) | AI LLM (GPT/Claude/Gemini) |
|------|------------------------|---------------------------|
| **100만 글자 비용** | $10~25 | $1.5~7 |
| **무료 티어** | 50~200만 글자/월 | 없음 (API 기준) |
| **번역 품질** | 85~87% | 88~93% |
| **응답 속도** | 50~150ms | 300~1,000ms |
| **문맥 이해** | 문장 단위 | 문단/대화 단위 (우수) |
| **구어체/슬랭** | 약함 | 강함 |
| **설정 난이도** | 쉬움 (문자열 입출력) | 프롬프트 엔지니어링 필요 |
| **일관성** | 높음 (동일 입력 = 동일 출력) | 변동 가능 |

---

## 4. 비용 시뮬레이션 (Jeong 앱 기준)

### 가정
- 월 활성 사용자 (MAU): 1,000명
- 사용자당 월 번역량: 평균 5,000글자 (리뷰 10개 + UI 텍스트)
- **월 총 번역량: 500만 글자**

| API | 월 비용 | 연간 비용 |
|-----|---------|-----------|
| Azure (무료 200만 + 유료 300만) | $30 | $360 |
| Google (무료 50만 + 유료 450만) | $90 | $1,080 |
| DeepL | $191 (~$5.49 + $125) | $2,292 |
| **Gemini Flash** | **$10** | **$120** |
| GPT-4o | $25 | $300 |
| Claude Sonnet | $30 | $360 |

### 비용 승자: **Gemini Flash** (월 $10)

---

## 5. Jeong 앱 추천 전략

### Option A: 하이브리드 (추천)

```
실시간 UI 번역  →  Azure Translator (무료 200만 글자)
리뷰/설명 번역  →  Gemini Flash (고품질 + 저가)
한↔일/중 특화  →  Papago (한국어 품질 최고)
```

**장점**: 무료 티어 최대 활용 + AI 품질 + 한국어 특화
**월 예상 비용**: MAU 1,000 기준 ~$5~15

### Option B: AI Only (심플)

```
모든 번역 →  Gemini Flash ($2/100만 글자)
```

**장점**: 구현 심플, 문맥 이해 우수, 구어체 강함
**월 예상 비용**: MAU 1,000 기준 ~$10

### Option C: 무료 Only (초기)

```
모든 번역 →  Azure Translator (200만 글자/월 무료)
초과분    →  Google Translate (50만 글자/월 추가 무료)
```

**장점**: 완전 무료 (MAU ~500 이하)
**월 예상 비용**: $0 (250만 글자 이내)

---

## 6. 결론

| 우선순위 | 추천 |
|---------|------|
| **비용 최소화** | Azure 무료 (200만) + Google 무료 (50만) = 월 250만 글자 무료 |
| **품질 최우선** | GPT-4o 또는 Claude Sonnet (~93% 품질) |
| **가성비 최강** | Gemini Flash ($2/100만 글자, ~88% 품질) |
| **한국어 특화** | Papago (한↔일/중/영 최고 품질) |
| **데이터 프라이버시** | LibreTranslate 셀프호스팅 (무료, 품질 낮음) |

> **AI 번역이 더 쌀까?**
> **Yes.** 유료 기준 AI(Gemini Flash $2) < 전통 NMT(Google $20)로 **10배 저렴**하면서 품질도 비슷하거나 우수.
> 단, 무료 티어만 쓸 거면 Azure(200만) + Google(50만) 조합이 $0으로 가능.

---

## Sources

- [Best Translation API 2026 - IntlPull](https://intlpull.com/blog/ai-translation-api-comparison-2026)
- [Translation API Pricing Comparison - BuildMVPFast](https://www.buildmvpfast.com/api-costs/translation)
- [Best Free Translation APIs 2026 - Langbly](https://langbly.com/blog/best-free-translation-api-2026/)
- [AI API Pricing Comparison 2026 - IntuitionLabs](https://intuitionlabs.ai/articles/ai-api-pricing-comparison-grok-gemini-openai-claude)
- [Papago Translation - Naver Cloud](https://www.ncloud.com/v2/product/aiService/papagoTranslation)
- [AI Translation Cost - Crowdin](https://crowdin.com/blog/ai-translation-cost)
