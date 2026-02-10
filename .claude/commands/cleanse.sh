#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# claude-cleanse — Safely clean sensitive data from ~/.claude
# ============================================================

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
DRY_RUN=true
AGGRESSIVE=false
SESSIONS_ONLY=false
SCAN_ONLY=false
KEEP_DAYS=7
KEEP_PLANS_DAYS=30
KEEP_HISTORY=500
VERBOSE=false
QUIET=false

# Counters
total_files=0
total_bytes=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# Category tracking
declare -A cat_files
declare -A cat_bytes

usage() {
  cat <<'USAGE'
claude-cleanse — Safely clean sensitive data from ~/.claude

Usage: claude-cleanse [OPTIONS]

Modes:
  (default)         Clean caches + prune sessions >7d + truncate history
  --aggressive      Delete ALL sessions, history, plans, todos, tasks
  --sessions-only   Only clean session data
  --scan            Scan for sensitive patterns without deleting

Options:
  --dry-run         Show what would happen (DEFAULT)
  --execute         Actually perform the cleanup
  --keep-days N     Session retention in days (default: 7)
  --keep-history N  History entries to keep (default: 500)
  --verbose         Show each file being processed
  --quiet           Only show summary
  --help            Show this help
USAGE
}

# --- Argument Parsing ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)     DRY_RUN=true; shift ;;
    --execute)     DRY_RUN=false; shift ;;
    --aggressive)  AGGRESSIVE=true; KEEP_DAYS=0; KEEP_HISTORY=0; KEEP_PLANS_DAYS=0; shift ;;
    --sessions-only) SESSIONS_ONLY=true; shift ;;
    --scan)        SCAN_ONLY=true; shift ;;
    --keep-days)   KEEP_DAYS="$2"; shift 2 ;;
    --keep-history) KEEP_HISTORY="$2"; shift 2 ;;
    --verbose)     VERBOSE=true; shift ;;
    --quiet)       QUIET=true; shift ;;
    --help|-h)     usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

# --- Utilities ---

log() {
  [[ "$QUIET" == true ]] && return
  echo -e "$@"
}

log_verbose() {
  [[ "$VERBOSE" == true ]] && echo -e "  ${DIM}$*${NC}"
}

human_size() {
  local bytes=$1
  if (( bytes >= 1073741824 )); then
    printf "%.1f GB" "$(echo "scale=1; $bytes / 1073741824" | bc)"
  elif (( bytes >= 1048576 )); then
    printf "%.1f MB" "$(echo "scale=1; $bytes / 1048576" | bc)"
  elif (( bytes >= 1024 )); then
    printf "%.1f KB" "$(echo "scale=1; $bytes / 1024" | bc)"
  else
    printf "%d B" "$bytes"
  fi
}

get_cutoff_epoch() {
  local days=$1
  if [[ "$(uname -s)" == "Darwin" ]]; then
    date -v-"${days}d" +%s
  else
    date -d "-${days} days" +%s
  fi
}

get_file_mtime() {
  local file=$1
  if [[ "$(uname -s)" == "Darwin" ]]; then
    stat -f %m "$file" 2>/dev/null || echo 0
  else
    stat -c %Y "$file" 2>/dev/null || echo 0
  fi
}

dir_size() {
  local dir=$1
  if [[ -d "$dir" ]]; then
    du -sk "$dir" 2>/dev/null | awk '{print $1 * 1024}'
  else
    echo 0
  fi
}

file_size() {
  local file=$1
  if [[ -f "$file" ]]; then
    if [[ "$(uname -s)" == "Darwin" ]]; then
      stat -f %z "$file" 2>/dev/null || echo 0
    else
      stat -c %s "$file" 2>/dev/null || echo 0
    fi
  else
    echo 0
  fi
}

track() {
  local category=$1 files=$2 bytes=$3
  cat_files[$category]=$(( ${cat_files[$category]:-0} + files ))
  cat_bytes[$category]=$(( ${cat_bytes[$category]:-0} + bytes ))
  total_files=$(( total_files + files ))
  total_bytes=$(( total_bytes + bytes ))
}

