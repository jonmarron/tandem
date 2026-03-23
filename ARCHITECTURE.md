# FamilyMatch — Architecture & Technical Reference

## Vision

A mobile app for parents who are new to an area (or new parents) to connect with other families. Think "Tinder for families" — parents create a family profile, describe themselves and their kids, discover nearby families, and match to become friends.

## Tech Stack

| Layer | Technology | Why |
|---|---|---|
| Mobile framework | React Native + Expo (managed) | Managed workflow handles builds, OTA updates, native modules. Expo Router for file-based navigation. |
| Language | TypeScript | Type safety, better DX, consistency with web React experience. |
| UI styling | NativeWind (Tailwind CSS for RN) | Familiar utility-class approach, fast iteration, consistent design. |
| Backend / DB | Supabase (Postgres + PostGIS) | Relational data model, real-time subscriptions, built-in auth, storage, edge functions. PostGIS for geospatial queries. |
| Data fetching | TanStack React Query | Caching, background refetching, optimistic updates. Wraps Supabase calls. |
| Client state | Zustand | Lightweight, minimal boilerplate, good for UI state (filters, modals, onboarding progress). |
| Push notifications | Expo Notifications | Unified iOS/Android push API. Tokens stored in Supabase, triggered from Edge Functions. |
| Chat | Supabase Realtime | WebSocket subscriptions on `messages` table. No third-party chat SDK needed for MVP. |
| Testing | Jest + React Native Testing Library | Unit and component tests. Detox for E2E later. |
| CI/CD | EAS Build + EAS Update | Expo's build service for app store binaries. OTA updates for JS changes. |

## Database Schema

```
profiles
├── id (uuid, PK, = auth.uid())
├── email (text)
├── full_name (text)
├── avatar_url (text, nullable)
├── created_at (timestamptz)
└── updated_at (timestamptz)

families
├── id (uuid, PK)
├── name (text) — e.g. "The Müller Family"
├── description (text) — about the family
├── looking_for (text) — what they want in friend-families
├── location (geography(Point, 4326)) — PostGIS point
├── neighborhood (text) — human-readable area name
├── created_by (uuid, FK → profiles.id)
├── created_at (timestamptz)
└── updated_at (timestamptz)

family_members
├── id (uuid, PK)
├── family_id (uuid, FK → families.id)
├── profile_id (uuid, FK → profiles.id)
└── role (text) — 'admin' | 'member'

children
├── id (uuid, PK)
├── family_id (uuid, FK → families.id)
├── name (text)
├── birth_year (int) — year only, not exact birthday, for privacy
├── interests (text[], nullable) — array of interest tags
└── gender (text, nullable)

family_photos
├── id (uuid, PK)
├── family_id (uuid, FK → families.id)
├── storage_path (text) — path in Supabase Storage
├── display_order (int)
└── uploaded_at (timestamptz)

swipes
├── id (uuid, PK)
├── swiper_family_id (uuid, FK → families.id)
├── swiped_family_id (uuid, FK → families.id)
├── direction (text) — 'like' | 'pass'
├── created_at (timestamptz)
└── UNIQUE(swiper_family_id, swiped_family_id)

matches
├── id (uuid, PK)
├── family_a_id (uuid, FK → families.id)
├── family_b_id (uuid, FK → families.id)
├── matched_at (timestamptz)
└── UNIQUE(family_a_id, family_b_id) — ensure ordered: a < b

conversations
├── id (uuid, PK)
├── match_id (uuid, FK → matches.id, UNIQUE)
└── created_at (timestamptz)

messages
├── id (uuid, PK)
├── conversation_id (uuid, FK → conversations.id)
├── sender_id (uuid, FK → profiles.id)
├── content (text)
├── sent_at (timestamptz)
└── read_at (timestamptz, nullable)

push_tokens
├── id (uuid, PK)
├── profile_id (uuid, FK → profiles.id)
├── expo_token (text)
├── platform (text) — 'ios' | 'android'
└── updated_at (timestamptz)
```

### Key Indexes

- `families.location` — GIST index for PostGIS spatial queries
- `swipes(swiper_family_id, swiped_family_id)` — unique, fast lookup for match detection
- `messages(conversation_id, sent_at)` — ordered message retrieval
- `matches(family_a_id)` and `matches(family_b_id)` — find all matches for a family

### Match Detection

When a swipe is inserted with direction = 'like', a Postgres function checks if a reciprocal like exists:

```sql
-- Pseudocode for the trigger function
IF EXISTS (
  SELECT 1 FROM swipes
  WHERE swiper_family_id = NEW.swiped_family_id
    AND swiped_family_id = NEW.swiper_family_id
    AND direction = 'like'
) THEN
  INSERT INTO matches (family_a_id, family_b_id)
  VALUES (LEAST(NEW.swiper_family_id, NEW.swiped_family_id),
          GREATEST(NEW.swiper_family_id, NEW.swiped_family_id));
  INSERT INTO conversations (match_id) VALUES (new_match_id);
END IF;
```

