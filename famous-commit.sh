#!/usr/bin/env bash

set -e

declare -a PEOPLE=(
  "Linus Torvalds|torvalds@linux-foundation.org"
  "Guido van Rossum|guido@python.org"
  "Yukihiro Matsumoto (Matz)|matz@ruby.or.jp"
  "Sindre Sorhus|sindresorhus@gmail.com"
  "Brendan Eich|brendan@mozilla.org"
  "Ryan Dahl|ry@tinyclouds.org"
  "John Resig|jeresig@gmail.com"
  "Addy Osmani|addyosmani@gmail.com"
  "Chris Lattner|clattner@nondot.org"
  "Kent C. Dodds|kent@doddsfamily.us"
  "Evan You|yyx990803@gmail.com"
  "Rich Harris|richard.harris@gmail.com"
)

red()    { printf "\033[0;31m%s\033[0m\n" "$*"; }
green()  { printf "\033[0;32m%s\033[0m\n" "$*"; }
yellow() { printf "\033[0;33m%s\033[0m\n" "$*"; }
bold()   { printf "\033[1m%s\033[0m\n" "$*"; }

cleanup() {
  if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
  fi
}
trap cleanup EXIT

if ! command -v gh >/dev/null 2>&1; then
  red "Error: GitHub CLI (gh) is not installed."
  echo "Install it from https://cli.github.com/"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  red "Error: You are not logged in with gh."
  echo "Run:  gh auth login"
  exit 1
fi

# Get repo URL
echo
bold "Famous Commit Tool 🐧"
echo "Add an empty commit as a legendary developer so they appear in the contributors list."
echo
read -rp "Paste GitHub repo URL (e.g. https://github.com/user/repo): " REPO_URL

REPO_URL="${REPO_URL%.git}"
REPO_URL="${REPO_URL%/}"
if [[ "$REPO_URL" =~ github\.com[:/]([^/]+)/([^/]+)$ ]]; then
  OWNER="${BASH_REMATCH[1]}"
  REPO="${BASH_REMATCH[2]}"
else
  red "Could not parse GitHub repo from: $REPO_URL"
  exit 1
fi

FULL_REPO="$OWNER/$REPO"
green "Target: $FULL_REPO"

# Menu
echo
bold "Select who you want to add as author:"
echo

for i in "${!PEOPLE[@]}"; do
  name="${PEOPLE[$i]%%|*}"
  printf "  [%2d]  %s\n" $((i+1)) "$name"
done
echo "  [ 0]  Cancel"

echo
read -rp "Choice: " CHOICE

if [[ "$CHOICE" == "0" || -z "$CHOICE" ]]; then
  yellow "Cancelled."
  exit 0
fi

if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || (( CHOICE < 1 || CHOICE > ${#PEOPLE[@]} )); then
  red "Invalid choice."
  exit 1
fi

INDEX=$((CHOICE-1))
SELECTED="${PEOPLE[$INDEX]}"
AUTHOR_NAME="${SELECTED%%|*}"
AUTHOR_EMAIL="${SELECTED##*|}"

echo
green "Selected: $AUTHOR_NAME <$AUTHOR_EMAIL>"

TEMP_DIR=$(mktemp -d)
echo
yellow "Cloning $FULL_REPO into temporary directory..."

gh repo clone "$FULL_REPO" "$TEMP_DIR" -- --depth 1 --quiet

cd "$TEMP_DIR"

# Create the empty commit
git -c user.name="$AUTHOR_NAME" -c user.email="$AUTHOR_EMAIL" \
  commit --allow-empty -m "Empty commit so $AUTHOR_NAME appears as a contributor ✨"

echo
yellow "Pushing..."
git push origin HEAD

echo
green "Done! $AUTHOR_NAME should now appear in the contributors list of $FULL_REPO"
echo "   (It can take a minute for GitHub to update the graph)"
