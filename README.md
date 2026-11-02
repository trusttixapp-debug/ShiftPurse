# ShiftPurse

A phone-first app for tracking shifts, clock-ins, pay and budget across three jobs: Thirst (club), Avila (restaurant) and Co-op (supermarket).

It's a single static page (`index.html`) with no build step, hosted on GitHub Pages and added to the iPhone home screen as a full-screen web app.

## Features

- **Rosters:** upload a roster photo or PDF. Claude reads it, including handwriting, and keeps only your shifts.
- **Clocking in:** you can only clock in during a rostered shift, and the app clocks you out automatically if you forget.
- **Pay:** pay per job, paydays for each pay schedule (weekly, every 2, 3 or 4 weeks, or monthly), and payments you've logged.
- **Budget:** rent and debts are planned for you. Every payment you log is split automatically.
- **Alerts:** shifts go into the iPhone Calendar app with reminders.

## Files

| Path | What it is |
|---|---|
| `index.html` | The whole app: HTML, CSS and JS |
| `manifest.webmanifest` | App name, icon and colours for the home screen |
| `sw.js` | Service worker that makes the app work offline |
| `icons/` | Home-screen icons and iPhone splash screens |
| `tools/make-icons.ps1` | Redraws everything in `icons/` (run it in Windows PowerShell) |

## Data

- **Your data:** stays in the phone's local storage. To keep it safe, go to Settings → Back up, which saves a JSON file. Settings → Restore loads that file back.
- **The Claude API key:** stored in `localStorage` under `sp.apikey`. It is never included in backups. Requests go directly from the phone to `api.anthropic.com`.

## Running locally

```bash
npx serve .
```

Then open the address it prints. The service worker only registers over HTTPS, so offline mode is tested on GitHub Pages.
