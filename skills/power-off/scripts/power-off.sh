#!/bin/sh
# Power off this machine. Linux, macOS, WSL (powers off the Windows host), Git Bash/MSYS/Cygwin.
# Usage: power-off.sh [--dry-run]   (--dry-run only prints the command)
# Waits 5s before powering off so the calling agent can finish its reply; Ctrl+C or killing it cancels.
set -u
dry=0; [ "${1-}" = "--dry-run" ] && dry=1

case "$(uname -s)" in
  Darwin) os=macos ;;
  MINGW*|MSYS*|CYGWIN*) os=windows ;;
  Linux)
    if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2>/dev/null; then os=wsl; else os=linux; fi ;;
  *) echo "power-off: unsupported OS: $(uname -s)" >&2; exit 2 ;;
esac

case "$os" in
  linux)
    if command -v systemctl >/dev/null 2>&1; then set -- systemctl poweroff
    else set -- poweroff; fi ;;
  macos)   set -- osascript -e 'tell app "System Events" to shut down' ;;
  wsl)
    exe=shutdown.exe
    command -v "$exe" >/dev/null 2>&1 || exe=/mnt/c/Windows/System32/shutdown.exe
    set -- "$exe" /s /t 0 ;;
  windows) set -- shutdown.exe //s //t 0 ;;  # doubled slashes stop MSYS rewriting them into paths
esac

echo "power-off: detected $os; command: $*"
[ "$dry" = 1 ] && exit 0
sleep 5
exec "$@"
