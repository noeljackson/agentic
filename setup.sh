#!/bin/bash
#
# Agentic Setup Script
# Symlinks Claude Code configuration from this repo to ~/.claude
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

# --- Flags ---
case "${1:-}" in
  --status)
    echo "Commands:"
    ls -la "$CLAUDE_DIR/commands/" 2>/dev/null | grep -- '->'
    echo ""
    echo "Plugins:"
    ls -la "$CLAUDE_DIR/plugins/" 2>/dev/null | grep -- '->'
    echo ""
    echo "Settings:"
    ls -la "$CLAUDE_DIR/settings.local.json" 2>/dev/null
    exit 0
    ;;
  --uninstall)
    echo "Removing agentic symlinks..."
    find "$CLAUDE_DIR/commands" -type l -lname "$SCRIPT_DIR/*" -delete 2>/dev/null || true
    [ -L "$CLAUDE_DIR/plugins/superpowers" ] && rm "$CLAUDE_DIR/plugins/superpowers"
    [ -L "$CLAUDE_DIR/settings.local.json" ] && rm "$CLAUDE_DIR/settings.local.json"
    echo "Done."
    exit 0
    ;;
  --help|-h)
    echo "Usage: setup.sh [--status|--uninstall|--help]"
    echo ""
    echo "  (no args)    Install symlinks from this repo to ~/.claude"
    echo "  --status     Show current symlink state"
    echo "  --uninstall  Remove symlinks pointing to this repo"
    exit 0
    ;;
esac

echo "Installing agentic..."

# Remove stale symlinks before creating directories
for dir in commands plugins; do
  if [ -L "$CLAUDE_DIR/$dir" ]; then
    echo "  Removing stale symlink: $CLAUDE_DIR/$dir"
    rm "$CLAUDE_DIR/$dir"
  fi
done

# Create ~/.claude structure
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/plugins"

# Symlink all commands (individual files, not the directory)
for f in "$SCRIPT_DIR/.claude/commands"/*; do
  [ -f "$f" ] || continue
  name="$(basename "$f")"
  target="$CLAUDE_DIR/commands/$name"
  # Remove existing symlink or file
  [ -L "$target" ] && rm "$target"
  [ -f "$target" ] && rm "$target"
  ln -sf "$f" "$target"
  echo "  Linked: commands/$name"
done

# Symlink superpowers plugin (directory)
if [ -d "$SCRIPT_DIR/.claude/plugins/superpowers" ]; then
  target="$CLAUDE_DIR/plugins/superpowers"
  [ -L "$target" ] && rm "$target"
  [ -d "$target" ] && rm -rf "$target"
  ln -sfn "$SCRIPT_DIR/.claude/plugins/superpowers" "$target"
  echo "  Linked: plugins/superpowers"
fi

# Symlink settings.local.json
if [ -f "$SCRIPT_DIR/.claude/settings.local.json" ]; then
  target="$CLAUDE_DIR/settings.local.json"
  [ -L "$target" ] && rm "$target"
  ln -sf "$SCRIPT_DIR/.claude/settings.local.json" "$target"
  echo "  Linked: settings.local.json"
fi

# Symlink MEMORY.md as global CLAUDE.md
target="$CLAUDE_DIR/CLAUDE.md"
[ -L "$target" ] && rm "$target"
ln -sf "$SCRIPT_DIR/MEMORY.md" "$target"
echo "  Linked: CLAUDE.md -> MEMORY.md"

echo ""
echo "Agentic installed. Run './setup.sh --status' to verify."
