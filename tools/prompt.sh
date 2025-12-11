#!/bin/sh

clean_prompt() {
    sed -n '
/<article/,/<\/article>/{
        s/<\/p>/\
\
/g
        s/<\/code>/`/g
        s/<code>/`/g
        s/<em>/*/g
        s/<\/em>/*/g
        s/<[^>]*>//g
        s/^[[:space:]]*//; s/[[:space:]]*$//
        /^[[:space:]]*$/d
        p
}
'
}

SESSION_FILE="session.txt"
SESSION=""
YEAR=$(date +%Y)
DAY=$(date +%d)
USE_STDOUT=0
OUTFILE="prompt.txt"

while getopts "f:s:y:d:o:i" opt; do
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
        "o")
            OUTFILE=$OPTARG
            ;;
        "i")
            USE_STDOUT=1
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

SESSION=$(printf %s "$SESSION" | tr -d "[:space:]")

HTML=$(curl -sS \
    -H "Cookie: session=$SESSION" \
    "https://adventofcode.com/$YEAR/day/$DAY")

if [ "$USE_STDOUT" -eq 1 ]; then
    printf "%s\n" "$(printf '%s\n' "$HTML" | clean_prompt)"
else
    printf "%s\n" "$(printf '%s\n' "$HTML" | clean_prompt)" > "$OUTFILE"
    echo "[*] Saved cleaned prompt to $OUTFILE"
fi