# Remove a directory's contents but recreate the empty directory
remove_dir_contents() {
  local category=$1
  local dir="$CLAUDE_DIR/$2"
  local label=${3:-$2}

  if [[ ! -d "$dir" ]]; then
    return
  fi

  local count
  count=$(find "$dir" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')
  local bytes
  bytes=$(dir_size "$dir")

  if (( count == 0 )); then
    return
  fi

  log_verbose "$label: $count items, $(human_size "$bytes")"

  if [[ "$DRY_RUN" == false ]]; then
    rm -rf "$dir"
    mkdir -p "$dir"
  fi

  track "$category" "$count" "$bytes"
}

remove_file() {
  local category=$1
  local file="$CLAUDE_DIR/$2"

  if [[ ! -f "$file" ]]; then
    return
  fi

  local bytes
  bytes=$(file_size "$file")

  log_verbose "$(basename "$file"): $(human_size "$bytes")"

  if [[ "$DRY_RUN" == false ]]; then
    rm -f "$file"
  fi

  track "$category" 1 "$bytes"
}

# --- Validation ---

validate() {
  if [[ ! -d "$CLAUDE_DIR" ]]; then
    echo "Error: $CLAUDE_DIR does not exist" >&2
    exit 1
  fi

  # Verify it looks like a Claude Code directory
  if [[ ! -f "$CLAUDE_DIR/settings.json" ]] && [[ ! -d "$CLAUDE_DIR/projects" ]] && [[ ! -f "$CLAUDE_DIR/history.jsonl" ]]; then
    echo "Error: $CLAUDE_DIR doesn't look like a Claude Code directory" >&2
    exit 1
  fi

  # Warn if Claude Code is running
  if pgrep -f "claude" > /dev/null 2>&1; then
    log "${YELLOW}Warning:${NC} Claude Code appears to be running. Files in use may not be fully cleaned."
  fi
}

# --- Phase 1: Ephemeral Caches ---

clean_ephemeral() {
  log "${CYAN}Ephemeral caches${NC}"
  remove_dir_contents "paste-cache" "paste-cache" "paste-cache (clipboard)"
  remove_dir_contents "debug" "debug" "debug (session logs)"
  remove_dir_contents "session-env" "session-env" "session-env (empty dirs)"
  remove_dir_contents "shell-snapshots" "shell-snapshots" "shell-snapshots"
  remove_file "cache" "cache/changelog.md"

  # Plugin caches (preserve config files)
  if [[ -d "$CLAUDE_DIR/plugins/cache" ]]; then
    remove_dir_contents "plugin-cache" "plugins/cache" "plugins/cache"
  fi
  remove_file "plugin-cache" "plugins/install-counts-cache.json"
}

# --- Phase 2: Session Pruning ---

clean_sessions() {
  log "${CYAN}Session data${NC}"

  if ! command -v jq &>/dev/null; then
    log "${YELLOW}Warning:${NC} jq not found. sessions-index.json will not be updated."
  fi

  local cutoff
  if [[ "$AGGRESSIVE" == true ]]; then
    cutoff=99999999999  # far future — everything is "older"
  else
    cutoff=$(get_cutoff_epoch "$KEEP_DAYS")
  fi

  # Process each project
  for project_dir in "$CLAUDE_DIR"/projects/*/; do
    [[ -d "$project_dir" ]] || continue

    local project_name
    project_name=$(basename "$project_dir")
    local session_count=0
    local session_bytes=0
    local remaining_ids=()

    # Find and process session JSONL files
    for jsonl in "$project_dir"*.jsonl; do
      [[ -f "$jsonl" ]] || continue

      local mtime
      mtime=$(get_file_mtime "$jsonl")
      local session_id
      session_id=$(basename "$jsonl" .jsonl)

      if (( mtime < cutoff )); then
        local bytes
        bytes=$(file_size "$jsonl")
        local subdir_bytes=0

        # Check for matching UUID subdirectory
        if [[ -d "$project_dir$session_id" ]]; then
          subdir_bytes=$(dir_size "$project_dir$session_id")
        fi

        log_verbose "session $session_id: $(human_size $((bytes + subdir_bytes)))"

        if [[ "$DRY_RUN" == false ]]; then
          rm -f "$jsonl"
          [[ -d "$project_dir$session_id" ]] && rm -rf "$project_dir$session_id"
        fi

        session_count=$((session_count + 1))
        session_bytes=$((session_bytes + bytes + subdir_bytes))
      else
        remaining_ids+=("$session_id")
      fi
    done

    # Rewrite sessions-index.json
    local index_file="$project_dir/sessions-index.json"
    if [[ -f "$index_file" ]] && command -v jq &>/dev/null && (( session_count > 0 )); then
      if [[ "$DRY_RUN" == false ]]; then
        local ids_json
        ids_json=$(printf '%s\n' "${remaining_ids[@]}" | jq -R . | jq -s .)
        jq --argjson keep "$ids_json" \
          '.entries |= map(select(.sessionId as $id | $keep | index($id)))' \
          "$index_file" > "${index_file}.tmp"
        mv "${index_file}.tmp" "$index_file"
      fi
    fi

    if (( session_count > 0 )); then
      log_verbose "$project_name: $session_count sessions, $(human_size "$session_bytes")"
      track "sessions" "$session_count" "$session_bytes"
    fi
  done
}

# --- Phase 3: History Truncation ---

clean_history() {
  log "${CYAN}History${NC}"

  local history_file="$CLAUDE_DIR/history.jsonl"
  [[ -f "$history_file" ]] || return

  local total_lines
  total_lines=$(wc -l < "$history_file" | tr -d ' ')
  local original_bytes
  original_bytes=$(file_size "$history_file")

  if [[ "$AGGRESSIVE" == true ]] || (( KEEP_HISTORY == 0 )); then
    log_verbose "history.jsonl: deleting all $total_lines entries ($(human_size "$original_bytes"))"
    if [[ "$DRY_RUN" == false ]]; then
      rm -f "$history_file"
    fi
    track "history" 1 "$original_bytes"
  elif (( total_lines > KEEP_HISTORY )); then
    local lines_to_remove=$((total_lines - KEEP_HISTORY))
    if [[ "$DRY_RUN" == false ]]; then
      tail -n "$KEEP_HISTORY" "$history_file" > "${history_file}.tmp"
      mv "${history_file}.tmp" "$history_file"
    fi
    local new_bytes
    if [[ "$DRY_RUN" == false ]]; then
      new_bytes=$(file_size "$history_file")
    else
      # Estimate: proportional reduction
      new_bytes=$(( original_bytes * KEEP_HISTORY / total_lines ))
    fi
    local freed=$((original_bytes - new_bytes))
    log_verbose "history.jsonl: truncating from $total_lines to $KEEP_HISTORY entries (~$(human_size "$freed") freed)"
    track "history" "$lines_to_remove" "$freed"
  else
    log_verbose "history.jsonl: $total_lines entries (within limit of $KEEP_HISTORY)"
  fi
}

# --- Phase 4: Auxiliary Age-Based Cleanup ---

clean_auxiliary() {
  log "${CYAN}Auxiliary data${NC}"

  local cutoff
  cutoff=$(get_cutoff_epoch "$KEEP_DAYS")

  local plans_cutoff
  plans_cutoff=$(get_cutoff_epoch "$KEEP_PLANS_DAYS")

  # file-history: UUID-named subdirectories
  if [[ -d "$CLAUDE_DIR/file-history" ]]; then
    local fh_count=0 fh_bytes=0
    for dir in "$CLAUDE_DIR/file-history"/*/; do
      [[ -d "$dir" ]] || continue
      local mtime
      mtime=$(get_file_mtime "$dir")
      if (( mtime < cutoff )); then
        local bytes
        bytes=$(dir_size "$dir")
        fh_count=$((fh_count + 1))
        fh_bytes=$((fh_bytes + bytes))
        [[ "$DRY_RUN" == false ]] && rm -rf "$dir"
      fi
    done
    if (( fh_count > 0 )); then
      log_verbose "file-history: $fh_count dirs, $(human_size "$fh_bytes")"
      track "file-history" "$fh_count" "$fh_bytes"
    fi
  fi

  # todos: JSON files
  if [[ -d "$CLAUDE_DIR/todos" ]]; then
    local td_count=0 td_bytes=0
    for file in "$CLAUDE_DIR/todos"/*.json; do
      [[ -f "$file" ]] || continue
      local mtime
      mtime=$(get_file_mtime "$file")
      if (( mtime < cutoff )); then
        local bytes
        bytes=$(file_size "$file")
        td_count=$((td_count + 1))
        td_bytes=$((td_bytes + bytes))
        [[ "$DRY_RUN" == false ]] && rm -f "$file"
      fi
    done
    if (( td_count > 0 )); then
      log_verbose "todos: $td_count files, $(human_size "$td_bytes")"
      track "todos" "$td_count" "$td_bytes"
    fi
  fi

  # tasks: UUID-named subdirectories
  if [[ -d "$CLAUDE_DIR/tasks" ]]; then
    local tk_count=0 tk_bytes=0
    for dir in "$CLAUDE_DIR/tasks"/*/; do
      [[ -d "$dir" ]] || continue
      local mtime
      mtime=$(get_file_mtime "$dir")
      if (( mtime < cutoff )); then
        local bytes
        bytes=$(dir_size "$dir")
        tk_count=$((tk_count + 1))
        tk_bytes=$((tk_bytes + bytes))
        [[ "$DRY_RUN" == false ]] && rm -rf "$dir"
      fi
    done
    if (( tk_count > 0 )); then
      log_verbose "tasks: $tk_count dirs, $(human_size "$tk_bytes")"
      track "tasks" "$tk_count" "$tk_bytes"
    fi
  fi

  # plans: markdown files (longer retention)
  if [[ -d "$CLAUDE_DIR/plans" ]]; then
    local pl_count=0 pl_bytes=0
    for file in "$CLAUDE_DIR/plans"/*.md; do
      [[ -f "$file" ]] || continue
      local mtime
      mtime=$(get_file_mtime "$file")
      if (( mtime < plans_cutoff )); then
        local bytes
        bytes=$(file_size "$file")
        pl_count=$((pl_count + 1))
        pl_bytes=$((pl_bytes + bytes))
        [[ "$DRY_RUN" == false ]] && rm -f "$file"
      fi
    done
    if (( pl_count > 0 )); then
      log_verbose "plans: $pl_count files, $(human_size "$pl_bytes")"
      track "plans" "$pl_count" "$pl_bytes"
    fi
  fi
}

# --- Scan Mode ---

scan_secrets() {
  log "${BOLD}Scanning for sensitive patterns...${NC}"
  log ""

  local patterns='eyJ[A-Za-z0-9_-]{20,}|sk-[a-zA-Z0-9]{20,}|pk_[a-zA-Z0-9]{20,}|DOPPLER_TOKEN|SUPABASE_SERVICE_ROLE_KEY|postgresql://[^ ]*:[^ ]*@|redis://[^ ]*:[^ ]*@|Bearer [A-Za-z0-9._-]{20,}'

  local scan_dirs=("paste-cache" "debug")
  local scan_files=("history.jsonl")

  for dir in "${scan_dirs[@]}"; do
    local target="$CLAUDE_DIR/$dir"
    [[ -d "$target" ]] || continue
    local count
    count=$(grep -rlE "$patterns" "$target" 2>/dev/null | wc -l | tr -d ' ' || true)
    if (( count > 0 )); then
      log "  ${RED}$dir${NC}: $count files with sensitive patterns"
    else
      log "  ${GREEN}$dir${NC}: clean"
    fi
  done

  for file in "${scan_files[@]}"; do
    local target="$CLAUDE_DIR/$file"
    [[ -f "$target" ]] || continue
    local count
    count=$(grep -cE "$patterns" "$target" 2>/dev/null || true)
    count=${count:-0}
    if (( count > 0 )); then
      log "  ${RED}$file${NC}: $count lines with sensitive patterns"
    else
      log "  ${GREEN}$file${NC}: clean"
    fi
  done

  # Scan session files
  local session_hits=0
  for project_dir in "$CLAUDE_DIR"/projects/*/; do
    [[ -d "$project_dir" ]] || continue
    local count
    count=$(grep -rlE "$patterns" "$project_dir" --include="*.jsonl" 2>/dev/null | wc -l | tr -d ' ' || true)
    session_hits=$((session_hits + count))
  done
  if (( session_hits > 0 )); then
    log "  ${RED}sessions${NC}: $session_hits files with sensitive patterns"
  else
    log "  ${GREEN}sessions${NC}: clean"
  fi

  log ""
}

# --- Summary ---

print_summary() {
  log ""
  local mode_label
  if [[ "$DRY_RUN" == true ]]; then
    mode_label="${YELLOW}DRY RUN${NC}"
  else
    mode_label="${GREEN}EXECUTED${NC}"
  fi

  log "${BOLD}Summary${NC} ($mode_label)"
  log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  printf "${BOLD}%-20s %10s %12s${NC}\n" "Category" "Files" "Space"
  log "─────────────────────────────────────────────"

  for category in paste-cache debug session-env shell-snapshots cache plugin-cache sessions history file-history todos tasks plans; do
    local files=${cat_files[$category]:-0}
    local bytes=${cat_bytes[$category]:-0}
    if (( files > 0 )); then
      printf "%-20s %10d %12s\n" "$category" "$files" "$(human_size "$bytes")"
    fi
  done

  log "─────────────────────────────────────────────"
  printf "${BOLD}%-20s %10d %12s${NC}\n" "TOTAL" "$total_files" "$(human_size "$total_bytes")"
  log ""

  if [[ "$DRY_RUN" == true ]]; then
    log "To execute: ${BOLD}claude-cleanse --execute${NC}"
  fi
}

# --- Main ---

main() {
  log ""
  log "${BOLD}claude-cleanse${NC}"
  log ""

  validate

  if [[ "$SCAN_ONLY" == true ]]; then
    scan_secrets
    exit 0
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log "${YELLOW}DRY RUN${NC} — no files will be modified"
    log ""
  fi

  if [[ "$SESSIONS_ONLY" != true ]]; then
    clean_ephemeral
  fi

  clean_sessions

  if [[ "$SESSIONS_ONLY" != true ]]; then
    clean_history
    clean_auxiliary
  fi

  print_summary
}

main
