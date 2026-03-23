-- Enable PostGIS for geospatial queries
CREATE EXTENSION IF NOT EXISTS postgis;

-- ============================================================
-- profiles
-- ============================================================
CREATE TABLE profiles (
  id          uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email       text NOT NULL,
  full_name   text NOT NULL,
  avatar_url  text,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- families
-- ============================================================
CREATE TABLE families (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name          text NOT NULL,
  description   text NOT NULL DEFAULT '',
  looking_for   text NOT NULL DEFAULT '',
  location      geography(Point, 4326),
  neighborhood  text,
  created_by    uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX families_location_idx ON families USING GIST (location);

-- ============================================================
-- family_members
-- ============================================================
CREATE TABLE family_members (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id   uuid NOT NULL REFERENCES families(id) ON DELETE CASCADE,
  profile_id  uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role        text NOT NULL CHECK (role IN ('admin', 'member')),
  UNIQUE (family_id, profile_id)
);

-- ============================================================
-- children
-- ============================================================
CREATE TABLE children (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id   uuid NOT NULL REFERENCES families(id) ON DELETE CASCADE,
  name        text NOT NULL,
  birth_year  int NOT NULL,
  interests   text[],
  gender      text
);

-- ============================================================
-- family_photos
-- ============================================================
CREATE TABLE family_photos (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id      uuid NOT NULL REFERENCES families(id) ON DELETE CASCADE,
  storage_path   text NOT NULL,
  display_order  int NOT NULL DEFAULT 0,
  uploaded_at    timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- swipes
-- ============================================================
CREATE TABLE swipes (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  swiper_family_id  uuid NOT NULL REFERENCES families(id) ON DELETE CASCADE,
  swiped_family_id  uuid NOT NULL REFERENCES families(id) ON DELETE CASCADE,
  direction         text NOT NULL CHECK (direction IN ('like', 'pass')),
  created_at        timestamptz NOT NULL DEFAULT now(),
  UNIQUE (swiper_family_id, swiped_family_id)
);

-- ============================================================
-- matches
-- ============================================================
CREATE TABLE matches (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  family_a_id  uuid NOT NULL REFERENCES families(id) ON DELETE CASCADE,
  family_b_id  uuid NOT NULL REFERENCES families(id) ON DELETE CASCADE,
  matched_at   timestamptz NOT NULL DEFAULT now(),
  UNIQUE (family_a_id, family_b_id),
  CHECK (family_a_id < family_b_id)
);

CREATE INDEX matches_family_a_idx ON matches (family_a_id);
CREATE INDEX matches_family_b_idx ON matches (family_b_id);

-- ============================================================
-- conversations
-- ============================================================
CREATE TABLE conversations (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id    uuid NOT NULL UNIQUE REFERENCES matches(id) ON DELETE CASCADE,
  created_at  timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- messages
-- ============================================================
CREATE TABLE messages (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id  uuid NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id        uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content          text NOT NULL,
  sent_at          timestamptz NOT NULL DEFAULT now(),
  read_at          timestamptz
);

CREATE INDEX messages_conversation_sent_idx ON messages (conversation_id, sent_at);

-- ============================================================
-- push_tokens
-- ============================================================
CREATE TABLE push_tokens (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id  uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  expo_token  text NOT NULL,
  platform    text NOT NULL CHECK (platform IN ('ios', 'android')),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (profile_id, expo_token)
);
