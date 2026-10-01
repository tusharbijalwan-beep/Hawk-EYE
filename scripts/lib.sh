#!/bin/bash
# Shared helpers for Hawkeye's API-based Superset access.
# Source this from other scripts: source "$(dirname "$0")/lib.sh"
#
# Portable across machines/users as of 2026-10-01 — nothing below should be
# specific to any one person's filesystem. If you're setting this up fresh and
# `agent-browser` isn't found, or Chrome isn't at a standard location, set
# HAWKEYE_CHROME_PATH yourself before sourcing this file:
#   export HAWKEYE_CHROME_PATH="/path/to/your/Google Chrome"

# Make sure `agent-browser` is reachable without assuming a specific Node
# version or install method. If it's already on PATH, do nothing. Otherwise,
# search nvm's installed versions (any version, not a hardcoded one) for a bin
# dir that has it. If it's genuinely not installed anywhere, install it —
# confirmed 2026-10-01: it's a real, dependency-free npm package
# (agent-browser@0.38.1, registry.npmjs.org, no deps), safe and small to
# auto-install the first time a teammate's Claude Code session needs it. This
# runs as a normal Bash tool call, so the host's own permission system (if any)
# still gets a say — this isn't bypassing that, just making the *command* to
# run automatic instead of a manual prerequisite someone has to look up.
if ! command -v agent-browser >/dev/null 2>&1; then
  for _d in "$HOME"/.nvm/versions/node/*/bin; do
    if [ -x "$_d/agent-browser" ]; then
      export PATH="$_d:$PATH"
      break
    fi
  done
  unset _d
fi
if ! command -v agent-browser >/dev/null 2>&1; then
  if command -v npm >/dev/null 2>&1; then
    echo "agent-browser not found — installing it now (npm install -g agent-browser)..." >&2
    npm install -g agent-browser >/dev/null 2>&1
  fi
  if ! command -v agent-browser >/dev/null 2>&1; then
    echo "ERROR: agent-browser still not found after attempting install." >&2
    echo "  If npm isn't available, install Node.js first, then run: npm install -g agent-browser" >&2
  fi
fi

HAWKEYE_BASE="https://reporting.dcxtools.com"
HAWKEYE_SESSION_NAME="dcxtools"
HAWKEYE_CACHE_DIR="${TMPDIR:-/tmp}/hawkeye_cache"
HAWKEYE_CACHE_TTL="${HAWKEYE_CACHE_TTL:-300}"  # seconds; override per-call with env var if needed

mkdir -p "$HAWKEYE_CACHE_DIR" 2>/dev/null || true

# Chrome path: respect an explicit override first (set this yourself if your
# install is somewhere unusual), else try the standard locations in order of
# likelihood. If nothing's found anywhere AND agent-browser is available,
# self-provision one — `agent-browser install` downloads a Chrome build into
# agent-browser's own cache (confirmed: this is its documented fix for exactly
# this case). Once that cache exists, agent-browser finds it automatically on
# its own without needing --executable-path at all, so HAWKEYE_CHROME_PATH can
# stay empty after this — it's only a problem if BOTH this detection and
# agent-browser's own cache lookup come up empty.
if [ -z "${HAWKEYE_CHROME_PATH:-}" ]; then
  for _c in \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    "$HOME/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"; do
    if [ -x "$_c" ]; then
      HAWKEYE_CHROME_PATH="$_c"
      break
    fi
  done
  unset _c
fi
if [ -z "${HAWKEYE_CHROME_PATH:-}" ] && command -v agent-browser >/dev/null 2>&1; then
  if ! agent-browser --version >/dev/null 2>&1; then
    : # agent-browser itself broken; nothing more to try here
  else
    echo "No Chrome install found — running 'agent-browser install' to fetch one (one-time, ~100MB)..." >&2
    agent-browser install >/dev/null 2>&1 || true
  fi
fi

# Prints the raw `session=...` cookie string, or empty if none/expired.
hawkeye_get_cookie() {
  agent-browser --session "$HAWKEYE_SESSION_NAME" cookies get --domain "$(echo "$HAWKEYE_BASE" | sed -E 's#https?://##')" 2>/dev/null \
    | grep -o 'session=[^;]*' | head -1
}

# Returns 0 if the cookie authenticates, 1 otherwise. Distinguishes "no response
# at all" (local browser process likely dead — recoverable without a human) from
# "401" (genuinely expired — needs a human for SSO+MFA) via the $2 out-param.
# Usage: hawkeye_check_session "$cookie" reason_var
#   reason_var is set to "unreachable" or "expired" or "" (success) in the caller's scope.
hawkeye_check_session() {
  local cookie="$1"
  local __reason_var="${2:-}"
  if [ -z "$cookie" ]; then
    [ -n "$__reason_var" ] && printf -v "$__reason_var" '%s' "unreachable"
    return 1
  fi
  local code
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 8 -b "$cookie" "$HAWKEYE_BASE/api/v1/chart/?q=(page_size:1)" 2>/dev/null) || code="000"
  if [ "$code" = "401" ]; then
    [ -n "$__reason_var" ] && printf -v "$__reason_var" '%s' "expired"
    return 1
  fi
  if [ "$code" != "200" ]; then
    [ -n "$__reason_var" ] && printf -v "$__reason_var" '%s' "unreachable"
    return 1
  fi
  [ -n "$__reason_var" ] && printf -v "$__reason_var" '%s' ""
  return 0
}

# The main entry point every script should use instead of calling get_cookie +
# check_session directly. Handles the "local browser process died" case
# (confirmed to happen — a CDP crash mid-session on 2026-10-01) automatically,
# with one headless restore-and-retry, no human needed. Only a genuinely
# expired session (401) still needs a human for SSO+MFA — that can't be
# automated around, ever.
#
# Prints the valid cookie to stdout on success. On failure, prints nothing to
# stdout, prints a clear actionable message to stderr, and returns 1.
hawkeye_ensure_session() {
  local cookie reason
  cookie=$(hawkeye_get_cookie)
  if hawkeye_check_session "$cookie" reason; then
    echo "$cookie"
    return 0
  fi

  if [ "$reason" = "expired" ]; then
    echo "ERROR: session cookie present but expired (401 from Superset API)." >&2
    echo "  This needs a human: re-run the browser login flow in SKILL.md Setup Step 2 (headed SSO+MFA)." >&2
    return 1
  fi

  # reason == "unreachable": could just be a dead local browser process
  # (agent-browser's Chrome crashed, saved cookies are still fine) — try one
  # automatic recovery before giving up. HAWKEYE_CHROME_PATH may be empty here
  # even on a fully-working setup — agent-browser checks its own install cache
  # first (including anything `agent-browser install` fetched at source time),
  # so only pass --executable-path when we actually found an explicit one;
  # otherwise let agent-browser's own detection do the work.
  echo "Session unreachable, attempting automatic recovery (headless restore)..." >&2
  if [ -n "${HAWKEYE_CHROME_PATH:-}" ]; then
    agent-browser --session "$HAWKEYE_SESSION_NAME" --restore open "$HAWKEYE_BASE/superset/welcome/" --executable-path "$HAWKEYE_CHROME_PATH" >/dev/null 2>&1
  else
    agent-browser --session "$HAWKEYE_SESSION_NAME" --restore open "$HAWKEYE_BASE/superset/welcome/" >/dev/null 2>&1
  fi
  sleep 3
  cookie=$(hawkeye_get_cookie)
  if hawkeye_check_session "$cookie" reason; then
    echo "Recovered." >&2
    echo "$cookie"
    return 0
  fi

  if [ "$reason" = "expired" ]; then
    echo "ERROR: session expired (401) even after recovery attempt." >&2
    echo "  This needs a human: re-run the browser login flow in SKILL.md Setup Step 2 (headed SSO+MFA)." >&2
  else
    echo "ERROR: could not reach Superset even after one automatic recovery attempt." >&2
    echo "  Check network connectivity, or that agent-browser itself is working (agent-browser --session $HAWKEYE_SESSION_NAME get url)." >&2
  fi
  return 1
}

# Prints a fresh CSRF token for the given cookie, or empty on failure.
hawkeye_get_csrf() {
  local cookie="$1"
  curl -s -b "$cookie" "$HAWKEYE_BASE/api/v1/security/csrf_token/" | python3 -c "import json,sys; print(json.load(sys.stdin).get('result',''))" 2>/dev/null
}

# --- Response cache -----------------------------------------------------
# Keyed by an arbitrary string (callers use e.g. "chart_<id>"). TTL in
# seconds, default $HAWKEYE_CACHE_TTL (300s / 5min). A cache hit means a
# repeat question (or a cross-check pull) in the same working window skips
# the network round trip entirely.

hawkeye_cache_path() {
  local key="$1"
  # sanitize key to a safe filename
  echo "$HAWKEYE_CACHE_DIR/$(echo "$key" | tr -c 'a-zA-Z0-9_.-' '_').json"
}

# Prints cached content to stdout and returns 0 if a fresh entry exists;
# returns 1 (prints nothing) if missing or stale.
hawkeye_cache_get() {
  local key="$1"
  local ttl="${2:-$HAWKEYE_CACHE_TTL}"
  local path
  path=$(hawkeye_cache_path "$key")
  [ -f "$path" ] || return 1
  local age
  age=$(( $(date +%s) - $(stat -f %m "$path" 2>/dev/null || stat -c %Y "$path" 2>/dev/null || echo 0) ))
  if [ "$age" -gt "$ttl" ]; then
    return 1
  fi
  cat "$path"
  return 0
}

# Stores content (read from stdin) under key.
hawkeye_cache_set() {
  local key="$1"
  local path
  path=$(hawkeye_cache_path "$key")
  cat > "$path"
}