### Row-Level Security (RLS)

Every table has RLS enabled. Key policies:
- Profiles: users can read any profile, update only their own.
- Families: members can read/update their own family. All users can read other families (for discovery).
- Swipes: users can insert for their own family, read only their own swipes.
- Matches: users can read matches involving their family.
- Messages: users can read/insert messages in conversations linked to their matches.
- Children: same access as the parent family.

## Project Structure

```
familymatch/
├── app/                          # Expo Router — file-based screens
│   ├── _layout.tsx               # Root layout (providers, auth guard)
│   ├── index.tsx                 # Entry redirect
│   ├── (auth)/
│   │   ├── _layout.tsx
│   │   ├── login.tsx
│   │   ├── signup.tsx
│   │   └── onboarding.tsx        # Post-signup family creation wizard
│   └── (tabs)/
│       ├── _layout.tsx           # Tab navigator
│       ├── discover/
│       │   └── index.tsx         # Swipe card stack
│       ├── matches/
│       │   ├── index.tsx         # Match list
│       │   └── [conversationId].tsx  # Chat screen
│       └── profile/
│           ├── index.tsx         # View own family profile
│           └── edit.tsx          # Edit family + children
├── components/
│   ├── ui/                       # Generic: Button, Input, Card, Avatar
│   ├── family/                   # FamilyCard, ChildBadge, PhotoCarousel
│   ├── discover/                 # SwipeCard, SwipeStack, MatchAnimation
│   └── chat/                     # MessageBubble, ChatInput, ConversationItem
├── lib/
│   ├── supabase.ts               # Supabase client initialization
│   ├── auth.tsx                  # Auth context/provider
│   ├── queries/                  # React Query hooks
│   │   ├── useFamily.ts
│   │   ├── useDiscover.ts
│   │   ├── useMatches.ts
│   │   └── useChat.ts
│   ├── services/                 # Business logic
│   │   ├── location.ts           # Expo Location helpers
│   │   ├── notifications.ts      # Push token registration
│   │   └── storage.ts            # Photo upload helpers
│   ├── types/                    # TypeScript types (mirroring DB schema)
│   │   └── database.ts
│   └── utils/
│       ├── distance.ts           # Format distance strings
│       └── dates.ts              # Age calculation from birth_year
├── assets/
│   ├── images/
│   └── fonts/
├── constants/
│   └── config.ts                 # App-wide constants (radius defaults, etc.)
├── supabase/
│   ├── migrations/               # SQL migration files (versioned)
│   │   ├── 00001_initial_schema.sql
│   │   ├── 00002_rls_policies.sql
│   │   ├── 00003_match_trigger.sql
│   │   └── 00004_postgis_indexes.sql
│   ├── functions/                # Supabase Edge Functions
│   │   ├── send-push/index.ts
│   │   └── on-match/index.ts
│   └── seed.sql                  # Dev seed data
├── CLAUDE.md                     # Claude Code project instructions
├── ARCHITECTURE.md               # This file
├── app.json                      # Expo config
├── tsconfig.json
├── package.json
└── .env.local                    # EXPO_PUBLIC_SUPABASE_URL, EXPO_PUBLIC_SUPABASE_ANON_KEY
```

## Development Phases

### Phase 1 — Foundation
Expo + Supabase setup, auth (signup/login/logout), tab navigation skeleton, base UI components.

### Phase 2 — Profiles
Family creation wizard, photo upload, children management, location capture, profile viewing.

### Phase 3 — Discovery & Matching
Card stack UI with swipe gestures, discovery feed (nearby families), swipe recording, match detection trigger, match celebration screen.

### Phase 4 — Chat
Conversation list, real-time messaging, read receipts, push notifications for new messages and matches.

### Phase 5 — Polish & Launch
Onboarding flow, distance filtering, empty states, error handling, loading skeletons, app icon/splash, TestFlight.

## Key Technical Decisions

- **No child photos in MVP.** Privacy-first approach — children are represented by name, age, and interests only.
- **Family-level swiping.** Swipes and matches happen between families, not individual profiles. This keeps the model simple and inclusive of different family structures.
- **Ordered match pairs.** `matches` always stores the lower UUID as `family_a_id`. This prevents duplicate matches and simplifies queries.
- **PostGIS for location.** Native Postgres geospatial support. Discovery query: `ST_DWithin(location, user_location, radius_meters)`.
- **Edge Functions for side effects.** Match creation triggers push notifications via an Edge Function, keeping the client simple.
