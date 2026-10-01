# Hawkeye View

A Claude Code skill that answers business questions straight out of Superset — no dashboard
clicking, no manual chart-hunting, no "let me go check and get back to you."

## The problem this solves

Every BI dashboard tool has the same failure mode: the data is real, but getting to it isn't.
Someone wants one number — "what's signup-to-NAP conversion this month" — and the actual path to
that number is: remember which of 169 dashboards has it, open it, find the right tab, read a chart
that may or may not render the value as text, and hope the date range matches what was actually
asked. Multiply that by every question anyone on a team has in a week, and most of it is
dashboard-archaeology, not analysis.

**Hawkeye turns that into a conversation.** Ask it the question in plain language. It finds the
right chart, pulls the real number, and tells you — in a sentence or a table, not a tour of
Superset's UI.

## How it's fast — the core mechanism

The first build of this drove a real browser: open Superset, click into a chart, use its "View as
table" option, read the rendered HTML. It worked, but it was slow (~9-10 seconds per chart) and
fragile (a Superset UI bug meant the data modal would silently show stale values from a previous
chart unless the whole page was reloaded between every single pull).

**The actual fix: stop using the browser for data at all.** A logged-in Superset session carries a
cookie that authenticates against Superset's own REST API — the same API its frontend calls
internally. Once that cookie exists, a plain `curl` request gets the same data the UI would've
rendered, with none of the UI's problems.

| | Browser automation | Direct API |
|---|---|---|
| Time per chart | ~9-10s | ~1-2s |
| 5 charts, sequential | 12.5s | — |
| 5 charts, parallel | not possible (shared browser state) | 1.4s |
| History returned | whatever the UI's date filter was set to | full history by default |
| Known UI bugs inherited | yes (stale-modal bug) | no |

**Browser automation still has exactly one job left: logging in.** JumpCloud SSO + MFA can't be
scripted — a human has to complete that once. Every query after that reuses the session cookie
directly against the API. No browser window, no clicking, no waiting on page renders.

## What's in here

- **`scripts/fetch_chart.sh <chart_id> [date_range] [--no-cache]`** — pull a chart's real data.
  Supports server-side date filtering (so a "last month" question doesn't pull three years of
  history and discard most of it) and response caching (a repeated question in the same session is
  near-instant). Flags known-bad charts automatically — see Known issues below.
- **`scripts/fetch_dashboard.sh <dashboard_id>`** — a dashboard's full structure (owners, tabs,
  every chart's id/name) in one API call, under a second. No browser, ever, for this step.
- **`scripts/search_charts.sh <keyword>` / `scripts/search_dashboards.sh <keyword>`** — full-catalog
  search across every dashboard and chart Superset has, not just the ones already documented.
- **`scripts/lib.sh`** — shared session handling. Self-heals a crashed local browser process
  without a human needing to notice; self-installs `agent-browser` via npm and self-provisions a
  Chrome build if neither is present, so a new install is just: copy the folder in, run it, and
  complete the one login prompt.
- **`references/dashboard-inventory.md`** — a living map of every dashboard walked so far: what's
  on it, what's broken, what's stale, and why. Compounds over time instead of being rediscovered
  every run.

## Setup

1. Copy this folder into `~/.claude/skills/`.
2. Invoke the skill. On first use it'll check for a live session, find none, and open a visible
   Chrome window for the one-time login.
3. Complete SSO + MFA with **your own credentials** — results reflect your own dashboard
   permissions, same as logging into Superset directly would.

That's the whole setup. `agent-browser` and a Chrome install are fetched automatically if missing —
see `SKILL.md`'s Setup section for the exact mechanism.

## Known issues this has already caught

**A confirmed SQL bug, not a hypothesis.** One dataset's percentage-metric charts
(`SUM(x)/COUNT(user_id)` instead of `COUNT(DISTINCT user_id)`) were inflating conversion rates by
3-5x, silently — no error, no out-of-range value, just a wrong number that looked plausible.
Caught by cross-checking against a raw-count chart on the same dashboard. `fetch_chart.sh` now
flags this automatically on every chart from that dataset — this is the kind of thing a project
like this is supposed to accumulate, not just report once and forget.

**Pipeline flakiness is a pattern, not a one-off.** Some dashboards sit behind a backend pipeline
that goes down and recovers within the same session. A single "pipeline down" read gets retried
once before being reported as a real outage — otherwise you end up reporting noise as signal.

## Scope

This is wired to one company's Superset instance and internal dataset naming — the base URL and
dataset names in `references/` are specific to that deployment. The part worth taking if you're
building something similar: **the session-cookie-as-API-credential trick**, the
self-provisioning setup, and the compounding data-quality inventory. Swap the base URL and rebuild
the inventory against your own dashboards, and the same shape holds.
