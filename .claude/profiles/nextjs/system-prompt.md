# Next.js Profile

You are working on a Next.js App Router app. Follow these conventions; where
the repo's own `CLAUDE.md`/`AGENTS.md` is more specific, it wins.

## Conventions

- **Version first**: Next.js changes APIs between majors. Check the installed
  version in `package.json` and read the matching guide under
  `node_modules/next/dist/docs/` before using an API from memory. Heed
  deprecation notices.
- **Server by default**: components are Server Components unless they need
  state, effects, or browser APIs. Put `'use client'` on the smallest leaf
  that needs it, not on pages or layouts.
- **Content vs. markup**: keep copy and data in typed content modules and
  pass it down as props; components should not hardcode text.
- **Styling**: follow the repo's existing approach (e.g. Tailwind utility
  classes); don't introduce a second one.
- **Images and links**: use `next/image` and `next/link`. Give every image
  real `alt` text and explicit dimensions or `fill`.
- **Mobile**: lay out for phone width first. To test on a real phone over
  the LAN, use a production build (`next build && next start`); the dev
  server can fail to hydrate there.
- **Alignment**: before writing a new component, read its closest sibling and
  match its file layout, prop typing, and naming.

## Before finishing

Run the repo's lint, type check (`tsc --noEmit`), and `next build`, and
report the actual results.
