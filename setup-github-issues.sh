#!/bin/bash
# ============================================================================
# FamilyMatch — GitHub Issues Bootstrap Script
# ============================================================================
# Prerequisites:
#   1. Install GitHub CLI: https://cli.github.com/
#   2. Authenticate: gh auth login
#   3. Create your repo: gh repo create familymatch --private --clone
#   4. cd into the repo and run: bash setup-github-issues.sh
# ============================================================================

set -e

echo "🏠 FamilyMatch — Setting up GitHub Issues..."
echo ""

# ============================================================================
# LABELS
# ============================================================================
echo "📌 Creating labels..."

# Phase labels
gh label create "phase:1-foundation"  --color "1D76DB" --description "Phase 1: Project setup, auth, navigation" --force
gh label create "phase:2-profiles"    --color "5319E7" --description "Phase 2: Family profiles, photos, children" --force
gh label create "phase:3-discovery"   --color "D93F0B" --description "Phase 3: Swipe UI, matching, discovery feed" --force
gh label create "phase:4-chat"        --color "0E8A16" --description "Phase 4: Real-time messaging, push notifications" --force
gh label create "phase:5-polish"      --color "FBCA04" --description "Phase 5: Onboarding, filtering, launch prep" --force
gh label create "phase:current"       --color "B60205" --description "Ready to work on now" --force

# Type labels
gh label create "type:setup"          --color "C2E0C6" --description "Project/tooling setup" --force
gh label create "type:feature"        --color "A2EEEF" --description "New feature implementation" --force
gh label create "type:database"       --color "D4C5F9" --description "Schema, migrations, RLS policies" --force
gh label create "type:test"           --color "FEF2C0" --description "Testing" --force
gh label create "type:docs"           --color "0075CA" --description "Documentation" --force
gh label create "type:refactor"       --color "E6E6E6" --description "Code improvement without feature change" --force

# Priority labels
gh label create "priority:high"       --color "B60205" --description "Must have for this phase" --force
gh label create "priority:medium"     --color "FBCA04" --description "Important but not blocking" --force
gh label create "priority:low"        --color "0E8A16" --description "Nice to have" --force

# Status labels
gh label create "status:in-progress"  --color "D93F0B" --description "Currently being worked on" --force
gh label create "status:blocked"      --color "000000" --description "Blocked by dependency or question" --force

echo "✅ Labels created."
echo ""

# ============================================================================
# MILESTONES
# ============================================================================
echo "🏁 Creating milestones..."

gh api repos/:owner/:repo/milestones --method POST --field title="Phase 1 — Foundation"              --field description="Expo + Supabase setup, auth flow, navigation skeleton, base UI components." --field state="open" 2>/dev/null || echo "  (Phase 1 milestone may already exist)"
gh api repos/:owner/:repo/milestones --method POST --field title="Phase 2 — Profiles"                --field description="Family creation wizard, photo upload, children management, location capture." --field state="open" 2>/dev/null || echo "  (Phase 2 milestone may already exist)"
gh api repos/:owner/:repo/milestones --method POST --field title="Phase 3 — Discovery & Matching"    --field description="Card stack UI, swipe gestures, match detection, discovery feed." --field state="open" 2>/dev/null || echo "  (Phase 3 milestone may already exist)"
gh api repos/:owner/:repo/milestones --method POST --field title="Phase 4 — Chat"                    --field description="Real-time messaging, conversation list, push notifications." --field state="open" 2>/dev/null || echo "  (Phase 4 milestone may already exist)"
gh api repos/:owner/:repo/milestones --method POST --field title="Phase 5 — Polish & Launch"         --field description="Onboarding, filtering, empty states, error handling, TestFlight." --field state="open" 2>/dev/null || echo "  (Phase 5 milestone may already exist)"

echo "✅ Milestones created."
echo ""

# ============================================================================
# PHASE 1 ISSUES
# ============================================================================
echo "📋 Creating Phase 1 issues..."

