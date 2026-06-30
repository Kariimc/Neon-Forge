# Neon Forge UI — Claude Code Instructions

## Working principle — never assert unverified, verify before handing off
- NEVER state a claim that hasn't been verified — no facts from memory about file
  contents, repo/PR/API state, or whether something exists. Check first (read the
  file, query the API), then state. If it can't be verified, say so — never assert.
- Before giving the user anything to run, make it a true one-shot: trace every branch
  it could hit (existing folder, wrong remote, dirty tree, conflicts, already-installed)
  and handle each in the deliverable itself.
- Fix gaps on our end first. Never send a "do this, then patch what I missed" sequence.
- A deliverable should be copy-paste-and-done, not step-one-then-debug.

## Stack
React 19 + TanStack Start + Tailwind v4 + motion/react v12 + Radix UI
Cloudflare Workers (single worker, SSR). Bun as package manager.

## Key rules
- NEVER use `framer-motion` — always `motion/react` (package name: `motion`)
- NEVER put `ease: number[]` inside a `Variants` object — use string like `"easeOut"`
- NEVER add a second `style=` prop to the same JSX element — merge into one object
- NEVER use `whileHover` as a key inside `transition={{}}` — it's not valid in motion v12
- All components live in `app/src/components/demos*.tsx`
- Register in `app/src/lib/components-registry-v6.ts`
- Wire live demo in `app/src/components/component-card.tsx` demos map
- Design tokens: `var(--text-primary)`, `var(--bg-elevated)`, `var(--border-default)`, `var(--accent)`
- Accent color comes via `accent` prop (hex string) — never hardcode colors

## Token setup (one-time)
The deploy/watch/pull scripts read the Higgsfield token from the environment or a
local file — it is intentionally NOT committed to git. Set it up once:

```powershell
# Option A — environment variable (per session)
$env:HF_TOKEN = "your-higgsfield-token"

# Option B — local file (persists; gitignored)
"your-higgsfield-token" | Out-File -Encoding ascii token.txt
```

## Deploy
Run `.\deploy.ps1 "your message"` from the repo root.
Or run `.\watch.ps1` in a separate terminal for auto-deploy on save.

## Sync with Higgsfield
Run `.\pull.ps1` before starting work to get Supercomputer's latest changes.

## Adding a component — checklist
1. Write `export function YourDemo({ accent }: { accent: string })` in `app/src/components/demos6.tsx` (or create demos7.tsx)
2. Add entry to `ALL_COMPONENTS_V6` in `app/src/lib/components-registry-v6.ts`
3. Add `"your-slug": <YourDemo accent={accent} />` to the `demos` map in `app/src/components/component-card.tsx`
4. `.\deploy.ps1 "feat: add YourDemo"`

## Production URL
https://hidden-glow-736.higgsfield.app
