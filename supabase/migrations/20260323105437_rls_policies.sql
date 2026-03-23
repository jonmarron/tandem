-- ============================================================
-- Enable RLS on all tables
-- ============================================================
ALTER TABLE profiles       ENABLE ROW LEVEL SECURITY;
ALTER TABLE families       ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE children       ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_photos  ENABLE ROW LEVEL SECURITY;
ALTER TABLE swipes         ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches        ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations  ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages       ENABLE ROW LEVEL SECURITY;
ALTER TABLE push_tokens    ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- Helper: returns the family_id for the current user
-- (used in several policies to avoid repeated subqueries)
-- ============================================================
CREATE OR REPLACE FUNCTION my_family_id()
RETURNS uuid LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT family_id FROM family_members
  WHERE profile_id = auth.uid()
  LIMIT 1;
$$;

-- ============================================================
-- profiles
-- Any authenticated user can read any profile (needed for discovery).
-- Only the owner can update their own row.
-- ============================================================
CREATE POLICY "profiles: authenticated users can read all"
  ON profiles FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "profiles: owner can update own"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

-- ============================================================
-- families
-- All authenticated users can read families (for discovery).
-- Only family members can update their family.
-- Only authenticated users can insert (they become admin via trigger in a later migration).
-- ============================================================
CREATE POLICY "families: authenticated users can read all"
  ON families FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "families: members can update"
  ON families FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM family_members
      WHERE family_id = families.id
        AND profile_id = auth.uid()
    )
  );

CREATE POLICY "families: authenticated users can insert"
  ON families FOR INSERT
  TO authenticated
  WITH CHECK (created_by = auth.uid());

-- ============================================================
-- family_members
-- All authenticated users can read memberships (needed to verify membership).
-- Only the family admin can insert or delete members.
-- ============================================================
CREATE POLICY "family_members: authenticated users can read all"
  ON family_members FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "family_members: admin can insert"
  ON family_members FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM family_members fm
      WHERE fm.family_id = family_members.family_id
        AND fm.profile_id = auth.uid()
        AND fm.role = 'admin'
    )
    OR NOT EXISTS (
      SELECT 1 FROM family_members fm
      WHERE fm.family_id = family_members.family_id
    )
  );

CREATE POLICY "family_members: admin can delete"
  ON family_members FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM family_members fm
      WHERE fm.family_id = family_members.family_id
        AND fm.profile_id = auth.uid()
        AND fm.role = 'admin'
    )
  );

-- ============================================================
-- children
-- Same access pattern as the parent family.
-- ============================================================
CREATE POLICY "children: authenticated users can read all"
  ON children FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "children: family members can insert"
  ON children FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM family_members
      WHERE family_id = children.family_id
        AND profile_id = auth.uid()
    )
  );

CREATE POLICY "children: family members can update"
  ON children FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM family_members
      WHERE family_id = children.family_id
        AND profile_id = auth.uid()
    )
  );

CREATE POLICY "children: family members can delete"
  ON children FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM family_members
      WHERE family_id = children.family_id
        AND profile_id = auth.uid()
    )
  );

-- ============================================================
-- family_photos
-- Same access pattern as the parent family.
-- ============================================================
CREATE POLICY "family_photos: authenticated users can read all"
  ON family_photos FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "family_photos: family members can insert"
  ON family_photos FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM family_members
      WHERE family_id = family_photos.family_id
        AND profile_id = auth.uid()
    )
  );

CREATE POLICY "family_photos: family members can delete"
  ON family_photos FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM family_members
      WHERE family_id = family_photos.family_id
        AND profile_id = auth.uid()
    )
  );

-- ============================================================
-- swipes
-- Users can only insert swipes for their own family.
-- Users can only read their own family's swipes.
-- ============================================================
CREATE POLICY "swipes: own family can insert"
  ON swipes FOR INSERT
  TO authenticated
  WITH CHECK (swiper_family_id = my_family_id());

CREATE POLICY "swipes: own family can read"
  ON swipes FOR SELECT
  TO authenticated
  USING (swiper_family_id = my_family_id());

-- ============================================================
-- matches
-- Users can read matches that involve their own family.
-- Matches are created by the trigger (SECURITY DEFINER), not by users.
-- ============================================================
CREATE POLICY "matches: own family can read"
  ON matches FOR SELECT
  TO authenticated
  USING (
    family_a_id = my_family_id() OR family_b_id = my_family_id()
  );

-- ============================================================
-- conversations
-- Users can read conversations linked to their own matches.
-- ============================================================
CREATE POLICY "conversations: own matches can read"
  ON conversations FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM matches
      WHERE matches.id = conversations.match_id
        AND (matches.family_a_id = my_family_id() OR matches.family_b_id = my_family_id())
    )
  );

-- ============================================================
-- messages
-- Users can read and insert messages in their own conversations.
-- ============================================================
CREATE POLICY "messages: participants can read"
  ON messages FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM conversations
      JOIN matches ON matches.id = conversations.match_id
      WHERE conversations.id = messages.conversation_id
        AND (matches.family_a_id = my_family_id() OR matches.family_b_id = my_family_id())
    )
  );

CREATE POLICY "messages: participants can insert"
  ON messages FOR INSERT
  TO authenticated
  WITH CHECK (
    sender_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM conversations
      JOIN matches ON matches.id = conversations.match_id
      WHERE conversations.id = messages.conversation_id
        AND (matches.family_a_id = my_family_id() OR matches.family_b_id = my_family_id())
    )
  );

-- ============================================================
-- push_tokens
-- Full access only for own tokens.
-- ============================================================
CREATE POLICY "push_tokens: owner can read"
  ON push_tokens FOR SELECT
  TO authenticated
  USING (profile_id = auth.uid());

CREATE POLICY "push_tokens: owner can insert"
  ON push_tokens FOR INSERT
  TO authenticated
  WITH CHECK (profile_id = auth.uid());

CREATE POLICY "push_tokens: owner can update"
  ON push_tokens FOR UPDATE
  TO authenticated
  USING (profile_id = auth.uid());

CREATE POLICY "push_tokens: owner can delete"
  ON push_tokens FOR DELETE
  TO authenticated
  USING (profile_id = auth.uid());
