# FamilyMatch — Claude Code Instructions

## Project Overview

FamilyMatch is a React Native (Expo) mobile app that helps families connect with other families nearby. Parents create a family profile, browse other families in a swipeable card stack, and chat with matches. Built with Supabase (Postgres + PostGIS) as the backend.

Read `ARCHITECTURE.md` for the full technical reference (schema, project structure, tech decisions).

## Tech Stack

- **Mobile:** React Native, Expo (managed workflow), Expo Router, TypeScript
- **Styling:** NativeWind (Tailwind CSS for React Native)
- **Backend:** Supabase (Postgres, Auth, Storage, Realtime, Edge Functions, PostGIS)
- **Data fetching:** TanStack React Query
- **Client state:** Zustand
- **Push:** Expo Notifications
- **Testing:** Jest + React Native Testing Library

## Task Management

Tasks are tracked as GitHub Issues. Use the `gh` CLI to interact with them.

### Workflow

1. Before starting work, check for the next open issue:
   ```bash
   gh issue list --state open --label "phase:current" --sort created --json number,title,labels,body
   ```

2. When starting a task, assign yourself:
   ```bash
   gh issue edit <number> --add-label "status:in-progress"
   ```

3. When a task is complete, close it:
   ```bash
   gh issue close <number> --comment "Completed: <brief summary of what was done>"
   ```

4. If a task is blocked or needs clarification, add a comment:
   ```bash
   gh issue comment <number> --body "Blocked: <reason>"
   ```

### Labels

- `phase:1-foundation`, `phase:2-profiles`, etc. — which development phase
- `phase:current` — issues ready to work on now
- `type:feature`, `type:setup`, `type:database`, `type:test` — what kind of work
- `priority:high`, `priority:medium`, `priority:low` — importance
- `status:in-progress`, `status:blocked` — current state

### Milestones

Each phase is a GitHub Milestone. Check progress with:
```bash
gh api repos/:owner/:repo/milestones --jq '.[] | {title, open_issues, closed_issues}'
```

## Coding Conventions

### File Organization
- Screens go in `app/` following Expo Router file-based routing
- Reusable components go in `components/` organized by domain (ui/, family/, discover/, chat/)
- All Supabase interactions go through React Query hooks in `lib/queries/`
- Business logic and helpers go in `lib/services/` and `lib/utils/`
- TypeScript types mirroring the database go in `lib/types/database.ts`

### Naming
- Files: kebab-case for components (`family-card.tsx`), camelCase for utilities (`useFamily.ts`)
- Components: PascalCase (`FamilyCard`, `SwipeStack`)
- Hooks: `use` prefix (`useFamily`, `useDiscover`)
- Types: PascalCase, suffixed for clarity (`FamilyRow`, `SwipeInsert`, `MatchWithFamilies`)

### Patterns
- All data fetching through React Query — no raw `useEffect` + `useState` for async data
- Supabase client initialized once in `lib/supabase.ts`, imported everywhere
- Auth state managed via a React context provider in `lib/auth.tsx`
- Expo Router layouts handle auth guards — redirect to `(auth)` if not logged in
- Environment variables prefixed with `EXPO_PUBLIC_` for client access

### Styling with NativeWind
- Use Tailwind utility classes via `className` prop
- Create reusable styled components for repeated patterns
- Keep the design system consistent: use a constrained color palette defined in `tailwind.config.js`

### Database Migrations
- SQL migrations live in `supabase/migrations/` with numeric prefixes
- Each migration file should be self-contained and idempotent where possible
- Always include RLS policies for new tables
- Test migrations locally with `supabase db reset` before pushing

### Testing
- Write tests for business logic (utils, services) first
- Component tests for interactive elements (swipe gestures, forms)
- Use MSW or Supabase local for mocking API calls in tests

## Common Commands

```bash
# Development
npx expo start                          # Start dev server
npx expo start --clear                  # Start with cache cleared

# Supabase
npx supabase start                      # Start local Supabase
npx supabase db reset                   # Reset DB and replay migrations
npx supabase migration new <name>       # Create new migration file
npx supabase gen types typescript --local > lib/types/database.ts  # Generate types from schema

# Testing
npm test                                # Run Jest tests
npm test -- --watch                     # Watch mode

# Building
npx eas build --profile development     # Dev build for testing
npx eas build --profile preview         # Preview build (TestFlight/internal)
npx eas update                          # OTA update
```

## Important Notes

- Never commit `.env.local` — it contains Supabase keys
- The `matches` table always stores UUIDs in order: `family_a_id < family_b_id` to prevent duplicates
- No child photos in the MVP — children are represented by name, birth year, and interests only
- Location is stored as a PostGIS geography point (SRID 4326) — always use `ST_DWithin` for distance queries, not `ST_Distance` with a WHERE clause
- Match detection happens via a Postgres trigger on the `swipes` table, not in application code