# Get the milestone number for Phase 1
PHASE1_MILESTONE=$(gh api repos/:owner/:repo/milestones --jq '.[] | select(.title | startswith("Phase 1")) | .number')

# --- Issue 1: Initialize Expo project ---
gh issue create \
  --title "Initialize Expo project with TypeScript and Expo Router" \
  --label "phase:1-foundation,phase:current,type:setup,priority:high" \
  --milestone "Phase 1 — Foundation" \
  --body '## Description
Create the Expo project with the managed workflow, TypeScript, and Expo Router.

## Tasks
- [ ] Run `npx create-expo-app familymatch -t tabs` (or blank + manual Expo Router setup)
- [ ] Verify TypeScript is configured (`tsconfig.json`)
- [ ] Install and configure Expo Router for file-based navigation
- [ ] Set up the `app/` directory structure per ARCHITECTURE.md
- [ ] Verify the app runs on iOS simulator and/or Android emulator
- [ ] Add `.env.local` to `.gitignore`

## Acceptance Criteria
- App boots and shows a placeholder tab navigator with 3 tabs: Discover, Matches, Profile
- TypeScript compiles with no errors
- File-based routing works (each tab renders its own screen)

## Learning Notes
Expo Router works very similarly to Next.js App Router — files in `app/` become routes, `_layout.tsx` files define shared layouts (like `layout.tsx` in Next.js). The `(group)` folder syntax creates route groups without affecting the URL.'

# --- Issue 2: Install and configure NativeWind ---
gh issue create \
  --title "Install and configure NativeWind (Tailwind CSS for RN)" \
  --label "phase:1-foundation,phase:current,type:setup,priority:high" \
  --milestone "Phase 1 — Foundation" \
  --body '## Description
Set up NativeWind so we can use Tailwind utility classes for styling throughout the app.

## Tasks
- [ ] Install NativeWind v4 and its peer dependencies
- [ ] Create `tailwind.config.js` with content paths pointing to `app/` and `components/`
- [ ] Configure the Babel plugin and Metro bundler as per NativeWind docs
- [ ] Define the app color palette in the Tailwind config (primary, secondary, background, text, accent)
- [ ] Verify `className` prop works on a test component
- [ ] Add a `global.css` file with Tailwind directives

## Acceptance Criteria
- A component using `className="bg-primary text-white p-4 rounded-xl"` renders correctly
- Colors from the custom palette are accessible
- Hot reload works with style changes

## Learning Notes
NativeWind v4 is a significant rewrite. It compiles Tailwind classes to React Native StyleSheet objects at build time. Not all web Tailwind classes work (no `grid`, limited `position`) but flexbox, spacing, colors, typography all work great.'

# --- Issue 3: Set up Supabase project ---
gh issue create \
  --title "Set up Supabase project (local + remote)" \
  --label "phase:1-foundation,phase:current,type:setup,priority:high" \
  --milestone "Phase 1 — Foundation" \
  --body '## Description
Initialize Supabase for both local development and a remote project.

## Tasks
- [ ] Create a Supabase project at https://supabase.com/dashboard
- [ ] Install Supabase CLI: `npm install -g supabase`
- [ ] Run `npx supabase init` in the project root
- [ ] Start local Supabase: `npx supabase start`
- [ ] Enable the PostGIS extension in the initial migration
- [ ] Store the Supabase URL and anon key in `.env.local` as `EXPO_PUBLIC_SUPABASE_URL` and `EXPO_PUBLIC_SUPABASE_ANON_KEY`
- [ ] Install `@supabase/supabase-js` in the Expo project
- [ ] Create `lib/supabase.ts` that initializes and exports the Supabase client
- [ ] Verify the client can connect (simple health check or `supabase.auth.getSession()`)

## Acceptance Criteria
- `npx supabase start` runs and local Supabase is accessible
- The Expo app can import the Supabase client and call `getSession()` without errors
- PostGIS extension is enabled in the local database

