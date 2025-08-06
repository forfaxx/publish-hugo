#!/usr/bin/env bash
#
# publish.sh — Safely build and deploy your Hugo site with git snapshotting
# Usage: ./publish.sh
#
# - Stops any running Hugo server
# - Optionally commits and pushes changes to git
# - Builds with hugo (cleanly)
# - Rsyncs public/ to your web host
# - Warns and prompts before destructive or network steps

set -euo pipefail

### [0] CONFIGURABLES
REMOTE_HOST="yourwebhost"                # e.g. 'mycoolserver', or hostname in ~/.ssh/config
REMOTE_PATH="/home/USERNAME/public_html" # Path to your site’s web root on remote server
HUGO_PROJECT_DIR="$HOME/path/to/your-hugo-project"  # Local path to your Hugo site
RSYNC_FLAGS="-av --delete"
DRYRUN=0  # Set to 1 for testing (never pushes real changes)!

### [1] STOP HUGO SERVER IF RUNNING
echo -e "\033[1;36m▶️  Stopping hugo server (if running)...\033[0m"
pkill -f "hugo server" && echo "Stopped hugo server." || echo "(No hugo server running.)"

### [2] ENSURE WE’RE IN THE PROJECT DIR
cd "$HUGO_PROJECT_DIR" || { echo "Failed to cd to $HUGO_PROJECT_DIR"; exit 1; }

### [3] CLEAN AND REBUILD
echo -e "\033[1;36m🧹 Cleaning public/ directory...\033[0m"
rm -rf ./public

echo -e "\033[1;36m🔨 Building site with hugo --cleanDestinationDir...\033[0m"
hugo --cleanDestinationDir

### [4] OPTIONAL: GIT SNAPSHOT & PUSH
echo -e "\033[1;36m🔍 Checking git status...\033[0m"
if [[ -d ".git" ]]; then
    if [[ -n "$(git status --porcelain)" ]]; then
        echo -e "\033[1;33m⚠️  Uncommitted changes detected:\033[0m"
        git status -s
        git diff --stat || true

        read -p "Do you want to stage, commit, and push all changes? [y/N]: " gans
        if [[ "$gans" =~ ^[Yy]$ ]]; then
            # List .md articles changed for the commit message
            changed_files=$(git status --porcelain | awk '{print $2}' | grep -E '\.md$' | xargs)
            articles=$(echo "$changed_files" | tr '\n' ' ')
            now=$(date +"%Y-%m-%d %H:%M")
            msg="sync-hugo: $articles ($now)"
            git add .
            git commit -m "$msg"
            git push
            echo -e "\033[1;32m✅ Git commit & push complete.\033[0m"
        else
            echo "Skipped git commit."
        fi
    else
        echo -e "\033[1;32m✔ Git working tree is clean.\033[0m"
    fi
else
    echo -e "\033[1;31m(Not a git repo: skipping git step.)\033[0m"
fi

### [4.5] CHECK FOR DRAFT POSTS
if grep -R "draft: true" content/**/*.md >/dev/null 2>&1; then
    echo -e "\033[1;33m⚠️  Draft posts detected!\033[0m"
    grep -R "draft: true" content/**/*.md | sed 's/^/    • /'
    echo -e "\033[1;33mFlip them to draft: false if you meant to publish.\033[0m"
    echo
fi

### [5] FINAL PROMPT BEFORE DEPLOY
echo
read -p "🚚 Ready to rsync public/ to ${REMOTE_HOST}:${REMOTE_PATH}? [y/N]: " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborting before rsync."
    exit 0
fi

### [6] DEPLOY VIA RSYNC
echo -e "\033[1;36m🚀 Deploying with rsync...\033[0m"
if [[ $DRYRUN -eq 1 ]]; then
    rsync $RSYNC_FLAGS --dry-run ./public/ "${REMOTE_HOST}:${REMOTE_PATH}"
    echo "Dry-run complete. No files transferred."
else
    rsync $RSYNC_FLAGS ./public/ "${REMOTE_HOST}:${REMOTE_PATH}"
    echo -e "\033[1;32m🎉 Deployed to $REMOTE_HOST:$REMOTE_PATH\033[0m"
fi

echo -e "\033[1;36mAll done. ✨\033[0m"

if command -v fortune >/dev/null; then
    echo
    # Print fortune, wrap in quotes, color yellow
    fortune | head -n 3 | sed '1s/^/"/; $s/$/"/' | while IFS= read -r line; do
        echo -e "\033[1;33m$line\033[0m"
    done
fi
