# Dashboard Inventory

Complete chart-level map of the 11 Superset dashboards this skill draws on. Built 2026-09-25 by
walking every tab of every dashboard by hand. **Read this before opening any dashboard** — the
goal is to look up where data lives, not rediscover it each run.

**Extraction method update, 2026-10-01: use the API scripts first, not the browser.** Confirmed
working via Superset's own REST API (same session cookie, no UI needed):
- `../scripts/fetch_chart.sh <chart_id>` — ~1-2s per chart instead of ~9-10s, and **confirmed ~9x
  faster again when run in parallel** (`& ... & wait` on multiple calls — 5 charts: 12.5s
  sequential vs 1.4s parallel). Always parallelize when a question needs more than one chart.
- `../scripts/fetch_dashboard.sh <dashboard_id>` — a dashboard's full structure (owners, tabs,
  every chart id/name/tab) in one ~0.5-1s call, zero browser. Use this first on any dashboard not
  yet below, instead of opening it in a browser to shallow-index it.
- `../scripts/search_charts.sh` / `../scripts/search_dashboards.sh` — full-catalog discovery
  (169 dashboards, 9,973 charts), same speed.

Every chart id documented in this file below still works with `fetch_chart.sh` directly — e.g.
`fetch_chart.sh 5820` for Daily Product Metrics' Signup->KYC funnel. See `SKILL.md`'s "Extraction
method" section for full detail; the browser View-as-table method documented throughout this file
(including the standalone writeup under Product dashboard) is now the **fallback**, used only when
a chart has no `query_context` (exit code 2 from `fetch_chart.sh`).

Superset base URL: `https://reporting.dcxtools.com`

## Quick links

Direct URLs — open these straight, no dashboard-list search needed.

| # | Dashboard | Direct link |
|---|---|---|
| 1 | Options Business Dashboard | https://reporting.dcxtools.com/superset/dashboard/676/ |
| 2 | Futures Tracker | https://reporting.dcxtools.com/superset/dashboard/597/ |
| 3 | Product dashboard | https://reporting.dcxtools.com/superset/dashboard/776/ |
| 4 | Daily Product Metrics | https://reporting.dcxtools.com/superset/dashboard/730/ |
| 5 | Daily Metrics | https://reporting.dcxtools.com/superset/dashboard/797/ |
| 6 | Crypto Market Volume | https://reporting.dcxtools.com/superset/dashboard/9/ |
| 7 | Trading Volumes | https://reporting.dcxtools.com/superset/dashboard/15/ |
| 8 | Futures product Metrics | https://reporting.dcxtools.com/superset/dashboard/760/ |
| 9 | US Perps \| Advisory Dashboard | https://reporting.dcxtools.com/superset/dashboard/2804/ |
| 10 | Advisory Expert Calls Dashboard | https://reporting.dcxtools.com/superset/dashboard/476/ |
| 11 | Advisory Business Metrics Dashboard | https://reporting.dcxtools.com/superset/dashboard/659/ |

Note: Superset appends a `?native_filters_key=...` query param on load — that's a session-specific
filter-state token, not a stable part of the URL. Always open the bare `/superset/dashboard/<id>/`
link above rather than a copied URL with that param, since the token won't be valid in a new
session.

## Table of contents

