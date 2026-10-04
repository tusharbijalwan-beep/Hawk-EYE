# Hawkeye View

A Claude Code skill that answers business questions straight out of Superset — ask in plain
language, get a real number back, no dashboard-clicking.

## Capabilities

- **Any single metric, fast.** A one-off question ("what's today's Futures take-rate") doesn't
  need a full dashboard walk — one direct pull, seconds, not minutes.
- **Full-catalog reach, not just pre-mapped dashboards.** Search across every dashboard and chart
  Superset has, not only the ones already documented — a metric nobody's asked about before is a
  search away, not a dead end.
- **Direct SQL when nothing existing covers the question.** Not limited to what a saved chart
  already computes — can write and run new SQL directly against the warehouse (via Superset's own
  SQL Lab, under the invoking user's own permissions) for a grouping or window no existing chart
  supports.
- **Cross-dashboard and cross-metric comparison.** Checking whether two dashboards reporting the
  "same" number actually agree, or ranking several business lines against each other on a shared
  metric.
- **Root-cause digging, not just numbers.** Pulling the funnel, the channel mix, and the timing
  together when a metric moved, instead of reporting the move in isolation.
- **Qualitative + quantitative together.** Pulling raw case-level customer-voice text behind a
  contact-volume number, not just the count.
- **A full business-pulse briefing** — scorecards per business line, ranked flags for leadership,
  competitive position, and a data-reliability notice — on request, not by default.
- **A compounding memory of the data itself.** Known bugs, stale pipelines, flaky dashboards, and
  dataset quirks get documented once and never re-discovered from scratch.

## Guardrails

- **Never fabricates a number.** If a value can't be reliably read, that's the answer — not a
  guess dressed up as one.
- **Independent verification before calling anything a confirmed bug.** A correction only counts
  as confirmed once checked against a source that's structurally independent of what's being
  corrected — not another column of the same table, which is how a real false-positive finding got
  caught and retracted mid-project.
- **Known issues get labeled, not re-discovered as news.** A flaky backend pipeline gets retried
  once (confirmed to flap, not simply fail) before being reported as down. A known SQL bug on a
  specific dataset gets flagged automatically rather than silently trusted.
- **Partial-period awareness.** A "today" or "this week" number that hasn't had time to mature gets
  flagged as partial, not reported as a real decline.
- **Same permissions as the person asking, always.** Every pull — chart-based or direct SQL — runs
  under the invoking user's own logged-in Superset session. Nothing bypasses their actual dashboard
  or database permissions; a restricted dashboard stays restricted no matter who's asking.
- **Mechanics stay hidden in normal answers.** Chart IDs, SQL, API/script details stay out of a
  plain business answer by default — they surface only when the question is actually about how the
  extraction itself works.
- **No auto-published pages.** Output defaults to plain text in the conversation; nothing gets
  turned into a shareable page or artifact unless explicitly asked for.
- **Honest about data-quality tradeoffs.** When a cross-check reveals two sources disagree, that
  gets surfaced and reasoned through, not smoothed over in favor of a cleaner-looking answer.

## Setup

1. Copy this folder into `~/.claude/skills/`.
2. Invoke the skill. On first use it checks for a live session, finds none, and opens a visible
   Chrome window for a one-time login.
3. Complete SSO + MFA with **your own credentials** — results reflect your own dashboard
   permissions, same as logging into Superset directly would.

That's the whole setup. Node package and browser-build dependencies are fetched automatically if
missing — see `SKILL.md`'s Setup section for the exact self-provisioning mechanism. After that
first login, every query — including every future invocation — runs headless; a visible browser
only reappears if the session cookie genuinely expires.
