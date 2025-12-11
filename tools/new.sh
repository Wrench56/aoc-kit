#!/bin/sh

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
TEMPLATE_ROOT=${TEMPLATE_ROOT:-"$SCRIPT_DIR/../templates"}

YEAR=$(date "+%Y")
DAY=$(date "+%d")
TEMPLATE="asm"

usage() {
    echo "Usage: $0 [-y year] [-d day] [-t template]" >&2
    exit 1
}

while getopts "y:d:t:h" opt; do
    case "$opt" in
        y)
            YEAR=$OPTARG
            echo "[*] Year explicitly set to $YEAR"
            ;;
        d)
            DAY=$OPTARG
            echo "[*] Day explicitly set to $DAY"
            ;;
        t)
            TEMPLATE=$OPTARG
            echo "[*] Template explicitly set to '$TEMPLATE'"
            ;;
        h)
            usage
            ;;
        \?)
            echo "[!] Invalid option: -$OPTARG" >&2
            usage
            ;;
    esac
done
shift "$((OPTIND - 1))"

case $YEAR in
    [0-9][0-9][0-9][0-9]) : ;;
    *)
        echo "[!] Invalid year: $YEAR" >&2
        exit 2
        ;;
esac

case $DAY in
    *[!0-9]*|'')
        echo "[!] Invalid day: $DAY" >&2
        exit 3
        ;;
esac

DAY_PADDED=$(printf "%02d" "$DAY")
CURR_YEAR=$(date "+%Y")

echo "[*] Creating scaffold for year $YEAR, day $DAY_PADDED"

years_root=""

for d in *; do
    case $d in
        [0-9][0-9][0-9][0-9])
            if [ -d "$d" ]; then
                years_root="."
                break
            fi
            ;;
    esac
done

if [ -z "$years_root" ]; then
    for parent in *; do
        if [ -d "$parent" ]; then
            found_year=""
            for d in "$parent"/*; do
                case $d in
                    */*)
                        base=${d##*/}
                        ;;
                    *)
                        base=$d
                        ;;
                esac
                case $base in
                    [0-9][0-9][0-9][0-9])
                        if [ -d "$d" ]; then
                            found_year=1
                            break
                        fi
                        ;;
                esac
            done
            if [ -n "$found_year" ]; then
                years_root=$parent
                break
            fi
        fi
    done
fi

if [ -z "$years_root" ]; then
    if [ "$YEAR" -lt "$CURR_YEAR" ] 2>/dev/null; then
        echo "[!] This repo does not appear to support multiple years yet." >&2
        echo "[!] No existing year directories found." >&2
        echo "[*] About to create a new year directory '$YEAR' in the current directory." >&2
        printf "Continue? [y/N]: " >&2
        read -r ans || exit 1
        case $ans in
            y|Y) : ;;
            *) echo "[*] Aborted." >&2; exit 4 ;;
        esac
    fi
    years_root="."
fi

if [ "$years_root" = "." ]; then
    year_dir=$YEAR
else
    year_dir=$years_root/$YEAR
fi

day_dir=$year_dir/day$DAY_PADDED

if [ ! -d "$year_dir" ]; then
    echo "[*] Creating year directory: $year_dir"
    mkdir -p "$year_dir"
fi

if [ -d "$day_dir" ]; then
    echo "[*] Day directory already exists: $day_dir"
else
    echo "[*] Creating day directory: $day_dir"
    mkdir -p "$day_dir"
fi

tpl_dir=""

if [ -n "$TEMPLATE" ]; then
    tpl_dir=$TEMPLATE_ROOT/$TEMPLATE
elif [ -d "$TEMPLATE_ROOT/default" ]; then
    tpl_dir=$TEMPLATE_ROOT/default
fi

if [ -n "$tpl_dir" ]; then
    if [ ! -d "$tpl_dir" ]; then
        echo "[!] Template directory not found: $tpl_dir" >&2
        exit 5
    fi
    echo "[*] Copying template from: $tpl_dir"
    cp -R "$tpl_dir"/. "$day_dir"/
else
    echo "[*] No template specified and no default template found."
fi

echo "[$] Done. Created: $day_dir"