## Learning Notes
Supabase CLI gives you a full local Postgres + Auth + Storage + Realtime stack via Docker. This is your development environment. The remote project is for staging/production. Always develop against local first, then push migrations to remote with `npx supabase db push`.'

# --- Issue 4: Create initial database schema ---
gh issue create \
  --title "Create initial database schema migration" \
  --label "phase:1-foundation,phase:current,type:database,priority:high" \
  --milestone "Phase 1 — Foundation" \
  --body '## Description
Write the first SQL migration that creates all core tables per the schema in ARCHITECTURE.md.

## Tasks
- [ ] Create migration: `npx supabase migration new initial_schema`
- [ ] Define all tables: profiles, families, family_members, children, family_photos, swipes, matches, conversations, messages, push_tokens
- [ ] Enable PostGIS: `CREATE EXTENSION IF NOT EXISTS postgis;`
- [ ] Add the `location` column as `geography(Point, 4326)` on families
- [ ] Add GIST index on `families.location`
- [ ] Add unique constraints on swipes and matches as per ARCHITECTURE.md
- [ ] Add indexes on messages(conversation_id, sent_at), matches(family_a_id), matches(family_b_id)
- [ ] Run `npx supabase db reset` to test the migration
- [ ] Generate TypeScript types: `npx supabase gen types typescript --local > lib/types/database.ts`

## Acceptance Criteria
- `npx supabase db reset` runs cleanly with no errors
- All tables exist with correct columns, types, and constraints
- TypeScript types file is generated and reflects the schema
- PostGIS extension is active and the location column accepts geographic points

## Notes
Remember: `matches` stores UUIDs in order (`family_a_id < family_b_id`). Add a CHECK constraint: `CHECK (family_a_id < family_b_id)`.'

# --- Issue 5: Set up RLS policies ---
gh issue create \
  --title "Set up Row-Level Security (RLS) policies" \
  --label "phase:1-foundation,phase:current,type:database,priority:high" \
  --milestone "Phase 1 — Foundation" \
  --body '## Description
Enable RLS on all tables and create security policies so users can only access data they are authorized to see.

## Tasks
- [ ] Create migration: `npx supabase migration new rls_policies`
- [ ] Enable RLS on every table: `ALTER TABLE <table> ENABLE ROW LEVEL SECURITY;`
- [ ] **profiles:** SELECT for all authenticated users, UPDATE only own row (`auth.uid() = id`)
- [ ] **families:** SELECT for all authenticated, INSERT/UPDATE only for family members (via family_members join)
- [ ] **family_members:** SELECT for all authenticated, INSERT/DELETE only for family admin
- [ ] **children:** same access pattern as the parent family
- [ ] **family_photos:** same access pattern as the parent family
- [ ] **swipes:** INSERT only for own family, SELECT only own swipes
- [ ] **matches:** SELECT only matches involving own family
- [ ] **conversations:** SELECT only conversations linked to own matches
- [ ] **messages:** SELECT/INSERT only in own conversations
- [ ] **push_tokens:** full access only for own tokens
- [ ] Test policies with different user contexts using Supabase SQL editor

## Acceptance Criteria
- All tables have RLS enabled
- A user cannot read another family'\''s swipes
- A user cannot read messages from conversations they are not part of
- A user can read all family profiles (for discovery)
- Policies pass manual testing in Supabase SQL editor or via the client

## Learning Notes
RLS is Postgres-native security. Every query is automatically filtered by the policy — you do not need to add WHERE clauses in your app code. The `auth.uid()` function returns the currently authenticated user'\''s ID. This is one of Supabase'\''s most powerful features for security.'

# --- Issue 6: Implement auth flow ---
gh issue create \
  --title "Implement authentication flow (signup, login, logout)" \
  --label "phase:1-foundation,phase:current,type:feature,priority:high" \
  --milestone "Phase 1 — Foundation" \
  --body '## Description
