#!/usr/bin/env bash

# Change to the directory where this script lives, so git commands always run
# from the project root regardless of where the user double-clicks in Finder.
cd "$(dirname "$0")"

# ── Formatting ────────────────────────────────────────────────────────────────
BOLD="\033[1m"
DIM="\033[2m"
CYAN="\033[0;36m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

HUGO_PID=""

cleanup() {
    tput cnorm 2>/dev/null
    [[ -n "$HUGO_PID" ]] && kill "$HUGO_PID" 2>/dev/null
    printf "\n"
}
trap cleanup EXIT

# ── Arrow-key menu ────────────────────────────────────────────────────────────
# Sets global $SELECTED to the 0-based index of the chosen option.
# Usage: select_option "Label 1" "Label 2" ...
SELECTED=0
select_option() {
    local options=("$@")
    local count=${#options[@]}
    SELECTED=0

    _draw_menu() {
        local i
        for i in "${!options[@]}"; do
            if [[ "$i" -eq "$SELECTED" ]]; then
                printf "  ${CYAN}${BOLD}> ${options[$i]}${RESET}\n"
            else
                printf "    ${options[$i]}\n"
            fi
        done
    }

    tput civis
    tput sc      # save cursor — redraw restores here instead of counting lines
    _draw_menu

    while true; do
        IFS= read -rsn1 key
        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 -t 1 seq || seq=""  # -t 1 (integer) for bash 3.2 compatibility
            case "$seq" in
                '[A') (( SELECTED-- )); [[ "$SELECTED" -lt 0 ]] && SELECTED=$(( count - 1 )) ;;
                '[B') (( SELECTED++ )); [[ "$SELECTED" -ge "$count" ]] && SELECTED=0 ;;
            esac
        elif [[ "$key" == "" ]]; then
            break
        fi
        tput rc
        _draw_menu
    done

    tput cnorm
    printf "\n"
}

# ── Start hugo silently in the background ─────────────────────────────────────
start_hugo_bg() {
    if ! command -v hugo &>/dev/null; then
        printf "${YELLOW}  (Hugo is not installed — live preview unavailable.\n"
        printf "   Ask your developer to run: brew install hugo)${RESET}\n"
        return 1
    fi

    hugo server > /dev/null 2>&1 &
    HUGO_PID=$!

    printf "Starting blog preview"
    local i
    for (( i=0; i<20; i++ )); do
        sleep 0.5
        printf "."
        if curl -sf "http://localhost:1313/papermod/" > /dev/null 2>&1; then
            printf "\n"
            open "http://localhost:1313/papermod/" 2>/dev/null
            printf "${GREEN}Your blog is live at: ${BOLD}http://localhost:1313/papermod/${RESET}\n"
            printf "${DIM}The preview stops automatically when you close this window.${RESET}\n"
            return 0
        fi
    done

    printf "\n${YELLOW}Hugo is taking a while to start. Try opening ${BOLD}http://localhost:1313/papermod/${RESET}${YELLOW} manually.${RESET}\n"
}

# ── Publish changes ───────────────────────────────────────────────────────────
publish_changes() {
    printf "\nWrite a short note about what you changed.\n"
    printf "${DIM}For example: \"added new post about Tokyo\"${RESET}\n"
    printf "> "
    IFS= read -r note
    [[ -z "$note" ]] && note="update blog"

    printf "\nPublishing your changes...\n"
    if git add . && git commit -m "$note" && git push origin main; then
        printf "\n${GREEN}${BOLD}All done! Your changes have been published.${RESET}\n"
        printf "Vercel will update your live blog in about a minute.\n"
    else
        printf "\n${RED}Something went wrong. Please contact your developer for help.${RESET}\n"
    fi
}

# ── Greeting ──────────────────────────────────────────────────────────────────
clear
printf "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
printf "${BOLD}   Hi Yuri! Welcome to your Blog Manager (\`・ω・´)${RESET}\n"
printf "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n\n"

# ── Step 1: Check for remote updates ─────────────────────────────────────────
printf "Checking for updates from the cloud...\n"
if git fetch origin main 2>/dev/null; then
    BEHIND=$(git rev-list HEAD..origin/main --count 2>/dev/null)
    BEHIND=${BEHIND:-0}
else
    BEHIND=0
    printf "${YELLOW}  (Could not reach the internet — skipping update check)${RESET}\n"
fi

if [[ "$BEHIND" -gt 0 ]]; then
    printf "\n${YELLOW}There are ${BOLD}${BEHIND}${RESET}${YELLOW} new update(s) in the cloud you don't have yet.${RESET}\n"
    printf "Would you like to download them?\n\n"

    select_option "Yes, download the updates" "No, skip for now"

    if [[ "$SELECTED" -eq 0 ]]; then
        printf "Downloading...\n"
        if git pull origin main; then
            printf "${GREEN}Done! Your blog is now up to date.${RESET}\n"
        else
            printf "\n${RED}Something went wrong. Please contact your developer.${RESET}\n"
            read -rp $'\nPress Enter to close...'
            ( sleep 0.1 && osascript -e 'tell application "Terminal" to close front window' 2>/dev/null ) &
            exit 1
        fi
    else
        printf "OK, skipping the update.\n"
    fi
else
    printf "${GREEN}Your blog is already up to date.${RESET}\n"
fi

printf "\n"

# ── Step 2: Check local changes and show menu ────────────────────────────────
CHANGED=$(git status --porcelain 2>/dev/null)

print_changes() {
    printf "You have the following changes on your computer:\n\n"
    while IFS= read -r line; do
        code="${line:0:2}"
        file="${line:3}"
        case "$code" in
            " M"|"M "|"MM") label="Modified" ;;
            "??"           ) label="New file" ;;
            " D"|"D "      ) label="Deleted"  ;;
            "A "           ) label="New file" ;;
            "R "           ) label="Renamed"  ;;
            *              ) label="Changed"  ;;
        esac
        printf "  ${CYAN}${label}:${RESET}  ${file}\n"
    done <<< "$CHANGED"
    printf "\n"
}

if [[ -n "$CHANGED" ]]; then
    print_changes
    printf "What would you like to do?\n\n"
    select_option "Preview my blog in the browser" "Publish (upload) my changes" "Exit"

    case "$SELECTED" in
        0)  start_hugo_bg
            printf "\nWhat would you like to do?\n\n"
            select_option "Publish (upload) my changes" "Exit"
            [[ "$SELECTED" -eq 0 ]] && publish_changes
            ;;
        1)  publish_changes ;;
    esac
else
    printf "There are no new changes on your computer.\n\n"
    printf "What would you like to do?\n\n"
    select_option "Preview my blog in the browser" "Exit"

    if [[ "$SELECTED" -eq 0 ]]; then
        start_hugo_bg
        printf "\nWhat would you like to do?\n\n"
        select_option "Exit"
    fi
fi

( sleep 0.1 && osascript -e 'tell application "Terminal" to close front window' 2>/dev/null ) &