1. [Options Business Dashboard](#options-business-dashboard-id-676) (id 676)
2. [Futures Tracker](#futures-tracker-id-597) (id 597)
3. [Product dashboard](#product-dashboard-id-776-owner-anjani-janyavula) (id 776)
4. [Daily Product Metrics](#daily-product-metrics-id-730-owner-nitish-amnerkar) (id 730)
5. [Daily Metrics](#daily-metrics-id-797-owner-ishika-kadam) (id 797)
6. [Crypto Market Volume](#crypto-market-volume-id-9-owner-kartik-arjaria) (id 9)
7. [Trading Volumes](#trading-volumes-id-15-owner-kartik-arjaria) (id 15)
8. [Futures product Metrics](#futures-product-metrics-id-760-owner-parth-joshi) (id 760)
9. [US Perps | Advisory Dashboard](#us-perps--advisory-dashboard-id-2804-owner-saurabh-mehta) (id 2804)
10. [Advisory Expert Calls Dashboard](#advisory-expert-calls-dashboard-id-476-owner-saumya-maheshwari) (id 476)
11. [Advisory Business Metrics Dashboard](#advisory-business-metrics-dashboard-id-659-owner-saumya-maheshwari-last-edited-8-months-ago) (id 659)

## Status legend

- **text** — real numbers render in `document.body.innerText`. Cheapest, most reliable source.
- **graphical** — chart exists but renders via SVG/canvas with no text in the DOM. Needs a
  screenshot + visual read, or a Superset API call, to get exact values. Don't guess.
- **pipeline-down** — chart shows "Waiting on Cefi-Dev-DBT-Databricks" or "Waiting on
  Cefi-SQL-Endpoint-Analysis". **This pipeline flaps** — see [Known issues](#known-issues) before
  treating one down-read as a confirmed outage.
- **broken** — a SQL/query error renders instead of a chart.
- **no-data** — "No results were returned for this query" (query runs, returns nothing).

---

## Options Business Dashboard (id 676)

### Tab: Summary — re-pulled 2026-10-01
- Notional Volume ($) — **text** — $843M / $4.79B / $18.4B (1D / 7D / 30D) — 1D up ~28% vs the 09-25 baseline read, 7D slightly softer
- Premium Volume ($) — **text** — $2.69M / $13.8M / $59.5M
- Users (#) — **text** — 7.27k / 16.8k / 36.6k
- Fees ($) — **text** — $55.4k / $304k / $1.18M
- Trades (#) — **text** — 66.0k / 412k / 1.68M
- Options Competitor Notional Volume ($) — graphical
- Options Competitor Volume Ratio (%) — graphical
- Transacting Users (#) - New & Old — graphical
- Notional Volume ($) - New & Old — graphical
- New Users (#) - Acquisition Split — graphical
- New Users' Notional Volume ($) - Acquisition Split — graphical
- Notional Volume ($) - Stage Split — graphical
- Notional AVPU ($) — graphical
- Notional AOV ($) — graphical
- Premium AOV ($) — graphical
- Notional Volume ($) - Token Split — graphical
- Notional Volume ($) - Options Type — graphical
- Orders (#) - Options Type — graphical
- Placed Orders - Split by Options State — graphical
- Fees ($)- Order Stage — graphical
- Profitable Users (%) — graphical
- Notional Volume - Split by Options State — graphical
- Premium Volume - Split by Options State — graphical
- Notional Volume - Split by Options Side — graphical
- Premium Volume - Split by Options Side — graphical
- Placed Orders - Split by Options Side — graphical
- ATPU - Split by Users — graphical
- Notional AVPU - Split by Users — graphical
- Notional AOV - Split by Users — graphical
- Notional Volume ($) - Platform Split — graphical
- Users - Platform Split — graphical
- Orders - Platform Split — graphical
- Options Volume - Split — **no-data**

### Tab: Extended Views
- Placed Orders - Split by Order Type (T-2) — graphical
- Notional Volume ($) - Order Type — graphical
- Notional Volume ($) - Split by User Volume — graphical
- Placed Trades - Split By Premium Capped Flag (#) — graphical
- Volume - Split by Days to Expiry (Placed Orders) — **text** — expiry_cohort table: T0 2.24M orders/$26.3B/$71.3M; T1 604k/$6.92B/$33.5M; T2 198k/$2.16B/$14.2M; T3 30.5k/$351M/$2.86M; T3+ 272k/$2.28B/$30.2M
- Orders - Split by Days to Expiry (Placed Orders) — graphical
- Notional Volume & Users ($) - Split by Access Date (Last 1 Day) — **text** — options_access_date cohort table; largest bucket is untagged N/A: $28.3B / 48.8k users
- Notional Vol % of top 10 users — **no-data**

### Tab: Market Level Data
- (chart not individually named) — **flipped live 2026-10-01** (was pipeline-down on 2026-09-25 baseline; now real per-token data) — flap behavior, don't assume permanently fixed

### Tab: Retention
- Cohort Users — **text** — large weekly cohort % matrix, too granular to summarize without modeling
- Cohort Volume, Transacting Volume, AVPU, ARPU — **flipped live 2026-10-01** (was pipeline-down on 2026-09-25 baseline, now real cohort tables) — same flap pattern as Futures Tracker's earlier flip, don't assume permanently fixed

### Tab: User Split
- Options User Split — graphical
- Options Volume Split — graphical
- Options AVPU Split — graphical
- Options ATPU Split — graphical
- Options AOV Split — graphical
- ONAP MTUs Split — graphical
- New ONAP Split — graphical
- Notional volume - ORM Split — graphical
- New Direct ONAP Acquisition Channel Split — graphical
- Direct ONAP MTUs Split — graphical
- Direct ONAP MTUs - Volume Split — graphical

### Tab: Cross Sell
- Cumulative ONAP users % trend — graphical
- Cumulative Opt to fut cross sell % — graphical
- Opt to fut cross sell — graphical

### Tab: Non Zero Fee Tracker
- Notional vol above 1 million — graphical
- MTUs - Notional volume above 1 million — graphical
- Futures vol (Cross sell users) — graphical
- Futures MTUs (Cross sell users) — graphical
- Zero fee cost vs Options gain vs Fut revenue — graphical
- Net Margin — graphical

### Tab: Zero Fee Tracking
- Signup Funnel — **text** — weekly table (Signups, DNAPs, FNAPs, ONAPs, conversion %), Jun 29–Sep 21 2026; latest week Signups 33.5k, ONAP Cvr% 0.7
- NAPs Funnel — **text** — weekly table (NAPs, NAPs→FNAP/ONAP, conversion %)
- FNAPs --> ONAP Movement (table) — **text** — weekly table (FNAPs→ONAPs, split ≤6/>6 days, Futures MTUs→ONAPs)
- New Signup DNAPs — graphical
- New Signup - DNAP Cvr % & FNAP Cvr% — graphical
- NAP -> FNAP Cvr % & NAP -> ONAP Cvr % — graphical
- FNAPs -> ONAP Movement (chart, distinct from the table above) — graphical

### Tab: Fee data
- Options - Pre zero fee data — **no-data**
- Options - Post zero fee data — **text** — weekly table (Fees debited/charged, Rebate, Refund, KOL payout, Net Cost)
- Options - Debit Recon data — **text** — weekly table (Debit_Spot/Bybit txn counts + recon values + diff)
- Options - Credit Recon data — **text** — weekly table (Credit_Spot/Bybit txn counts + recon values + diff)
- Cap/ Non Cap - Volume & Fee — **text** — dense weekly table by stage/maker-taker/capped-flag

### Tab: All VIP User Split
- Volumes — graphical
- Total VIPs — graphical
- User Split — graphical
- Volumes - Split — graphical
- Users - Split — graphical
- Volumes - Channel — graphical
- Users - channel — graphical
- Options Volume - Split — graphical

---

## Futures Tracker (id 597)

*Summary + Segments tabs fully deep-walked 2026-10-01 via View-as-table (22/22 charts clean, real
monthly data back to 2025-01). The other 5 tabs were spot-checked live (not deep-walked) and found
**fully live — no pipeline-down banners anywhere**, a major correction to the 2026-09-25 baseline
below which documented them as mostly/all pipeline-down. This is the flap behavior documented in
[Known issues](#known-issues), just a much bigger swing than previously observed: this whole
dashboard was largely unusable 6 days ago and is fully usable now. Treat Acquisition/Retention/
Resurrection/OKR View/Targets-Progress as **confirmed live, ready for on-demand deep extraction**
next time a real question needs them — don't assume the pipeline-down tags below still hold.*

### Tab: Summary — all 17 charts now real data (previously graphical)
- Global Derivatives Volume Ratio (%) (Updated) — **text** — Binance-side 0.20%→0.87% peak, now 0.81–0.82%; Delta-side 0.07%→0.32%
- Futures Volume - Delta India vs CoinDCX — **text** — Delta ratio spiked to 99.5%, now 48.7%
- Channel x Volume, Channel x Revenue, Channel x ARPU — **text** — per-channel breakdown now readable via View-as-table
- Binance comission, Lifecycle x Transacting Users, User lifecycle x Volume/Revenue, FNAPs x Channel, FNAPs - Breakup, New/Repeat Users x Channel (Volume & Revenue), ARPU/AVPU: User lifecycle & Overall — **text** — all pulled clean, see `/tmp/futurestracker_extract.jsonl` for full series

### Tab: Acquisition — confirmed live on 2026-10-01, not yet deep-walked
Previously logged as fully pipeline-down (Cefi-Dev-DBT-Databricks): Signups - Users; Rolling 30 day
- FNAP conversion(Active users); Acquisition Funnel; Signup - KYC Verified(7 Day); KYC - Bank A/c
Verification(7 Day); Bank A/c Verification - Deposit(1 Day); Deposit - NAP(1 Day); Deposit -
FNAP(1 & 7 Day); BAV - FNAP(7 Day); Signup -> FNAP (7 Days). **Status flipped to live** — pull via
View-as-table next time this tab is needed.

### Tab: Retention — confirmed live on 2026-10-01, not yet deep-walked
Previously logged as fully pipeline-down: Futures Transacting Users; FTU/FAU; Retention - Trend;
Cohort Retention; Transacting Users; Volume: M0-Mn; Revenue: M0-Mn; AVPU: M0-Mn; ARPU: M0-Mn;
Cumulative Vol/User: M0-Mn; Cumulative Revenue/User M0-Mn. **Cohort Retention and the M0-Mn tables
are now rendering real data directly as page text** (no View-as-table even needed) — status
flipped to live.

### Tab: Resurrection — confirmed live on 2026-10-01, not yet deep-walked
Previously logged as fully pipeline-down: Resurrection; AVPU: Resurrected Users; ARPU: Resurrected
Users. Status flipped to live.

### Tab: OKR View — confirmed live on 2026-10-01, not yet deep-walked
Previously logged as mostly pipeline-down: Volume x Channel Type; Retail Volume x User Lifecyle;
New Retail Volume x FNAP type; FNAP x FNAP Type; FNAP AVPU x FNAP Type; New Retail Volume x New
FNAP x Channel; New FNAP x Channel; New FNAP AVPU x Channel; New Volume / Repeat Volume. Status
flipped to live.

### Tab: Targets - Progress — confirmed live on 2026-10-01, not yet deep-walked
Previously logged as fully pipeline-down: Target- Achieved (%); Volumes Target Progress - MOM;
Acq's Target Progress - MOM. **MTD/QTD target-achievement table now rendering real data directly
as page text.** Status flipped to live.

### Tab: Segments — all 6 charts now real data (previously graphical)
- Pro Trader Segment Split Trend / Normalized Stacked / Volume Trend — **text** — pro traders are a growing minority of users (18%→20%, Jul→Aug 2026) but dominate volume ($12.7B→$15.8B vs $951M→$971M non-pro — pros run ~15-16x the per-capita volume of non-pro traders)
- Trading Style Segment Split Trend / Normalized Stacked / Volume Trend — **text** — Scalper is the largest trading-style segment by volume

---

## Product dashboard (id 776, owner Anjani Janyavula)

*Fully re-walked 2026-10-01 using the "View as table" extraction method (see
[View-as-table method](#view-as-table-extraction-method) below) — every chart that was previously
"graphical" has now been pulled as real numbers. 38 charts total across 4 tabs (vs ~19 logged
2026-09-25) — the dashboard has grown substantially. Treat this section as current; the
2026-09-25 version undercounted both chart volume and the severity of the breaches-tab bug.*

**KPI dictionary (built into the dashboard, tab 1 intro panel) — full version, supplied by Tushar
2026-10-04, supersedes the shorter paraphrase previously here:**

*Filters:* User type = segment by which product(s) (futures/options/spot) a user has traded
historically. Date range = inclusive. Acquisition Channel = source of user acquisition. Months
since acquisition = months since signup. Futures Persona = futures-only behavioral tagging (High
Freq, Swing, Bluechip, Explorer). Superset time grain & date granularity = both filters must be
set together to change the chart's time bucket (day/week/month). New vs Old = New if signup <30
days ago, else Old.

*KPIs:*
1. Product considered = Spot, Futures, Options only, across this whole dashboard.
2. Transacting Users = placed ≥1 order in the period, in any product.
3. Product level = transacting users per product — **overlapping** (a futures+spot user counts in both).
4. Product(s) traded level = transacting users by unique product-combination — **non-overlapping** (e.g. "spot only", "futures+spot", "futures+spot+options").
5. Orders = count of distinct orders placed.
6. Volume = total volume of orders placed.
7. ATPU = orders ÷ distinct transacting users.
8. AVPU = volume ÷ distinct transacting users.
9. AOV = volume ÷ orders.
10. **DAU = unique count of signed-up users who opened the app at least once in the period — this is an app-open metric, NOT a transacting/ordering metric.** Correction, 2026-10-04: earlier Hawkeye answers this session used "Transacting Users" (KPI #2) as a DAU proxy for Futures — per this dictionary, that's actually wrong; DAU and Transacting Users are two different KPIs, and the dashboard's own DTU/DAU ratio (#11) exists precisely because they're not the same population. Don't conflate them going forward — if asked for DAU specifically, that's an app-open count, not an order count.
11. DTU/DAU = % of DAU (app-openers) who also place ≥1 order in the period.
12. App opens/user = app opens ÷ unique users.
13. Sessions/user = sessions ÷ unique users (a session ends after 30 consecutive minutes of inactivity).
14. Timespent/user = total timespent on app ÷ unique users (excludes background app time).
15. Products per user = avg. distinct products a user has transacted in, lifetime.
16. Non-login user app activity = unique device_id's active on the app (i.e. activity without a logged-in user).
17. Transaction Retention = % of a period's transactors who transact again in the next window (day/week/month).
18. Fnap Eligible% = % of ever-NAP base that places ≥1 order in the period (NAP→FNAP cross-sell tracking).

### Tab: Product metrics (19 charts, id range 6709–7813)
All of the below are now **text** via View-as-table (date range pulled: 2026-07-24 onward, capture
truncated at ~20 rows per chart by extraction script, not a platform limit — re-extract with a
higher slice cap for full history):
- Transacting users - Product level (#) — futures ~40-49k/day, options ~4.5-6k/day, spot ~33-38k/day
- Transacting users - Products traded level(#) — breakdown by combo (Futures_only largest single bucket ~33-45k/day)
- Orders - Product level (#) — futures 616k-907k/day, options 20.5k-38.4k/day, spot 125k-228k/day
- Volume - Product level (#) — futures $333M-$907M/day, options $230M-$518M/day, spot $3.8M-$6.5M/day
- ATPU / AVPU / AOV - Product level — options has by far the highest AVPU (~$53k-$92k/user) and AOV (~$9.9k-$13.8k/order) vs futures (AVPU ~$8.6k-$15.4k) and spot (AVPU ~$112-$178)
- DAU - user type level — Non_transacted and spot_only are the two largest daily segments
- DAU - User product type level — overall DAU ~312k-375k/day
- DTU/DAU - User product type level (%) — 21.6%-26.3%, mildly trending up across the window
- Products per user (#) — flat ~1.37-1.41
- App opens per user, Sessions per user, Time spent per user (mins) — all flat-to-mildly-rising (time spent ~14.6→19.3 min)
- Logout users app activity — 82k-122k/day, no trend
- Transaction retention(%) - Product level — options retention (58-73%) exceeds futures (60-78%), both far exceed spot (29-35%)
- Fnap eligible percentage(%) — flat ~0.48%-0.72%
- **DAU/MAU (Logged in users) / WAU/MAU (Logged in users) — chart ids 7812/7813, correction 2026-10-04: NOT actually empty, just stale.** Any recent-date filter (default view, or even a "last 30 days" style window) returns zero rows and looks like the previously-logged blank render — but `fetch_chart.sh` with a wide date range (`2024-01-01 : 2026-10-04`) proves the underlying dataset `dev_cefi.cube_app_activity_dau_wau_metrics` has real history from mid-2025 through **2026-04-07, then nothing** — the pipeline has been dead for ~6 months, not permanently/structurally empty. **Also: the last 1-2 weeks of real data before the cutoff (late Mar–Apr 7 2026) show an abnormal spike** (DAU/MAU jumping from a steady ~20-29% band to ~38-42%; WAU/MAU spiking to 80.89% on Mar 30 vs a steady ~53-57% band) — a denominator-collapse artifact as the trailing-30-day MAU window ran out of future days near the pipeline's death, not a real usage spike. Last trustworthy reading: DAU/MAU ~22% (Mar 31 2026), WAU/MAU ~53-57% (mid-March 2026). Platform-wide ("logged in users"), not split by product — doesn't answer a product-specific (e.g. Futures) MAU question. Worth a data-eng ticket on the 6-month-dead pipeline, separate from the "silently dead" framing used elsewhere in this doc.

### Tab: Product metrics -Dimension level (5 charts, id range 6803–7142)
All **text** via View-as-table:
- Transacting users - Age since signup tagging (#) — **data artifact found**: the "a.0" (signed-up-today) bucket collapses from ~6000/day to 1258 on 2026-08-03, while "b.1"/"c.2" buckets simultaneously jump up (e.g. b.1 3500→5684) — a same-day cohort can't lose 80% of its population in one day while adjacent cohorts gain it; this reads as a **cohort-bucketing reclassification event on 2026-08-03**, not a real signup collapse. Don't quote pre/post-Aug-3 numbers in the same trend line without flagging this.
- Futures transacting users - Futures persona (#) — **same artifact, same date**: "non_transacted" collapses from ~12-13k to 2039 on 2026-08-01, then climbs back over the following week (2943→4020→4594→5818...). Co-occurring with the age-cohort shift above — strongly suggests a shared upstream user-tagging pipeline reprocessing event in the Aug 1-3 window. Flag both together if escalating.
- Transacting users - User type level (#) — Futures_and_spot is the dominant combo (26k-31k/day), consistent with Product-level tab
- Transacting users - Acquisition channel (#) — organic > marketing > kol > referral, consistently, no mix shift across the window
- Transacting users - Old vs New (#) — old_user dominates heavily (67k-80k/day vs new_user 5.8k-7.4k/day) — expected for a mature product, but means acquisition-tab growth claims should always be checked against this base

### Tab: Wealth experience breaches metrics (4 charts, id 6914/6915/6917/6918)
**Bigger finding than previously logged — all 4 breach metrics are non-functional, just in two different ways:**
- Order exit failure % (6915) — **broken**, loud SQL error — `UNRESOLVED_COLUMN.WITH_SUGGESTION: order_exit_failure_perc cannot be resolved` (same bug on 3 dashboards, see [Known issues](#known-issues))
- Order cancellation failure % (6914), TPSL placement failure % (6917), Chart load failure % (6918) — **silently dead**: View-as-table returns a real table (no error), but every single row across the table's own date range (2025-10-01 through 2025-10-20 — a full year stale, nowhere near the dashboard's live Jul-Sep 2026 filter) reads **N/A**. These don't error, so they'd pass a shallow health check — a CPO relying on this tab for breach-rate visibility is getting literally zero signal from any of the 4 charts, not just the 1 that visibly errors. Worth escalating as one ticket alongside the exit-failure bug: the whole breaches tab is dark.

### Tab: Home page engagement heatmap and metrics (10 charts, id range 10565–11597)
Was logged 2026-09-25 as just 2 charts — now has 10. **text** via View-as-table:
- Enagaged users% (EU/AU) — weekly, Jul 27-Sep 21 2026. Steady 64.8%-70.2% through Sep 14, then **drops to 51.6% the week of Sep 21** (latest complete week in this pull)
- Transacted users/Engaged users% (TU/EU) — same weekly cadence, steady 15.9%-21.0%, **also drops to 12.9% the week of Sep 21** — moves in lockstep with EU/AU above, same week
- Both of the above also broken out by User segment level (10 segments: Active Trader, Bluechip Futures Trader, Holders, etc.), User type level (8 product combos), and new vs old — all show the same late-window softening, most pronounced in "new" users (new-user TU/EU: 29.3% on Aug 31 → 13.4% on Sep 21)
- **Caveat before treating the Sep 21 drop as a real engagement decline**: this platform has a documented partial-period trap elsewhere (see [Known issues](#known-issues)) where the most recent bucket reads artificially low. Sep 21 is a plausible "last fully-closed week at pull time" rather than a partial bucket, but confirm with the data owner before using this as a flag-worthy decline — don't repeat this as fact without that check.
- Home page heat map - action level / section level — **text**, matches 2026-09-25 findings: Portfolio_NAV_clicked and Bottom_NAV remain the top click targets every week in the series (Jul27-Sep14)

---

### View-as-table extraction method

Every Superset chart — including ones with no text equivalent in `document.body.innerText`
("graphical") — has a **"View as table"** option in its chart-level "More Options" menu
(`span[aria-label="More Options"]`, id `slice_{chartId}-controls`). Clicking it opens a modal
(`.antd5-modal` / `.ant-modal`) with the real underlying data as an HTML `<table>`. This is
strictly better than screenshotting a graphical chart — exact values, full date series, works on
every viz type (bar/line/funnel/donut) — and it's scriptable.

**Critical gotcha, confirmed by direct testing 2026-10-01: the modal is stateful and gets stuck.**
The *first* "View as table" click on a freshly-loaded dashboard page correctly shows that chart's
data. Every subsequent click — even on a completely different chart, even after closing the modal
— re-shows the **first** chart's title and data, silently (no error, header text looks like it's
for the new chart in some failure modes, stale in others — behavior was inconsistent across two
reproductions, so don't trust it either way). **The only reliable fix found: reload the full
dashboard page before every single chart extraction.** This makes bulk extraction slower (~8-10s
per chart including reload + tab-switch + extract) but fully reliable — always verify by checking
the modal's actual header text equals `"Chart Data: " + <expected chart name>` before trusting the
table content; retry/reload if it doesn't match. Tabs other than the default one must be clicked
into after each reload (tab contents mount lazily on first visit within a page session, confirmed
by testing — a chart on an unvisited tab has no `slice_{id}-controls` element in the DOM yet).

Use this method as the default for any chart logged **graphical** in this inventory from now on —
reserve actual screenshots only for genuinely visual-only content (e.g. true heatmaps with no
tabular backing) where View-as-table itself has nothing to show.

## Daily Product Metrics (id 730, owner Nitish Amnerkar)

*Re-walked 2026-10-01 (single-dashboard CPO pull). Several corrections below — treat this section,
not the original 2026-09-25 pass, as current.*

### Tab: Primary Metrics by POD
- Global Derivatives Volume Ratio, Delta vs CoinDCX, Options volume, acquisition funnels, KYC/BAV
  auto-acceptance, Futures OI, engagement (Uninstalls/Crashes/ANRs), platform rejection rates,
  CX metrics (NPS, CSAT, bot fallback, Playstore rating), funds/compliance rates — all **graphical**
  (a small "2"/"3" badge renders next to the title, not a real value — don't mistake that badge
  for a metric)
- Order exit failure % — **broken** — same `order_exit_failure_perc` error (2nd dashboard;
  confirmed still live 2026-10-01, error now also lists the likely-intended columns:
  `position_exit_failure_perc`, `chart_load_failure_perc`, `tpsl_placement_failure_perc`,
  `order_cancellation_perc`, `dau_wau_perc`)
- **Daily Contact Ratio - Main Menu (L0) Level — text** — this chart now lives on *this* tab, not
  a separate "Org L0s" tab (see Known issues: Org L0s tab drift). Daily, Sep 17–30 2026. Total
  1.85%–2.22%, no clear trend. By L0: KYC/Bank Account highest driver (0.33–0.52%), Sign up/Login
  (0.24–0.37%), Crypto Deposits/Withdrawals (0.25–0.35%), INR Deposits/Withdrawals (0.19–0.33%),
  Futures/Options/Trading&TDS/Web3 all low single-digit-bps and flat.
- Uninstalls (#) — **graphical** on 2026-10-01 pull (was logged **no-data** 2026-09-25 — recheck
  if this matters, may just be date-range dependent)
- **New: "Grain" filter control itself is broken** (dashboard-level, not chart-level) —
  `UNRESOLVED_COLUMN.WITH_SUGGESTION: granularity cannot be resolved`. Confirmed on two separate
  loads 2026-10-01. Doesn't block reading charts, but the Grain selector can't be used to
  re-aggregate.
- **Flap observed live, 2026-10-01**: on first load, 10 charts read pipeline-down
  (Cefi-Dev-DBT-Databricks) — Spot Market Share % (Major Indian Exchanges), Non-FNAP WAU to FNAP %,
  Transaction Retention \| Futures, Futures Rejection Rate, Insta Rejection Rate, Order Latency
  Breaches %, Cost of Liquidity on Binance, Relational NPS, INR Deposit Success Rate, INR
  Withdrawal Rejection Rate. A full-dashboard reload ~2 min later brought all 10 back live
  (graphical, badge-only). Consistent with the documented flap behavior — just a much larger
  single-dashboard blast radius than previously logged here.

### Tab: Product Funnel TATs
- Signup -> KYC TAT, KYC -> BAV TAT, BAV -> Deposit TAT, Deposit -> NAP TAT (all in hrs) — fully
  graphical (badge-only), same flap pattern seen on the parent tab

### Tab: Org L0s
- **Drift, unresolved as of 2026-10-01**: this tab is listed in the dashboard's own aria-label /
  tab-bar text but is not reachable as a separate clickable tab in two attempts (ref-based click
  and JS `.click()` both either no-op or get intercepted by the sticky navbar). The data it used
  to hold (Daily Contact Ratio by Main Menu L0) is confirmed live under **Primary Metrics by POD**
  instead (see above). Treat "Org L0s" as folded into the first tab until proven otherwise — don't
  burn time hunting for it as a separate tab on future pulls.

---

## Daily Metrics (id 797, owner Ishika Kadam)

### Tab: CLM Metrics
- DTU, NAPs, New FNAPs, FNAPs total, NAP→FNAP conversion, FNAP Volume, M0 Volume — **text** — weekly by channel (Overall/Referral/Organic/Marketing/KOL), Jun 29–Sep 21 2026. **Caveat:** latest week routinely reads as a sharp drop — check period completeness before trusting it, see [Known issues](#known-issues).

### Tab: Cross Sell
- Reward Hub vs Non-Reward Hub tables — **text** — same weekly cadence, same late-week dip pattern

### Tab: Spends [WIP]
- Spends HUB — **text** — monthly table by channel_tag (others/referral/resurrected/retained/x-sell)
- Reward Hub Construct Wise Spends (INR) — **text** — monthly table by reward_hub_construct_id (70+ construct IDs)

### Tab: Resurrection & Retention metrics
- All charts — **flipped live on retry, 2026-10-01** (first read showed `Cefi-SQL-Endpoint-Analysis` pipeline-down, reload brought it back) — confirms this pipeline flaps too, not just Databricks. Don't assume permanently fixed.

### Tab: AnA
- Weekly Signups, Onboarding/BAV, Time to Onboard, First Trade CVR Hub, Activation Hub — **flipped live on retry, 2026-10-01**, same flap as above

### Correction to CLM Metrics caveat (2026-10-01)
A 2026-09-25-era read had flagged the week of Sep 21 as a sharp decline (DTU, NAPs, FNAP Volume all down). A fresh pull 2026-10-01 shows the **week of Sep 21–27 (now fully closed) is actually healthy**: DTU 306k (up from 276k the week before), NAPs 20.7k, New FNAPs 4.99k, NAP→FNAP Cvr% 24.1%. The partial-period trap had simply moved forward — it's now the **Sep 28 week** (still in progress) reading artificially low (196k DTU, 7.98k NAPs). Always check which week is the most recently *closed* one before calling a decline real.

### Tab: RH - Non RH Metrics [WIP]
- Reward Hub Metrics - M0 — **text** — weekly table (RH Users, Volume, AVPU, AOV, ARPU, ATPU, NAP→FNAP Cvr%). RH Users tapers sharply in latest weeks (2.8k→371→61→8→1) — check whether this is a real wind-down or a tagging/lag artifact before quoting it.
- Non Reward Hub Metrics - M0 — **text** — same structure, no tapering (7–12k users/week)
- Sub-tabs also exist for "Resurrected" and "Retained" cohorts (not yet opened, same table structure expected)

---

## Crypto Market Volume (id 9, owner Kartik Arjaria)

### Tab: Global Vs CoinDCX
- Exchange-level Global Futures Volume table — **text** — see [Competitive Position data](#competitive-reference-data) below
- Exchange-level Global Spot Volume table — **text** — CoinDCX $80.4M vs Binance $71.8B same week — scale mismatch, likely a subset/segment, not full CoinDCX spot volume
- **Caveat:** latest week (in-progress) reads as near-zero across every exchange — partial-period artifact, exclude it

### Tab: Spot Market Share by Token Category | F2C+C2C
- Total Volume in Indian Exchanges (DCX + CSK + WRX) by Market Category — **pipeline-down** (Cefi-Dev-DBT-Databricks)

### Tab: Spot Market Share | Indian Exchanges
- First to List View table — **text** — CoinDCX first-to-list on every recent listing checked (PONS, WENSOL, MARSCOIN, CASHCAT, PIPEDOG, FLOCK, DGAI, Aug 31–Sep 8)
- Market share % charts (Overall/F2C/C2C) — graphical

### Tab: API Share
- F2C Share (Non-API) % — **regressed to graphical 2026-10-01** (was chart-label readable, 29.89%, on 2026-09-25 baseline — labels no longer render as text; needs View-as-table if needed again)
- C2C Share (Non-API) % — same regression, was 2.63%
- API Share Overall (%) — same regression, was 8.41%
- F2C+C2C+API Spot (Overall Volume) — graphical, may need more scroll

### Tab: Spot Market Share | User Level
- By User Segment — **text** (chart-label readable) — HVT 56.37% latest, LVI/Inactive/HVI/LVT all under 10%
- By User Type — **text** (chart-label readable) — Retail 68.47%, MM 10.04%, Broker 1.78%
- Retained + Resurrected + New — **text** (chart-label readable) — retained 65.76%, resurrected 69.68%
- API Only (Retained + Resurrected + New) — **text** (chart-label readable) — api_retained 21.02% (labels overlap, verify on read)
- (possibly more below fold — scroll before assuming complete)

### Tab: Global Exchanges Listing
- Global Listings — **text** — table (market, exchange, Exchange Volume($), MIN(min_volume_date))

---

## Trading Volumes (id 15, owner Kartik Arjaria)

### Tab: Summary — re-pulled 2026-10-01, materially different from 09-25 baseline
- Volume ($) — **text** — $1.7B as of 2026-09-30, **+10.5% DoD** (reverses the earlier −3.6% decline — don't cite the old $1.54B/−3.6% figure as current)
- Gross Fees ($) — **text** — $517k, +12.2%
- Gross Take Rate (%) — **text** — 0.030%, +1.6%
- Volume Trend($) — graphical (daily line, ~$900M–$2.1B range)
- Gross Take Rate Trend (%) — graphical (daily line, ~0.02–0.05%)

### Tab: Source Level
- Volume ($), Gross Fees ($), Gross Take Rate (%), Volume Trend($), Gross Take Rate Trend (%) — **pipeline-down** (Cefi-Dev-DBT-Databricks) — same chart names as Summary, broken down by source; not retried 2026-10-01

### Tab: VIP Level
- Volume Trend($) - VIP Level — text/graphical hybrid (stacked area, live)
- Volume ($) - VIP Level — **regressed to graphical 2026-10-01** (donut renders but legend %s no longer readable as text; was Total $41.4B, non-VIP retail ~50%+, VIP retail ~15–18%, soft-VIP retail ~10% on 2026-09-25 baseline — needs View-as-table to re-confirm)
- Gross Fee Trend / Gross Fee ($) - VIP Level, second Gross Take Rate by Segment chart — pipeline-down (Databricks), not retried 2026-10-01
- (likely more below fold, not fully scrolled)

### Tab: Pair level
- Pair Level Trend — **text** — large sortable table (Metric/%Change/7-period avg/%contribution/sparkline), hundreds of pairs
- Pair Level Distribution — sub-tab exists, not yet opened

---

## Futures product Metrics (id 760, owner Parth Joshi)

*Deep-walked 2026-10-01 via View-as-table: 26/40 attempted charts clean, 2 confirmed broken, 2
confirmed pipeline-down (checked live on the page itself, not just inferred from the modal), 10
came back empty from the extraction script after a 7s table-wait — likely an **extraction-script
timeout limitation on slow grouped/segmented queries**, not a genuine platform issue (the dashboard
itself shows these as live graphical badges, not pipeline-down banners). Don't log those 10 as
broken/dead without a longer-timeout retry first.*

Single scrolling page, no tabs — 8 sections, 39 charts total. Scroll to load each section.

### Section: Business Health Metrics
- Volume ($) — **text** — $3.73B week of Sep 21 per 2026-10-01 pull; **correction 2026-10-04: this read as an isolated dip, not a trend** — daily volume through Oct 2-3 shows the business climbing again ($555M→$1.11B/day late Sep into Oct, Oct 3 Sat low is the normal weekend pattern)
- Open Interest — **correction 2026-10-04: the "$924M, down from $1.56B" read was a snapshot of a trough, not a decline trend.** Fresh weekly pull shows OI climbing steadily from $627M (Sep 1) to $1.95B (Sep 28) — the opposite direction from what was logged 2026-10-01. Don't cite the old $924M figure as current or as evidence of a drop.
- Transacting Users(#), ARPU ($), AVPU ($) - COINDCX — real data pulled, see `/tmp/futurespm_extract.jsonl`

### Section: Competitor Analysis
- Global Derivatives Volume ($) — **extraction timeout, not confirmed broken** — retry with longer wait before trusting either live-graphical or dead
- Futures Volume share of CoinDCX against Delta — **text** — two series, 49.3%→42.6% and 27.3%→25.6%
- Market Overview- Market Share (vs Binance) — **text** — 1.18%→0.65% (declining)
- Market Overview- Market Share (vs Binance) BTC/ETH, (non-BTC/ETH) — **extraction timeout, not confirmed broken** — same caveat, retry with longer wait
- Delta volumes in CoinDCX ($) — **broken, confirmed** — `Error: Metric 'futures_volume' does not exist`
- Fees ($), Binance comission ($) — not re-attempted this pass

### Section: Acquisition
- FNaps - user segments — **text** — FNAPs by channel: Organic largest (3,435), Institution smallest
- FNAPs x Channel, New Users x Channel: Volume — real data pulled, see raw file

### Section: Wallet/Profitability/Liquidations
- Futures wallet balance ($) - Daily snapshot — **text** — ~$107M
- Active wallet balance users (>10$) (#) — **text** — ~102k active wallet users
- Futures profitable and loss users(%), Futures Net PNL ($) — real data pulled, see raw file
- Percentage of users liquidated — pipeline-down (unchecked this pass, carried from baseline)
- Revenue distribution between liquidation and trading — pipeline-down (unchecked this pass)
- Futures wallet Debit to credit ratio (#) - UAT Pending — explicitly UAT-pending in the title, don't treat as production data

### Section: Retention
- Retention trendline, Cohort Retention — pipeline-down (unchecked this pass, carried from baseline — worth a fresh check given how much the Futures Tracker dashboard's pipeline status just flipped)

### Section: User Segmentation Analysis
- Total Users, Total Orders — pipeline-down, **confirmed live on the page itself** (explicit "Waiting on Cefi-Dev-DBT-Databricks" banner visible)
- AVPU, Total Volume, ATPU (all "by segmentation") — **extraction timeout, not confirmed broken** — same caveat as Competitor Analysis section above

### Section: Experience Breaches
- Order Cancellation Failure % (Futures), TPSL Placement Failure % (Futures), Chart load Failure % (Futures) — not re-attempted this pass
- Order Exit Failure % (Futures) — **broken, confirmed** — same `order_exit_failure_perc` error (3rd dashboard)

### Section: Product adoption
- INR Futures market share (%), SOF users%, Chart trading users%, TPSL User adoption rate, Mobile split (%), Web split (%), Web vs Mobile vs API market share (%) — not re-attempted this pass

---

## US Perps | Advisory Dashboard (id 2804, owner Saurabh Mehta)

### Tab: Overview
- Hit Rate - Terminated Calls (weekly + point figure), Number of Calls, Cancelled calls, Avg picks/day/week/month — **text, flapping**. Live earlier in session: 70.37% hit-rate, 35 calls, 0% cancelled, 7/day, 17.5/week, 35/month, 57.6% supplier success rate. Pipeline-down on recheck — confirms the flap is systemic, not dashboard-specific.
- Supplier (chart) and Advisory level-calls chart — not fully captured, below fold

### Tab: Call Level details
- Raw call log — **text** — granular, includes supplier cancellation notes (e.g. "issue going on with US expert picks where calls don't terminate automatically")

### Tab: Advisory Asset Profit %
- Advisory Asset Profit % — **text** — raw trade table (created_date, market, direction, leverage, expiry_date, status, terminal_reason, entry_price, take_profit, ...), Last week filter

### Tab: Supplier scorecard metrics
- Supplier scorecard table — **text** — rajneesh.dubey@marketwind.com 73.91% (30 calls); santoshpatidar005@gmail.com 66.67% (3 calls); yashkhandelwal@marketwind.in 0.00% (2 calls, small sample)

---

## Advisory Expert Calls Dashboard (id 476, owner Saumya Maheshwari)

### Tab: Overview
- Hit-Rate (Approved & TP/SL Hit), Hit-Rate (All Approved Inactive Calls), Hit-Rate Overall, %ROI, %Cancelled Calls, Approval TAT, Avg New Picks/day/week/month — **text, flapping**. Live earlier: 66.06% / 65.96% / 63.19% / 10.10% / 2.75% / 3.89 min / 19.56 / 122.25 / 489. Pipeline-down on recheck.

### Tab: Call Level Details
- Raw call log — **text** — granular, daily call volume

### Tab: Advisory Token Profit %
- Advisory Token Profit % — **text** — raw trade table, current-month filter, dozens of rows

### Tab: Supplier Scorecard Metrics
- Supplier Level Hit-Rate (Approved Calls) — **text** — jainarchana982@gmail.com 76.19% (top) ... krishna@marketwind.in 37.50% (bottom, but best risk-reward at 1.58 — good setups, poor execution/approval)
- Supplier Call Approval/Rejection — **text** — chahat@marketwind.in 54 calls/100% rejected; rachit@marketwind.in 3/100%; bitnomics.research@marketwind.in 3/100%

### Tab: Agent Wise Performance
- Manual TXN Completed Agent Wise, Agentwise TXN Status performance — **text** — this is internal CX/ops manual-transaction throughput by agent email, **not** advisory-supplier performance despite the dashboard's advisory framing. Don't conflate with supplier scorecards above.

---

## Advisory Business Metrics Dashboard (id 659, owner Saumya Maheshwari, last edited 8 months ago)

*Fully deep-walked 2026-10-01 via View-as-table: 28/28 charts clean, **fully live the entire
walk — zero pipeline-down reads**, despite being documented as flapping on 2026-09-25. Also much
bigger than previously logged: 28 charts across 3 tabs, not the handful originally captured.
Raw data: `/tmp/advisory_extract.jsonl`.*

**Headline:** Advisory is a small sliver of total business — ~0.53% of volume, ~0.56% of revenue,
~4.8% of users (both weekly and monthly, last-period figures). Volume-weighted ROI is **negative in
some recent weeks** (−1.9% to −3.2%, week of Jul 20–27). New-FNAP retention on the advisory product
specifically (~26–28% at week 1) is notably lower than platform-wide retention for the same cohort
(~54–55% at week 1) — advisory users churn off the *advisory product* faster than they churn off
the platform overall.

**Methodology caveat:** the four `*Transactor Retention - Weekly` tables are **not sorted
chronologically** in the raw export — sorted by some other key (possibly a week-diff rank),
interleaving dates like 2026-07-06 and 2026-08-24 adjacently. Don't assume "last N rows = most
recent" without checking the date column directly.

### Tab: Summary
- Volume/Revenue/Volume Weighted ROI/Orders/Users, Last Week & Last Month — **text, confirmed live 2026-10-01** (no flap this run). Weekly ROI negative in the Jul 20–27 window (−1.9% to −3.2%).
- Weekly ROI trend table — **text** — 7.3% (Aug 31) → 4.9% (Sep 21) → 2.5% (Sep 14) → −1.5% (Sep 7)

### Tab: User Segment Data
- Advisory Users - FNAPs & Existing Future Users — **text** — weekly stacked bars: 3.98k/5.17k/3.88k/3.31k (retained/resurrected/new split)
- Advisory Volume - FNAPs & Existing Future Users — **text** — % stacked, retained-user share rising 58%→75%→65%
- New FNAP Users - Advisory v/s Non-Advisory — **text, resolved 2026-10-01** (was graphical) — real data now in raw file
- New User Volume - Advisory v/s Non-Advisory — **text, resolved 2026-10-01** (was graphical)

### Tab: User Retention
- New FNAPs - Advisory Transactor Retention - Weekly — **text** — cohort table, ~26–28% at week 1 (advisory-specific retention)
- New FNAPs - Platform Transactor Retention - Weekly — **text** — comparable baseline cohort table, ~54–55% at week 1 (platform-wide retention for the same cohort — notably higher than the advisory-specific number above)

---

## Onboarding dashboard (id 1000, owner Anjani Janyavula)

Discovered 2026-10-01 via `search_charts.sh "PAN"` — not one of the original 11, but has become one
of the most-used dashboards this skill touches since, because it's the only place with the granular
Signup→PAN→Aadhar→Selfie→InO→KYC→BAV→Deposit→NAP→FNAP chain. Dataset: `dev_cefi.cube_onboarding_funnels`
(percent/conversion charts) and `dev_acquisition.cube_fact_user_master` / `stg_fact_users_master`
(some absolute-count charts). 4 tabs: Onboarding funnels, Onboarding Micro Funnels of each step,
Onboarding Steps - Absolute numbers, Onboarding funnels TAT.

**Key chart ids, all confirmed working with `fetch_chart.sh` (API method):**
- 8453/8454/8455/8456/8531 — Signup->KYC/BAV/Deposit/NAP/FNAP % (macro, weekly, `dev_cefi.cube_onboarding_funnels`)
- 8457/8458/8459/8555/8556 — Signup->PAN%, PAN->Aadhar%, Aadhar->Selfie%, selfie->InO%, InO->KYC% (the pre-KYC micro chain)
- 8547 — "Onboarding steps converted users - No conversion window (#)" — **the reliable one**: real weekly absolute counts (Signups, KYC_verified_users, BAV_verified_users, First_deposit_users, NAP users, FNAP users), no percentage math baked in, cross-check anything derived from the % charts against this
- 8548 — same idea but a differently-windowed variant ("Onboarding steps converted users (#) 2") — gives smaller numbers than 8547 for the same weeks (a tighter conversion-window definition); don't mix the two without noting which one a figure came from
- 8549 — micro-funnel absolute counts (KYC-\>BAV-\>Deposit-\>NAP-\>FNAP only, not the pre-KYC steps)

**MAJOR CORRECTION, 2026-10-04: the "Signup->KYC is really only 7-10%, inflated to 37-49%" finding
below (originally logged 2026-10-01) was itself wrong, and is retracted.** It was built on a bad
cross-check: dividing 8547's trustworthy DISTINCT KYC count by 8547's own `Signups` column — which
uses `count(user_id)`, **not** `count(distinct user_id)`. That Signups column is itself inflated by
the same fan-out (confirmed: true distinct weekly signups, from chart 9322's
`count(distinct case when signup_date is not null then user_id end)`, run ~43k-80k/week in
Jul-Sep 2026, vs. 8547's non-distinct Signups column reporting ~250k-400k/week for the same weeks —
roughly 5x inflated). Dividing a correct numerator by that bad denominator understated the true
rate, not overstated it. **The real root-cause finding, verified properly this time (distinct
signups from chart 9322 against distinct KYC from 8547, across 13 separate weeks, Jul-Sep 2026):
chart 8453's own reported Signup->KYC% tracks the independently-computed distinct-vs-distinct ratio
within 1-2.5 percentage points, every single week, no exceptions.** Chart 8453 was never broken.

**The real, mechanistic rule (replaces the old blanket "treat every % chart as suspect" rule):**
every chart on this dataset (`dev_cefi.cube_onboarding_funnels`, datasource id 1117) follows one of
two SQL shapes, and only one of them is broken:
- **Safe shape — "Signup to X" family** (8453 Signup->KYC%, 8454 Signup->BAV%, 8455
  Signup->Deposit%, 8456 Signup->NAP%, 8457 Signup->PAN%, 8531 Signup->FNAP%, and the whole
  `8023-8030`/`8084-8088` "Signup to X" chart set): `SUM(x_converted)/COUNT(user_id)` — **both**
  numerator and denominator are non-distinct, same `signup_date` anchor. The fan-out duplication
  hits both sides proportionally and cancels out. **Verified accurate, trust these directly.**
- **Broken shape — intermediate-stage family** (8458 PAN->Aadhar%, 8459 Aadhar->Selfie%, 8461
  KYC->BAV%, 8462 BAV->Deposit%, 8543 Deposit->NAP%, 8555 selfie->InO%, 8556 InO->KYC%, likely 9173
  Nap->Fnap%): `SUM(x_converted)/COUNT(DISTINCT case when <stage>_time is not null then user_id
  end)` — denominator is distinct, numerator is **not**. A user who converted and has N duplicate
  rows gets summed N times in the numerator but counted once in the denominator, inflating the
  ratio by roughly N every time. **This is genuinely broken** — confirmed by both an impossible
  result (8462 at 258-336%, KYC->BAV at 330-420%, Deposit->NAP at 415-445%, all logically
  impossible) and by the mechanism now being fully understood, not just inferred from a bad value.

**Practical fix, confirmed working 2026-10-04: don't average/divide the broken intermediate charts
at all — derive step-to-step conversion from two "Signup to X" (safe-family) absolute counts
instead.** E.g. for KYC->BAV%, don't touch chart 8461; instead take Signup->KYC% and Signup->BAV%
(both safe), multiply each by that week's distinct Signups (chart 9322) to get absolute KYC and BAV
counts, then divide BAV-count by KYC-count. Every step in the Signup→PAN→Aadhar→Selfie→KYC→BAV→
Deposit→NAP chain can be reconstructed this way, fully bypassing the broken intermediate-stage
charts and chart 8549 (which also uses the non-distinct-numerator pattern and should not be treated
as a safe raw-count source — only 8547 is safe, not 8549, despite both living on the same
"Steps - Absolute numbers" tab).

**MAJOR CORRECTION, 2026-10-05: the "derive step-to-step from two Signup-to-X counts" fix above
(lines immediately preceding) is itself unreliable and produced a real false finding — don't use it
anymore now that a better method exists (see below).** Caught live: a Hawkeye run reported "KYC→BAV
fell 94.4%→89.3% (-5pt)" for the week of Sep 28 2026 by dividing `signup_to_bav_converted` by
`signup_to_kyc_converted` (both from chart-equivalent absolute counts). The real, chart-verified
number (see new method below) was **80.2%→79.9% — flat, no dip at all.** Root cause: `signup_to_X`
flags are each independently anchored to a fixed window **from signup**, not chained from the prior
milestone's own timestamp — dividing two of them does not equal the true step-to-step transition
rate (which depends on elapsed time between the two specific milestones, e.g. KYC time → BAV time).
This approximation happened to track closely for most steps but broke specifically for KYC→BAV.
**Treat any number produced by this old method as an unverified approximation, not a confirmed
finding — re-derive via the method below before reporting a specific pointed claim (e.g. "step X
dropped by Ypt") to anyone.**

**New finding, same day, that makes the old workaround unnecessary: `conversion_window` is a literal
row-level column on `dev_cefi.cube_onboarding_funnels`** (confirmed via direct `SELECT *`), with
values like `'1d'`, `'7d'` etc. — **table grain is one row per (user_id, conversion_window)**, not
one row per user. This fully explains the original "broken intermediate family" fan-out bug: an
**unfiltered** query sums `SUM(x_converted)` across every conversion_window duplicate per user while
`COUNT(DISTINCT user_id)` collapses them — inflating the ratio by roughly the number of window
variants. **Once filtered to a single `conversion_window` value, each user has exactly one row, the
fan-out disappears, and the "broken" charts (8458, 8459, 8461, 8462, 8543, 8555, 8556) become
genuinely safe and should be trusted directly** — confirmed by pulling all of them filtered to
`conversion_window IN ('1d')` + `orm_tagging IN ('marketing','organic')` and finding internally
consistent, non-impossible values (40–95% range, nothing over 100%) that reconciled exactly with a
live Superset dashboard screenshot using the same native filters.

**Practical method, confirmed working 2026-10-05, supersedes the old "derive from two Signup-to-X
counts" fix above**: pull the actual intermediate-stage chart (8458/8459/8461/8462/8543/8555/8556),
but inject `{'col':'conversion_window','op':'IN','val':['<window>']}` into every query in its
`query_context.queries[]`, alongside any other native filter the question needs (e.g.
`{'col':'orm_tagging','op':'IN','val':['marketing','organic']}`), before POSTing to
`/api/v1/chart/data` — same mechanism a dashboard's native filters use under the hood. This gives
the exact number a human would see on the live filtered dashboard, not an approximation. **Also
works as a fallback when `run_sql.sh` (SQL Lab's `/api/v1/sqllab/execute/`) is down** — confirmed
2026-10-05 during a real SQL Lab outage (503/504 on every attempt, including a trivial `SELECT 1`)
while `/api/v1/chart/data` stayed fully healthy throughout. `fetch_chart.sh` itself doesn't yet
support injecting extra filters (it only overrides the TEMPORAL_RANGE value) — until it does, build
the filtered query_context by hand the way this fix did: fetch `/api/v1/chart/<id>`, parse
`query_context`, append filter dicts to each `queries[].filters` list, POST to `/api/v1/chart/data`.
**One subtlety to watch**: each intermediate chart buckets by the week of its *own* left-hand
milestone's timestamp (e.g. PAN→Aadhaar% buckets by week of `pan_verified_time`, not
`signup_date`) — check `colnames[0]` on each pull rather than assuming `signup_date` throughout.

**Caveat that still applies**: all of this is a **signup-cohort, no-fixed-window** view (a cohort's
conversion keeps accumulating for as long as the data exists, not bounded to a calendar month) —
the most recent 1-2 weeks of any pull will always read lower than reality simply because that
cohort hasn't had time to finish converting yet. Don't read a recent-week decline on this family as
a real trend without checking whether it's just cohort immaturity.

**Automated as of 2026-10-01**: `fetch_chart.sh` now auto-flags this — any chart on datasource id
1117 (this dataset) whose name contains "%" comes back with a non-null `caution` field warning to
cross-check, so this no longer depends on remembering the rule by hand.

**Correction, 2026-10-04: chart 8549 ("Onboarding Micro funnel steps converted users (#)") is NOT
a safe raw-count cross-check source like 8547 is — it uses `sum(kyc_to_bav_converted)` etc., not
`count(distinct ...)`, on the same fan-out-prone table.** It may carry the same duplicate-row
inflation as the broken % charts. Use 8547 (which does use `count(distinct case when ... then
user_id end)`) as the trusted raw-count source instead; don't treat 8549 as equivalent to 8547.
Also, 8549 only covers KYC→BAV→Deposit→NAP→FNAP — it has no columns for the pre-KYC steps below.

**New finding, 2026-10-04, corrected same day: of the pre-KYC micro-funnel % charts, 4 are broken
and 1 is fine — don't lump them together.** 8458 PAN->Aadhar%, 8459 Aadhar->Selfie%, 8555
selfie->InO%, 8556 InO->KYC% return literally impossible values (383–487%, i.e. >100%) — confirmed
broken, same `COUNT(DISTINCT...)` denominator vs non-distinct `SUM` numerator mismatch as the
macro-funnel's intermediate-stage family (8461, 8462, 8543). **8457 Signup->PAN%, however, uses the
safe "Signup to X" shape** (`SUM(signup_to_pan_converted)/COUNT(user_id)`, both non-distinct, same
family as 8453) — it was initially lumped in with the broken four on first discovery, which was a
mistake corrected within the same day once the SQL shapes were actually compared side by side.
Trust 8457 directly; don't cross-check it as if it were one of the other four.

**No raw-count chart exists anywhere on the Onboarding dashboard (id 1000) for the pre-KYC steps**
(PAN/Aadhaar/Selfie) to cross-check against — 8547/8549 both start at KYC_verified_users. A
cross-check source was found elsewhere instead: **`dev_onboarding.cube_onboarding_kyc_audits`**,
chart **356 "PAN Verified / Aadhaar Uploaded / Selfie Uploaded Users"** (lives on dashboards
"CeFi:Onboarding Ops" / "Onboarding Ops 2.0", not the Onboarding dashboard itself). This chart has
its own artifact, now diagnosed: **it's written at three different grains that collide on specific
days** — a monthly rollup lands on the 1st of each month (~30x a normal day's value), a weekly
rollup lands on every Monday (~3-7x normal), and every other day is a clean genuine-daily number.
The chart's own `avg()` groupby doesn't separate these, so those specific days balloon. **Fix:
exclude 1st-of-month and Monday rows, keep the rest.** Using 8 clean days (2026-09-24–27,
29–30, 10-02–03) as of this pull: **PAN Verified → Aadhaar Uploaded ≈ 93.6%** (range 89.8–96.0%
across those days), **Aadhaar Uploaded → Selfie Uploaded ≈ 97.9%** (range 96.4–100%) — both tight,
consistent, and nowhere near the broken chart's impossible numbers. Reading: this layer of the
funnel barely leaks once someone's PAN-verified; whatever drop-off is really happening inside KYC
is concentrated either before PAN verification succeeds (retries/rejections that never register as
"verified" in this counter) or after Selfie, at the name/identity-matching step feeding into KYC
itself — consistent with the VOC finding that name-mismatch complaints dominate the KYC-stage
contact volume. **Correction: Signup → PAN now has a trustworthy number after all** — see above,
chart 8457 is in the safe "Signup to X" family, not the broken one. The flagged-as-untrustworthy
state only applied until the SQL-shape comparison was actually done; it's resolved as of this pull.

### Trusted primitives — Signup→Deposit funnel, quick reference (don't re-derive, just use these)

The investigation above took real effort to sort safe from broken; this table is the payoff —
look here first before re-deriving anything on this funnel.

| Want | Use | Why it's safe |
|---|---|---|
| Signup → PAN % | Chart **8457** directly | Safe "Signup to X" shape, verified |
| Signup → Aadhaar % | Chart **8024** / **8085** ("Signup to Aadhar") directly | Same safe shape |
| Signup → Selfie % | Chart **8026** ("Signup to Selfie") directly | Same safe shape |
| Signup → KYC % | Chart **8453** directly | Verified against independent distinct-signup cross-check across 13 weeks, within 1-2pp every time |
| Signup → BAV % | Chart **8454** directly | Same safe shape as 8453 |
| Signup → Deposit % | Chart **8455** directly | Same safe shape as 8453 |
| Signup → NAP % | Chart **8456** directly | Same safe shape as 8453 |
| Signup → FNAP % | Chart **8531** directly | Same safe shape (not independently re-verified, but same formula family) |
| True distinct weekly Signups (absolute #) | Chart **9322** | `count(distinct case when signup_date is not null then user_id end)` — the ONLY safe absolute signup count found; do NOT use 8547's own `Signups` column, see below |
| True distinct KYC/BAV/Deposit/NAP/FNAP (absolute #) | Chart **8547** | Every column except `Signups` itself uses `count(distinct case when ... then user_id end)` — trustworthy |
| **Any intermediate-stage step** (PAN→Aadhaar, Aadhaar→Selfie, KYC→BAV, BAV→Deposit, Deposit→NAP) | **Use the direct chart** (8458/8459/8461/8462/8543), but inject a `conversion_window` filter (e.g. `IN ('1d')`) into its query_context before calling `/api/v1/chart/data` — see the 2026-10-05 correction above | Safe once filtered to one `conversion_window` value (eliminates the fan-out). **Do NOT** derive it by dividing two "Signup to X" counts — confirmed to produce false findings (a fake -5pt KYC→BAV dip that didn't exist) |
| A true **calendar-month** version of any of the above (not weekly-cohort-blended) | `run_sql.sh` directly against `dev_cefi.cube_onboarding_funnels`, using `count(distinct user_id)` / `count(distinct case when <x>_time is not null then user_id end)` patterns, `GROUP BY date_trunc('month', signup_date)` | Confirmed working 2026-10-04; more accurate than blending weekly cohorts, no extra approximation |

**Known traps, already paid for — don't re-pay them:**
- 8547's own `Signups` column (`count(user_id)`, no DISTINCT) is ~5x inflated — use chart 9322 instead for the denominator.
- 8549 is not a safe raw-count source despite living on the same tab as 8547 — it uses `sum(...)`, not `count(distinct...)`.
- The whole family is a **signup-cohort, no-fixed-window** view — the most recent 1-2 weeks always read low from immaturity, not a real decline.
- For live-day/live-month numbers on **Futures specifically** (AVPU/ATPU/DAU/MAU, not the onboarding funnel), the row-level `dev_databricks_models.stg_daily_trading_volume` table (confirmed live through today, not stale) is the right source via `run_sql.sh` — see its own entry below. Its `trades` column is execution/fill-level, not distinct order count — don't silently label it ATPU/AOV without that caveat.

---

## `dev_databricks_models.stg_daily_trading_volume` (live row-level trade data, not a dashboard)

Discovered 2026-10-04 while chasing a Futures AVPU/ATPU/DAU question that the stale
`cube_engagement_metrics` couldn't answer. **This table is genuinely live** — `max(trade_date)`
returned today's date on direct query, not a stale cutoff — and it's row-level (one row per
user/day/product/market/order_type/etc. combination, with a `trades` count and `volume_usdt`
summed into that row), not a pre-aggregated cube. Also backs 40 charts on "Business Finance
Dashboard" and a handful of orphaned/unattached charts (full list: Transacting Users trend/by-
product/by-sub-product variants, a Compliance Volume Monitoring suite, and a Delta/API-volume
suite for Futures that exists as charts but isn't on any dashboard) — see `search_charts.sh`
output for `datasource_id=9` if that list is ever needed again.

**Key columns**: `trade_date`, `user_id`, `product` (spot/futures/options/insta), `trades` (count —
**fills/executions, not confirmed to equal distinct orders placed** — don't silently call this
ATPU or AOV without that caveat), `volume_usdt`, plus dozens of dimension columns (channel, VIP
level, order type, market, device, first-txn-per-product timestamps, etc.) for slicing further.

**Confirmed-good queries via `run_sql.sh`** (database_id 8, the default):
- Daily DAU/orders/volume for a product: `SELECT trade_date, count(distinct user_id), sum(trades), sum(volume_usdt) FROM dev_databricks_models.stg_daily_trading_volume WHERE product='<x>' AND trade_date >= '<date>' GROUP BY trade_date`
- True monthly transacting users (real MAU/MTU, not a proxy): same query with `trade_date` bounded to a calendar month, no GROUP BY — e.g. Futures MTU for Sep 2026 = 177,100 (cross-validated exactly against the separate "Transacting Users Trend by Product" chart 10582 for the same month — this table and that chart agree).
- AVPU = `sum(volume_usdt)/count(distinct user_id)` for whatever window — reliable, volume and user-distinctness both behave correctly here (unlike the broken onboarding-funnel family, this table has no known fan-out issue).

---

## Superset-wide metadata index (2026-10-01)

This Superset instance has **169 dashboards and 9,969 charts** total — far beyond the 11-12
dashboards this skill deep-walks. Per the hybrid plan: don't deep-crawl everything (would take
~26+ hours of extraction time at the ~9.5s/chart rate this skill runs at, and much of the 169 is
personal/test/duplicate scratch work — confirmed duplicates spotted: a dead 7-month-stale fork of
"Daily Product Metrics", two "CoinDCX | KOL Referred User (I2) Performance" (one active, one
stale), two "Delisting Customer Experience", three "Liq Algo Backtest..." variants, assorted
`test`/`temp`/`[copy]` dashboards). Instead: index cheaply (name/owner/recency via the
Dashboards-list and Charts-list search — this is how "Onboarding dashboard" id 1000 was found from
the keyword "PAN"), and only deep-walk a dashboard's charts the first time someone actually asks a
question that needs it — then cache that result here permanently.

**7 new dashboards shallow-indexed below** (tabs + chart names only, confirmed live/active by
recency and owner count — not yet deep-walked for real data). Use `search_charts`-style keyword
search (dashboard/list and chart/list, both have a working name-search box) to find anything not
listed here; full raw list of all 169 dashboard names/owners/recency sits in this skill's working
notes, re-pull via the same pagination method if needed (list.html pages, 25 rows each, 7 pages).

### Business Review Dashboard (id 5) — DEEP-WALKED 2026-10-01, no longer shallow
Owners: AG, VK, VS, AP +12 (16 total — highest owner count of anything found, confirmed the
flagship exec dashboard). Modified: 22h ago at time of indexing.
Tabs: Acquisition, Volume/ Revenue, Payments, CX, CeFi, Customer View, VIP Metrics, OKR (AMJ) \|
WIP, Performance marketing metrics, Channel Level Metrics.

*Fully deep-walked via View-as-table: 55/56 charts clean. Raw data: `/tmp/bizreview_extract.jsonl`.
This is a cross-section of nearly every other dashboard's headline metrics in one place — the best
single starting point for any broad "how's the business" question, likely better than assembling
the original 11-dashboard Hawkeye sweep by hand.*

**New issues found, not previously logged anywhere else:**
- **"Channel Performance" (Channel Level Metrics tab) is broken** — `Error: Metric 'Recovery 7D' does not exist`. Different root cause from the `order_exit_failure_perc` bug family — a separate data-eng ticket.
- **"rNPS" (OKR tab) returns N/A across all 20 monthly rows** — silently dead, no error shown. Same failure pattern as Product dashboard's breaches tab: passes a shallow health check (no error) while giving zero actual signal.
- **Three different "CSAT" numbers exist on this one dashboard with no apparent cross-reference**: CX tab ~65–68%, VIP Metrics tab's "CSAT - Chats" ~70–75%, OKR tab's "Overall CSAT" (monthly) ~68–72%. Not necessarily wrong, but a definitional-consistency question worth raising with whoever owns this dashboard before quoting "CSAT" as a single number.

**Headline numbers (week of Sep 21 2026):** Futures volume $5.66B, Options $4.50B, Spot $100M.
Market share among Indian exchanges: CoinDCX ~81%, CoinSwitch ~13%, WazirX ~6%. 7-day funnel:
Signup→KYC ~46%, →Deposit ~23%, →NAP ~21% (Sep 28 partial week reads lower, as expected — partial-
period trap, see [Known issues](#known-issues)). NAP→FNAP 7-day conversion by channel: KOL highest
(~47–53%), Referral lowest (~14–17%). VIP: ~6.3k current / ~83k ever-VIP. AUC ~$478–567M. M0 volume
trending up Jun→Aug ($955M→$1.57B).

Sample charts (full list in raw file): Naps - Acq user segments, FNaps - user segments, SignUp
Funnels, %NAP -> FNAPs 7 Day Conversion, Volume by Product, Gross Fee by Product, AUC Trend,
Crypto/INR Deposit & Withdrawal (Users & Volume, TAT/Success Rate), Chats & Tickets, CSAT - Chats,
NPS - Score & Responses, Internal MM PnL, Futures profitable and loss users(%), WTU & WAU,
Transacting User - Product/Segment Split, VIP WTU, M0 Volume, CoinDCX/Delta Futures Volume Ratio,
Bot -> Agent Handover Rate (%), Recon Differences - Top 10 Tokens.

### Acquisition Metrics (id 16)
Owners: PP, VK, IK, VS +3 (7 total). Modified: 16h ago.
Tabs: Trends Tracking, Aggregate Numbers, Futures, Performance Marketing, Referral Programs,
Referral Metrics, AUC & OI.
Sample charts: Demand Index, Expected vs Actual NAPs, Signups, NAPs, NAPs ORM, Overall Blended CAC,
Signup -> KYC/BAV/Deposit/NAP (7 Days) Funnel, **Signup -> FNAP (7 Days) Funnel**, FNAPs, New
FNAPs, FNAPs by User Segment, %NAP -> FNAPs 7 Day Conversion, Channel wise Split (Naps/FNaps/TNaps),
NAP to FNAP %, NAP to TNAP %, AVPU/AOV/ATPU split by NAPs/FNAPs/TNAPs, Referral D1-D60 Retention,
AUC Futures, AUC Spot. **This dashboard already has the Signup->KYC->BAV->Deposit->NAP->FNAP
funnel built as native (7-day window) charts** — next time anyone asks for this funnel, pull it
from here directly instead of reconstructing it across Onboarding dashboard (id 1000) + Options
Business Dashboard (id 676) the way this skill did on 2026-10-01. Also introduces **TNAP** (a third
acquisition category alongside NAP/FNAP, not yet defined anywhere in this inventory — check this
dashboard's own glossary/tooltips before quoting it).

### CX OKR Metrics & Contact Ratio (id 764)
Owners: RM, IS, HB (3 total). Modified: 18h ago.
Tabs: CX WBR, Contact Ratio, Cases, CSAT, AHR, FRT, FuRT, Avg Agent Response Time, VOC Funnel, Last
Week Increase, By Volume.
Sample charts: CX WBR Overview, Weekly/Main-Menu/Daily-Hourly Contact Ratio (multiple
denominators: Trading Users vs Node Active Users), Top 5 Issues that increased last week (per
main menu), Feedbacks by L0/L1/L3 node, Daily DSAT Trend, AHR (Bot->Agent Handover Rate) at
multiple granularities, Agent FRT/FuRT outlier heatmaps. **Likely the canonical source for contact
ratio** — Daily Product Metrics' "Daily Contact Ratio" charts are probably a downstream mirror of
this dashboard, not the original source.

### Recon Dashboard (id 903)
Owners: TD, PR, UA, KM +2 (6 total). Modified: a day ago.
Tabs: SPOT, Earn/Advance Earn Ledger, WEB3 Transfers, Options Ledger, Staking Ledger, User credit
debit, Corporate OTC Ledger, Internal Txn View, Futures, Payments CDW, Tab, Options Recon data.
Sample charts: Spot/Earn/Web3/Options/Staking/Futures user liability & corporate asset ledgers,
Recon Status - Exchange wise, Token-Level Reconciliation Summary, Realized/Unrealized PnL Recon,
Funding Recon, Order-Level Reconciliation Summary. Finance/treasury reconciliation — not a
business-pulse dashboard, relevant for data-integrity or finance questions specifically, not for
Hawkeye's usual CXO briefing.

### CX Master Dashboard 2 (id 441)
Owners: IS, HB, RM (3 total). Modified: a day ago. (Note: a stale "CX Master Dashboard" — no "2" —
also exists, 29 days old; this "2" is the live successor, don't confuse them.)
Tabs: New VOC Funnel, Repeat Cases Analysis, INR CX reach-out deep dive, AHR Deep Dive, Bot Health,
Compliance, Cases Volume, Contact Ratio, Funnel Accuracy, DSAT VOC. **115 charts total** — by far
the largest single dashboard found in this pass, a deep CX/bot-ops diagnostic tool (intent
accuracy, bot fallback/block reasons, repeat-case analysis by L0/L1/L2 node). Full chart list
captured but not reproduced here in full; re-pull via this dashboard's own tab-by-tab chart listing
if a CX deep-dive question needs it — too granular to usefully summarize further without a
specific question driving it.

### New POR and AUC Dashboard - ALM Gap Visibility (id 2627)
Owners: AJ, UA (2 total). Modified: 19h ago.
Tabs: Glossary, POR/Asset, AUC/Liability, GAP - Asset Liability, Trends for Liability and Assets.
Sample charts: Total Assets (by product: Futures/Spot/US Perp/Cedefi/Okto/Options/Other), AUC/
Liability on this date (by product and legal entity), GAP Analysis Product Level, GAP in $ Timewise
Trend, Asset/Liability Trend Datewise by product/entity/ledger type. Treasury/compliance — Proof
of Reserves and Assets Under Custody gap tracking. Has its own **Glossary tab** — read that first
if ever asked to pull from here, POR/AUC/ALM terminology isn't established anywhere else in this
inventory.

### Invest Business Dashboard [Spot Tracker] (id 824)
Owners: Nishchal Prajapati, Aryan Tiwari, Anudeep Verma, Dibyansu Diptiman (4 total).

**Full chart list pulled 2026-10-04 via `fetch_dashboard.sh`** (previously only shallow-indexed by
name/owner/recency — this is now the real chart-id map, not yet deep-walked for actual values).
5 tabs, 27 charts:
- **Business summary**: Spot & Insta AVPU-ARPU (6821), Spot & Insta Transacting Users (6824),
  Spot \| Insta Take Rate (8109), Volume: Insta & Spot (6842), Fee: SPOT & Insta (6843), Rejection
  Rate (6823), Spot Market Share % : Major Indian Exchanges (5880), Global Spot Volume Ratio %
  (3524)
- **Active Portfolios**: Active portfolios trend (10824), x User-type (10825), Portfolio churn
  (10826), Spot AUC/User (10827), Spot AUC (10928), New CAPs: D30 portfolio-churn (10929)
- **Acquisition**: NAPs x Channels (6835), CAC: Referrals (9227)
- **Funnels** (native pre-NAP funnel, all here): Signup -> KYC (7133), KYC -> BAV (7135), BAV ->
  Deposit (7136), Deposit -> NAP (7137), Signup -> NAP (7138) — prefer this tab over reconstructing
  the funnel across multiple dashboards, same flag as Acquisition Metrics (id 16) elsewhere in this
  doc.
- **Retention levers**: Portfolio retention % (10829), New Earn Users (10830), Earn adopted users
  trend (10831), New SIP Users (10832), SIP Adopted Users Trend (10833), SIP Instalment success %
  (10834), SIPs Cancelled Trend (6833), Earn AUC Trend (7102), Earn eligible AUC trend (7134)

This is the Spot-side counterpart to Futures Tracker (id 597) — notably was missing from Hawkeye's
original 11-dashboard map despite Spot being a core business line. Not yet deep-walked for actual
values (all chart ids above are confirmed to exist and resolve via `fetch_dashboard.sh`, but none
have been pulled with `fetch_chart.sh` yet to confirm live/graphical/broken status) — do that the
first time a real question needs a number from here.

## Known issues

These are structural facts about the data platform itself, not scraping artifacts. Report them
as findings when a Hawkeye View run hits them — don't silently work around them or re-discover
them as if new.

**The `order_exit_failure_perc` SQL bug is live identically on 3 dashboards**: Product dashboard,
Daily Product Metrics, and Futures product Metrics. One unresolved-column error
(`UNRESOLVED_COLUMN.WITH_SUGGESTION`), one root cause, three dashboards blind to Order Exit
Failure %. Worth escalating to data eng as one ticket, not three.

**Two separate backend pipelines, don't conflate them:**
- `Cefi-Dev-DBT-Databricks` — affects Options (Market Level Data, most of Retention), Futures
  product Metrics (liquidations, retention, segmentation — status as of 2026-10-01, some of these
  unchecked this pass), Trading Volumes (Source Level), Crypto Market Volume (Token Category tab).
  **Futures Tracker's 5 previously-affected tabs (Acquisition/Retention/Resurrection/OKR
  View/Targets-Progress) flipped fully live on 2026-10-01** — see that dashboard's own section for
  the full flap-magnitude note; don't assume it's still down there.
- `Cefi-SQL-Endpoint-Analysis` — affects Daily Metrics only (Resurrection & Retention, AnA tabs).

**The Databricks pipeline flaps — it is not simply "down."** Within a single session, four
separate dashboards (Futures product Metrics Business Health, US Perps Advisory Overview,
Advisory Expert Calls Overview, Advisory Business Metrics Summary) were observed live with real
numbers, then pipeline-down on a later recheck. **Treat a single pipeline-down read as
inconclusive and retry once before reporting it as an outage.** If it's still down on retry,
report it as down; if it flips back to live, use the live numbers and note the flap. The
2026-10-01 Futures Tracker re-walk shows this flap can be much bigger than one chart at a time —
an entire dashboard's worth of tabs flipped from mostly-down to fully-live between visits 6 days
apart.

**"Silently dead" charts are a distinct failure mode from pipeline-down or broken — worth watching
for specifically.** Confirmed twice now: Product dashboard's breaches tab (Order Cancellation/TPSL
Placement/Chart Load Failure %, all return N/A across a stale year-old date range, no error shown)
and Business Review Dashboard's "rNPS" (N/A across all 20 monthly rows, no error). These pass a
shallow "did it error?" health check while giving zero actual signal — don't assume "no error
visible" means "the chart works."

**"Silently wrong" is a third, worse failure mode — found 2026-10-01 on Onboarding dashboard's
"BAV -> Deposit%" (chart 8462): no error, real-looking numbers, but 241%-336% for a metric that
cannot exceed 100%.** Root cause looks like a SQL fan-out (numerator summing across duplicate/joined
rows per user while the denominator stays a clean distinct-user count). Unlike silently-dead charts
(obviously N/A, at least gets noticed), a silently-wrong chart produces a plausible-shaped number
that passes a casual glance — the only catch is cross-referencing against an independent
absolute-count source for the same metric. Do this cross-check by default on any chart whose name
contains a bare "%" sign and whose dataset is `dev_cefi.cube_onboarding_funnels` or similar
user-funnel cubes, not just when a number looks obviously off.

**`order_exit_failure_perc` bug's broader family, found 2026-10-01:** Business Review Dashboard's
"Channel Performance" chart errors on a different missing metric (`Recovery 7D`) — same *class* of
problem (a metric/column the chart references no longer exists in the underlying model) but a
different root cause from the `order_exit_failure_perc` bug above. Don't conflate the two when
escalating to data eng — two separate tickets.

**Partial-period trap.** The most recent week/day bucket on Daily Metrics (CLM Metrics tab) and
Crypto Market Volume regularly reads as a false collapse — e.g. Binance's own spot volume
dropping from $71.8B to $322M week-over-week, which isn't a real market move. Before quoting a
"latest period" number from either dashboard, sanity-check it isn't sitting at a suspiciously
round-number-zero relative to the prior period.

**Reward Hub cohort tapering (Daily Metrics, RH-Non RH tab):** RH Users drops sharply in the most
recent weeks (2.8k→371→61→8→1). Unconfirmed whether this is a real wind-down or a tagging/data-lag
artifact — flag it, don't assert either explanation without checking with the data owner.

## Competitive reference data

Global Futures Volume by exchange, most recent full week observed (week of Sep 14–20 2026, from
Crypto Market Volume dashboard, Global Vs CoinDCX tab):

| Exchange | Weekly Volume |
|---|---|
| Binance | $342B |
| OKEx | $169B |
| Bybit | $104B |
| Gate.io | $91.8B |
| Coinbase | $54.5B |
| Bitget | $47.7B |
| Delta India | $21B |
| Huobi | $9.95B |
| Deribit | $7.11B |
| Kraken | $7.37B |
| KuCoin | $6.97B |
| **CoinDCX** | **$5.57B** |

Re-pull this table fresh each run rather than reusing these numbers — it's here as a reference for
table shape and which exchanges to expect, not as current data.
