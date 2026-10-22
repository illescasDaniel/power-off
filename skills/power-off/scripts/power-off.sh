#!/bin/sh
# Power off (or suspend) this machine. Linux, macOS, WSL (acts on the Windows host), Git Bash/MSYS/Cygwin.
# Usage: power-off.sh [--sleep] [--dry-run]   (--sleep suspends instead of powering off; --dry-run only prints the command)
# Waits 5s first so the calling agent can finish its reply; Ctrl+C or killing it cancels.
set -u
dry=0; mode=off
for a in "$@"; do
  case "$a" in
    --dry-run) dry=1 ;;
    --sleep) mode=sleep ;;
    *) echo "power-off: unknown option: $a" >&2; exit 2 ;;
  esac
done

case "$(uname -s)" in
  Darwin) os=macos ;;
  MINGW*|MSYS*|CYGWIN*) os=windows ;;
  Linux)
    if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2>/dev/null; then os=wsl; else os=linux; fi ;;
  *) echo "power-off: unsupported OS: $(uname -s)" >&2; exit 2 ;;
esac

case "$os/$mode" in
  linux/off)
    if command -v systemctl >/dev/null 2>&1; then set -- systemctl poweroff
    else set -- poweroff; fi ;;
  linux/sleep) set -- systemctl suspend ;;
  macos/off)   set -- osascript -e 'tell app "System Events" to shut down' ;;
  macos/sleep) set -- pmset sleepnow ;;
  wsl/*|windows/*)
    # WSL and Git Bash call the Windows executables; doubled slashes stop MSYS rewriting them into paths.
    exe=shutdown.exe
    if [ "$os" = wsl ]; then
      command -v "$exe" >/dev/null 2>&1 || exe=/mnt/c/Windows/System32/shutdown.exe
      flags="/s /t 0"
    else
      flags="//s //t 0"
    fi
    if [ "$mode" = sleep ]; then set -- rundll32.exe powrprof.dll,SetSuspendState 0,1,0
    else set -- "$exe" $flags; fi ;;
esac

echo "power-off: detected $os ($mode); command: $*"
[ "$dry" = 1 ] && exit 0
sleep 5
exec "$@"
