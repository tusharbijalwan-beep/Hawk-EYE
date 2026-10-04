# Waiting-room prompts

A content bank of capability-showcase teasers, drawn on for **two distinct, separately-governed
use cases** — don't conflate them:
1. **Mid-wait filler** (original use): show **exactly one** entry while a lookup is genuinely slow
   (a background fork, a cold multi-chart pull, a full dashboard sweep), instead of narrating
   mechanics ("fetching...", "0 of 40 done...", chart ids, curl/API talk). See SKILL.md's persona
   section ("If a lookup is genuinely slow...").
2. **Cold-open greeting** (added 2026-10-04): on a bare invocation with no specific ask attached,
   show **3-4 entries** as example prompts, rotating which ones across sessions so the greeting
   doesn't recite the same examples every time. See SKILL.md's persona section ("Bare invocation
   ... changed 2026-10-04").
Both draw from the same bank below; the difference is how many entries and when. Neither is the
answer to "what can Hawkeye do" asked as a direct question mid-conversation — that's a third,
separate case (see below), which gets the fuller answer in SKILL.md's "Pre-read: capabilities"
section instead of anything from this file.

**Why this file exists, not hardcoded numbers:** an earlier version of this idea considered baking
in real figures ("Futures volume dropped 33% last week!") as filler facts. Don't do that here —
today's number is next month's stale, wrong claim. Every entry below is a **capability tease** (an
example of a question Hawkeye can answer), which stays true forever, not a data point that rots.
If you want to pair a tease with a genuinely fresh fact, pull one live from whatever's already
cached in the current conversation — never from this file, and never invented.

## How to use this file

- **Mid-wait**: show exactly **one** entry per wait, as a short, warm aside — half a sentence of
  acknowledgment, then the tease. Example shape: *"This one's new to me, gimme a sec — while I
  check, here's something you could try next time: {entry}"*
- **Cold-open greeting**: show **3-4** entries, phrased as things the person could actually type
  (not the abstract category label), pulled across a spread of different categories rather than
  all from one — gives a sense of the real breadth in one glance.
- **Rotate, don't repeat.** Track (in-context, for the current session) which entries have already
  been shown — via either use — and don't reuse one within the same session unless you've cycled
  through all of them. Across separate sessions, vary which categories lead the cold-open greeting
  rather than always opening with the same one. No persisted state file needed — conversation
  memory is enough within a session; plain variety/judgment is enough across sessions.
- Pick an entry **loosely relevant to what's already happening** when you can (e.g. if the slow
  lookup is itself a cross-dashboard comparison, tease a *different* comparison, not the same
  category twice in a row) — but don't overthink it; any untouched entry is fine.
- This is a tease, not a lecture — one line, not the whole category writeup. If the person asks
  "what do you mean," then expand; don't front-load the expansion into the wait-filler itself.
- Never use this file's content as an answer to "what can Hawkeye do" when asked directly and
  there's no wait happening — that's a different, more complete answer (see SKILL.md's
  "Pre-read: capabilities" section). This file is specifically for filling dead air, not for
  answering the capability question head-on.

## The bank

### Quick lookups
1. You don't need the full business-pulse briefing for a one-number question — "what's today's
   Options fee take-rate" is a 1-2 second pull on its own.
2. Anything in the full ~10,000-chart Superset catalog is reachable, not just the ~20 dashboards
   Hawkeye knows by heart — if it's not pre-mapped, it's a search away.
3. Multiple independent metrics in one ask ("give me AVPU, ATPU, and DAU for Futures") get pulled
   in parallel, not one at a time.

### Cross-dashboard comparisons
4. Two dashboards reporting the "same" metric sometimes disagree — Hawkeye can check whether, say,
   Crypto Market Volume's market-share number actually matches Business Review Dashboard's.
5. You can ask for a head-to-head: "compare Options' competitor ratio to Futures' competitor
   ratio — which one's gaining share faster?"
6. When a dashboard has more than one version of the same-sounding KPI (e.g. three different CSAT
   numbers on one dashboard), Hawkeye can surface the gap instead of quoting just one.

### Root-cause digging
7. A number moving isn't the end of the question — "Deposit→FNAP conversion dropped sharply
   between two months, what actually drove it" is answerable by pulling the funnel, the channel
   mix, and the timing together.
8. A sudden spike in one specific VOC issue (like a 40%+ WoW jump in one complaint type) can be
   checked against the onboarding funnel and channel mix for a likely cause, not just reported as
   a number.

### Customer voice (VOC), not just counts
9. Beyond "how many contacts," Hawkeye can pull the actual case-level chat text behind a contact
   category — real customer language, not just a volume number.
10. Some of the biggest friction points aren't visible in any rollup chart — they only show up
    once you read the raw case descriptions behind a generic bucket like "Crypto
    Deposits/Withdrawals."
11. You can ask whether a business-metric move (like a market-share dip) shows up anywhere in
    what customers are actually saying that week.

### Cohort & time-series digging
12. Hawkeye can track one signup cohort's conversion week-by-week across a funnel, and compare it
    against a different month's cohort to see if behavior actually changed.
13. A metric that looks flat week-to-week can still be trending hard over 2-3 months — worth
    asking for the longer window, not just "this week vs last week."

### Data-quality catches
14. If a chart's numbers look suspiciously flat, zero, or N/A, Hawkeye checks whether that's a
    real signal or a known pipeline flap/dead pipeline before reporting it as business news.
15. A percentage chart that divides a summed numerator by a non-distinct count can silently return
    an inflated number with no error and no obviously-wrong value — Hawkeye knows which datasets
    on this platform have this exact failure mode and cross-checks them by default.

### Judgment calls, not just numbers
16. "Is this small business line worth the attention it gets" is answerable — pull its revenue/
    volume contribution, its trend, and whatever operational signal exists (like CX contact
    volume tied to it), and weigh them together.
17. Hawkeye can rank things for you — "which of these three products makes the most per user,"
    not just report each one in isolation.

### Full-catalog sweeps
18. "Find every chart anywhere in Superset that touches [topic] and tell me if any disagree with
    each other" is a real, answerable request — not limited to the handful of dashboards Hawkeye
    has pre-mapped.
19. A brand-new metric nobody's asked about before is usually a keyword search away, not a dead
    end — that's how a dedicated dashboard for a niche topic got found mid-session once, with
    nobody knowing it existed beforehand.
