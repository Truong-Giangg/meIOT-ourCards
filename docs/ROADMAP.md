# meiot.site — Pages Roadmap

A collection of small, personal, interactive web pages made for my girlfriend and our life together. Each page lives at its own URL under `https://meiot.site/`.

> Status legend: ✅ done · 🚧 in progress · 📝 planned

---

## Page list

| # | URL | Theme | Status |
|---|-----|-------|--------|
| 1 | `/birthday.html` | Birthday card | ✅ done |
| 2 | `/nup.html` | Núp the cat — care & health | ✅ done |
| 3 | `/christmas.html` | Christmas — snow, tree, gift | ✅ done |
| 4 | `/newyear.html` | New Year — countdown & fireworks | ✅ done |
| 5 | `/sleep.html` | Help her fall asleep | ✅ done |
| 6 | `/fiting.html` | Long-distance encouragement while she studies master's abroad | ✅ done |
| 7 | `/game.html` | Small love-themed mini games | ✅ done |
| 8 | `/valentine.html` | Valentine's Day | ✅ done |
| 9 | `/halloween.html` | Halloween — cute-spooky | ✅ done |
| 10 | `/miss.html` | I miss you — moon, distance, memories | ✅ done |
| 11 | `/women.html` | International Women's Day (Mar 8) | ✅ done |

---

## Key context

- **She lives in Italy** (started her Master's on **3 September 2026**, 2-year program → graduation around **3 September 2028**).
- **Our cat Núp** lives with me. Annual vet checkup is tracked on `/nup.html`.
- Target device: **iPhone 15 Pro** (393 × 852 CSS px, dynamic island). Every page tested for that viewport.

---

## Architecture

All pages ship from the same repo (`Happy-Birthday-Card`) and Parcel build.

- **Source**: each page is a self-contained HTML file in `src/`
- **Build**: `parcel build src/*.html` outputs everything to `dist/`
- **Serving**: nginx serves `dist/`; `/birthday.html` alias points to `index.html`
- **Shared assets**: favicons, fonts in `src/resources/`

### Adding a page

1. Create `src/<page>.html`
2. Add it to Parcel entries in `package.json` (`watch:parcel`, `build:parcel`)
3. Add to `Dockerfile` build command
4. Update `deploy/nginx.conf` only if you need URL rewriting
5. `npm run init-index-local && npm run build:parcel` and serve `dist/`

---

## Design principles

- **One user.** Write for her, not for the world.
- **iPhone first.** Safe-area padding, `100dvh`, one-handed reach, big tap targets.
- **Warm, calm, personal.** Dark for night, soft for day, no jarring animation.
- **Small deps.** Inline CSS/JS, procedural audio via Web Audio API, SVG over PNG.
- **Do, not just read.** Each page has an interaction that means something.

---

Last updated: 2026-09-27
