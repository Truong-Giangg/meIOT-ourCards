# ourCards · meiot.site

A collection of small, personal, interactive web pages made for my girlfriend. One codebase, one Docker image, eleven pages, one shared life.

```
      ♡           ✧             ♡
   ┌─────────────────────────────────┐
   │   for her, from home            │
   │   Hanoi ✈ Milan  ·  2026–2028   │
   │   ♡  our little cat Núp         │
   └─────────────────────────────────┘
```

---

## Pages

Live at `https://meiot.site/*`

| # | URL | What it does |
|---|-----|--------------|
| 1 | [`/birthday.html`](https://meiot.site/birthday.html) | Interactive birthday card — the original, animated scene with cake, room, gift and confetti |
| 2 | [`/sleep.html`](https://meiot.site/sleep.html) | Help her fall asleep — jumping sheep counter, procedural ambient sounds (rain, ocean, brown noise, wind), sleep timer that dims and stops everything, screen wake lock |
| 3 | [`/nup.html`](https://meiot.site/nup.html) | Our cat Núp — greeting by hour of day, tappable Núp with soft purr, mood chips, daily care schedule with local persistence, vet-visit countdown, diary log |
| 4 | [`/fiting.html`](https://meiot.site/fiting.html) | Encouragement during her Master's abroad — live countdown to graduation (3 Sep 2028), journey progress bar with plane, rotating quotes in EN + IT, milestone checklist, daily "I did my best" streak, letter from home |
| 5 | [`/christmas.html`](https://meiot.site/christmas.html) | Christmas — animated snowfall canvas, clickable tree lights, gift box that opens to reveal a message, procedural bell tones + crackling fire, wish list |
| 6 | [`/newyear.html`](https://meiot.site/newyear.html) | New Year — countdown to midnight, canvas fireworks with sound, resolutions list, live Milan clock so she knows when midnight is where she is |
| 7 | [`/valentine.html`](https://meiot.site/valentine.html) | Valentine's — floating hearts, days-together counter, 30 rotating "reasons I love you", real finger-drag scratch card, permanent letter |
| 8 | [`/halloween.html`](https://meiot.site/halloween.html) | Halloween — carve your own jack-o-lantern, toggle candle glow, happy/spooky mouth, tap-to-open door with random treat message, costume picker, rotating dad jokes |
| 9 | [`/miss.html`](https://meiot.site/miss.html) | I miss you — pulsing moon, live Hanoi + Milan clocks with context messages, distance visualization, auto-rotating memories, mutual love letters |
| 10 | [`/women.html`](https://meiot.site/women.html) | International Women's Day — falling flower petals, blooming SVG bouquet she can add to, 12 quality-word carousel, verse card, wishes |
| 11 | [`/game.html`](https://meiot.site/game.html) | Mini games — memory match, catch falling hearts (drag basket, avoid rocks), rock-paper-scissors first-to-5, guess a personal word |

---

## Design principles

- **One user.** Written for her, not for the world.
- **iPhone first.** Target device is iPhone 15 Pro. Safe-area insets, `100dvh` (no URL bar jumps), one-handed reach, ≥ 44 px tap targets, no hover-only interactions.
- **Warm, calm, personal.** Dark themes for night pages, soft palettes for day pages.
- **Small dependencies.** Inline CSS/JS per page, procedural audio via Web Audio API, SVG over PNG, `localStorage` for persistence.
- **Do, not just read.** Every page has an interaction that means something.

---

## Tech

- **Bundler:** [Parcel](https://parceljs.org/) (zero-config, per-page HTML entries)
- **Web server (runtime):** unprivileged nginx (from `nginxinc/nginx-unprivileged:alpine`), port 8080 in container
- **Container:** multi-stage `Dockerfile`, final image ~85 MB
- **Deploy:** Docker Compose, publishes container 8080 to host 80
- **No framework, no build magic.** Every page is a self-contained HTML file with inline `<style>` and `<script type="module">`.

Project layout:

```
ourCards/
├── src/                      # source pages (edit here)
│   ├── template.html         # birthday page template (goes through builder)
│   ├── sleep.html            # each remaining page is self-contained
│   ├── nup.html
│   ├── fiting.html
│   ├── christmas.html
│   ├── newyear.html
│   ├── valentine.html
│   ├── halloween.html
│   ├── miss.html
│   ├── women.html
│   ├── game.html
│   ├── resources/            # favicons, images, sfx
│   ├── scss/                 # birthday-page styles
│   └── js/                   # birthday-page scripts
├── builder/                  # renders template.html → index.html with .env vars
├── deploy/nginx.conf         # production nginx config served in the image
├── scripts/health-check.sh   # quick uptime check across all URLs
├── local/                    # local assets (sample-pic.jpeg, etc.)
├── docs/                     # design notes, roadmap
├── Dockerfile
├── docker-compose.yml
├── example.env
├── package.json
└── README.md
```

---

## Local development

```bash
npm install
cp example.env .env       # set NAME, PIC
npm run watch             # Parcel dev server, all pages
# open http://localhost:1234
```

Or the Docker dev profile (hot-reload without needing Node on the host):

```bash
docker compose --profile dev up
# open http://localhost:1234
```

---

## Production build & deploy

Everything is baked into one image. On the server:

```bash
# 1. Get the code onto the server (from your laptop)
rsync -av --exclude node_modules --exclude .parcel-cache --exclude dist --exclude .git \
  ./ourCards/ user@server:~/ourCards/

# 2. On the server
cd ~/ourCards
cp example.env .env      # first time; set NAME, PIC
docker compose up -d --build
docker compose logs -f   # watch it come up
```

The container publishes port 80 (both IPv4 and IPv6):

```
0.0.0.0:80->8080/tcp, [::]:80->8080/tcp
```

Point `meiot.site` DNS at the server IP (A + AAAA records), and put a TLS terminator in front for HTTPS. Simplest option:

```caddyfile
meiot.site {
    reverse_proxy localhost:80
}
```

Or use Cloudflare Tunnel — the repo already has a sample `cloudflared-config.yml`.

### Ops cheatsheet

```bash
docker compose ps                # status
docker compose logs -f           # tail logs
docker compose restart           # after config change
docker compose down              # stop
docker compose up -d --build     # after code change
```

Change host port on the fly (if 80 is taken):

```yaml
# docker-compose.yml
ports:
  - "8080:8080"
```

---

## Health check

Verify all pages are reachable:

```bash
./scripts/health-check.sh                  # https://meiot.site
./scripts/health-check.sh http://localhost # local
```

Sample output:

```
Checking https://meiot.site
URL                      HTTP   TIME     SIZE      STATUS
----------------------------------------------------------------------
/                        200    142ms    4.3KB     OK
birthday.html            200    98ms     4.3KB     OK
sleep.html               200    115ms    24.9KB    OK
...
✓ All 12 pages healthy
```

Exit code 0 if all healthy, 1 if any fail. Handy in cron:

```
*/5 * * * * /home/user/ourCards/scripts/health-check.sh > /dev/null || alert.sh
```

Or a quick one-liner without the script:

```bash
for p in "" birthday.html sleep.html nup.html fiting.html christmas.html \
         newyear.html valentine.html halloween.html miss.html women.html game.html; do
  code=$(curl -s -L -o /dev/null -w "%{http_code}" "https://meiot.site/$p")
  [ "$code" -ge 200 ] && [ "$code" -lt 400 ] && s="OK" || s="FAIL"
  printf "%-16s %s %s\n" "${p:-/}" "$code" "$s"
done
```

---

## Adding a new page

1. Create `src/<page>.html` — inline CSS/JS is fine, one file per page
2. Add its filename to both `parcel` commands in `package.json`
3. Add it to the `parcel build` line in `Dockerfile`
4. Rebuild: `docker compose up -d --build`
5. Update this README

The nginx config serves any `*.html` in `dist/` automatically, no config changes needed.

---

## Credits

- Original birthday card template based on [`AnshumanMahato/Happy-Birthday-Card`](https://github.com/AnshumanMahato/Happy-Birthday-Card)
- Everything else, hand-built for her

Made with love, from home to Milan. ♡
