#!/bin/sh

set -e

SCRIPT_DIR=$(dirname "$0")

SESSION_FILE="session.txt"
SESSION=""
YEAR=$(date "+%Y")
DAY=$(date "+%d")
TEMPLATE=""

usage() {
    echo "Usage: $0 [-f session_file] [-s session] [-y year] [-d day] [-t template]" >&2
    echo "  -f FILE    Session file (default: session.txt)" >&2
    echo "  -s TOKEN   Session token (overrides file)" >&2
    echo "  -y YEAR    Year (default: current year)" >&2
    echo "  -d DAY     Day (default: current day)" >&2
    echo "  -t NAME    Template name passed to new.sh" >&2
    exit 1
}

while getopts "f:s:y:d:t:h" opt; do
    case "$opt" in
        "f")
            SESSION_FILE=$OPTARG
            ;;
        "s")
            SESSION=$OPTARG
            ;;
        "y")
            YEAR=$OPTARG
            ;;
        "d")
            DAY=$OPTARG
            ;;
        "t")
            TEMPLATE=$OPTARG
            ;;
        "h")
            usage
            ;;
        \?)
            echo "[!] invalid option: -$OPTARG" >&2
            usage
            ;;
    esac
done

shift "$((OPTIND - 1))"
[ -n "$TEMPLATE" ] && echo "[*] Template = $TEMPLATE"

set -- "$SCRIPT_DIR/new.sh"
[ -n "$YEAR" ] && set -- "$@" -y "$YEAR"
[ -n "$DAY" ] && set -- "$@" -d "$DAY"
[ -n "$TEMPLATE" ] && set -- "$@" -t "$TEMPLATE"

echo "[*] Running new.sh to create the day..."
NEW_OUTPUT=$("$@" )

printf '%s\n' "$NEW_OUTPUT"

DAY_DIR=$(printf '%s\n' "$NEW_OUTPUT" | tail -n 1 | sed 's/^.*: *//')
if [ -z "$DAY_DIR" ]; then
    echo "[!] Could not determine day directory from new.sh output" >&2
    exit 2
fi

echo "[*] Detected day directory: $DAY_DIR"

INPUT_PATH="$DAY_DIR/input.txt"
PROMPT_PATH="$DAY_DIR/prompt.txt"
run_get() {
    set -- "$SCRIPT_DIR/get.sh"
    [ -n "$SESSION_FILE" ] && set -- "$@" -f "$SESSION_FILE"
    [ -n "$SESSION" ]      && set -- "$@" -s "$SESSION"
    set -- "$@" -y "$YEAR" -d "$DAY" -o "$INPUT_PATH"
    "$@" &
}

run_prompt() {
    set -- "$SCRIPT_DIR/prompt.sh"
    [ -n "$SESSION_FILE" ] && set -- "$@" -f "$SESSION_FILE"
    [ -n "$SESSION" ]      && set -- "$@" -s "$SESSION"
    set -- "$@" -y "$YEAR" -d "$DAY" -o "$PROMPT_PATH"
    "$@" &
}

echo "[^] Fetching input and prompt..."
run_get
PID_GET=$!

run_prompt
PID_PROMPT=$!

wait "$PID_GET"
wait "$PID_PROMPT"

echo "[*] Input saved to  : $INPUT_PATH"
echo "[*] Prompt saved to : $PROMPT_PATH"

if [ ! -f "$PROMPT_PATH" ]; then
    echo "[!] Prompt file not found: $PROMPT_PATH" >&2
    exit 3
fi

PAGER_CMD=${PAGER:-less}
echo "[*] Opening prompt in $PAGER_CMD..."
exec "$PAGER_CMD" "$PROMPT_PATH"