Build the complete auth flow using Supabase Auth, with screens for signup, login, and automatic session management.

## Tasks
- [ ] Create `lib/auth.tsx` with an AuthProvider context that:
  - Listens to `supabase.auth.onAuthStateChange`
  - Exposes `session`, `user`, `loading`, `signUp`, `signIn`, `signOut`
- [ ] Wrap the root layout (`app/_layout.tsx`) with `<AuthProvider>`
- [ ] Build `app/(auth)/login.tsx` screen with email + password form
- [ ] Build `app/(auth)/signup.tsx` screen with email + password + full name
- [ ] On signup, create a row in the `profiles` table via a Supabase trigger or in the signup handler
- [ ] Implement auth guard in `app/_layout.tsx`: redirect to `(auth)/login` if no session, redirect to `(tabs)` if session exists
- [ ] Add a logout button on the profile tab (placeholder screen is fine)
- [ ] Handle loading state (splash/loading screen while checking session)
- [ ] Handle error states (invalid credentials, email already exists, network error)

## Acceptance Criteria
- New user can sign up with email + password
- Existing user can log in
- After login, user is redirected to the main tab navigator
- After logout, user is redirected to login
- Session persists across app restarts (Supabase handles this via secure storage)
- Error messages are shown for invalid inputs

## Learning Notes
Supabase Auth uses JWTs stored in secure device storage (AsyncStorage on RN). The `onAuthStateChange` listener fires whenever the auth state changes (login, logout, token refresh). This pattern is very similar to Firebase Auth or NextAuth session management. The auth guard in the root layout is analogous to middleware in Next.js.'

# --- Issue 7: Create a profile on signup ---
gh issue create \
  --title "Auto-create profile row on user signup" \
  --label "phase:1-foundation,phase:current,type:database,priority:medium" \
  --milestone "Phase 1 — Foundation" \
  --body '## Description
Ensure a `profiles` row is created automatically when a new user signs up, using a Postgres trigger on the auth.users table.

## Tasks
- [ ] Create migration: `npx supabase migration new create_profile_trigger`
- [ ] Write a trigger function that inserts into `profiles` when a new row appears in `auth.users`
- [ ] Map `auth.users.id` → `profiles.id`, `auth.users.email` → `profiles.email`, and extract `full_name` from `raw_user_meta_data`
- [ ] Pass `full_name` in the signup metadata: `supabase.auth.signUp({ email, password, options: { data: { full_name } } })`
- [ ] Test: sign up a new user and verify a profile row exists
- [ ] Handle edge case: what if the trigger fails? (Add error handling or a fallback in the app)

## Acceptance Criteria
- Signing up automatically creates a matching `profiles` row
- The profile has the correct `id`, `email`, and `full_name`
- No manual profile creation step is needed in the app after signup'

# --- Issue 8: Install and configure React Query ---
gh issue create \
  --title "Install and configure TanStack React Query" \
  --label "phase:1-foundation,phase:current,type:setup,priority:medium" \
  --milestone "Phase 1 — Foundation" \
  --body '## Description
Set up React Query as the data-fetching layer. All Supabase calls will go through React Query hooks.

## Tasks
- [ ] Install `@tanstack/react-query`
- [ ] Create a `QueryClientProvider` in the root layout
- [ ] Configure sensible defaults: `staleTime: 5 * 60 * 1000`, `retry: 1`
- [ ] Install React Query DevTools for development (if available for RN, or use Flipper plugin)
- [ ] Create a sample query hook (e.g., `useProfile`) that fetches the current user'\''s profile from Supabase
- [ ] Verify the hook works on the Profile tab placeholder screen

## Acceptance Criteria
- React Query provider wraps the entire app
- A sample `useProfile` hook fetches and displays the current user'\''s name
- Loading and error states are handled in the sample

