#!/bin/sh

set -e

SESSION_FILE="session.txt"
SESSION=""
YEAR=$(date "+%Y")
DAY=$(date "+%d")
OUTFILE="input.txt"
USE_STDOUT=0

while getopts "f:s:o:y:d:i" opt; do
    case "$opt" in
        "f")
            SESSION_FILE="$OPTARG"
            if [ -f "$SESSION_FILE" ]; then
                echo "[*] Session file set to: $SESSION_FILE"
            else
                echo "[!] Session file does not exist!"
                exit 2
            fi
            ;;
        "s")
            SESSION="$OPTARG"
            ;;
        "y")
            YEAR="$OPTARG"
            echo "[*] Year explicitly set to $YEAR"
            ;;
        "d")
            DAY="$OPTARG"
            echo "[*] Day explicitly set to $DAY"
            ;;
        "o")
            OUTFILE="$OPTARG"
            echo "[*] Output file explicitly set to $OUTFILE"
            ;;
        "i")
            USE_STDOUT=1
            echo "[*] Output set as STDOUT"
            ;;
        \?)
            echo "[!] Invalid option: -$OPTARG" >&2
            echo "[*] Usage: $0 [-s session] [-f session file] [-y year] [-d day] [-o output file] [-i use stdout]" >&2
            exit 1
            ;;
    esac
done

if [ -z "$SESSION" ]; then
    SESSION=$(cat "$SESSION_FILE")
fi
if [ "$(printf %s "$SESSION" | tr -d "[:space:]" | wc -c)" -ne 128 ]; then
    echo "[!] Invalid session string!"
    exit 3
fi

echo "[^] Fetching for year $YEAR day $DAY..."
INPUT=$(curl -X GET "https://adventofcode.com/$YEAR/day/$DAY/input" -H "Cookie: session=$SESSION")
echo "[*] Length of input $(printf %s "$INPUT" | wc -c)"
if [ "$USE_STDOUT" -eq 1 ]; then
    printf %s "$INPUT"
else
    printf %s "$INPUT" > "$OUTFILE"
fi