## Learning Notes
React Query handles caching, background refetching, and stale data management. Think of it as replacing the `useEffect(() => { fetch(...) }, [])` + `useState` pattern with something much more robust. The `queryKey` is like a cache key — same key = same cached data.'

# --- Issue 9: Install Zustand ---
gh issue create \
  --title "Install and configure Zustand for client state" \
  --label "phase:1-foundation,phase:current,type:setup,priority:low" \
  --milestone "Phase 1 — Foundation" \
  --body '## Description
Set up Zustand for lightweight client-side state (UI state, not server state).

## Tasks
- [ ] Install `zustand`
- [ ] Create a sample store (e.g., `useAppStore` with a `hasCompletedOnboarding` flag)
- [ ] Demonstrate usage in one component
- [ ] Document the convention: React Query for server state, Zustand for UI state

## Acceptance Criteria
- Zustand store is accessible from any component
- Clear separation: server data → React Query, UI state → Zustand'

# --- Issue 10: Build base UI components ---
gh issue create \
  --title "Build base UI component library" \
  --label "phase:1-foundation,phase:current,type:feature,priority:medium" \
  --milestone "Phase 1 — Foundation" \
  --body '## Description
Create the foundational UI components that will be reused across all screens.

## Tasks
- [ ] `components/ui/Button.tsx` — primary, secondary, outline, disabled variants. Pressable with press animation.
- [ ] `components/ui/Input.tsx` — text input with label, error message, and focus styling
- [ ] `components/ui/Card.tsx` — rounded container with shadow, used for family cards and list items
- [ ] `components/ui/Avatar.tsx` — circular image with fallback initials
- [ ] `components/ui/LoadingSpinner.tsx` — centered activity indicator
- [ ] `components/ui/ScreenContainer.tsx` — safe area wrapper with consistent padding
- [ ] All components styled with NativeWind
- [ ] All components typed with proper TypeScript props

## Acceptance Criteria
- Each component renders correctly and is visually consistent
- Components handle edge cases (long text, missing image, disabled state)
- TypeScript props enforce correct usage
- Components are used in at least one screen (auth screens are a good place)

## Notes
Keep it simple. These do not need to be a full design system — just enough to move fast with a consistent look. We can refine later in Phase 5.'

# --- Issue 11: Set up Supabase Storage ---
gh issue create \
  --title "Set up Supabase Storage bucket for family photos" \
  --label "phase:1-foundation,phase:current,type:setup,priority:low" \
  --milestone "Phase 1 — Foundation" \
  --body '## Description
Configure a Supabase Storage bucket for family profile photos and user avatars. This sets the groundwork for Phase 2 photo upload.

## Tasks
- [ ] Create a `family-photos` bucket in Supabase Storage (via dashboard or migration)
- [ ] Create an `avatars` bucket for profile pictures
- [ ] Set up storage policies: authenticated users can upload to their own folder, anyone can read
- [ ] Create a helper in `lib/services/storage.ts` with `getPublicUrl(path)` utility
- [ ] Verify upload + read works with a test file via Supabase dashboard

## Acceptance Criteria
- Both buckets exist and are accessible
- RLS policies allow upload by authenticated users and public read
- `getPublicUrl` returns a working URL for an uploaded file'

echo ""
echo "✅ All Phase 1 issues created!"
echo ""
echo "============================================================================"
echo "📊 Summary"
echo "============================================================================"
echo ""
echo "Labels:     17 created (phase, type, priority, status)"
echo "Milestones: 5 created (one per development phase)"
echo "Issues:     11 created (all Phase 1, tagged 'phase:current')"
echo ""
echo "🚀 Next steps:"
echo "  1. Copy CLAUDE.md and ARCHITECTURE.md into your repo root"
echo "  2. Commit and push"
echo "  3. Open Claude Code and start with: 'Check the open issues and work on the first one'"
echo ""
echo "To see your board:"
echo "  gh issue list --label 'phase:current' --state open"
echo ""
