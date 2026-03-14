#!/bin/bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  ArchLens - Commit & Push All Repos${NC}"
echo -e "${CYAN}========================================${NC}"

MESSAGE="${1:-feat: update ArchLens services}"
PUSH="${2:-yes}"

REPOS=(
    "archlens-auth-service"
    "archlens-upload-service"
    "archlens-orchestrator-service"
    "archlens-report-service"
    "archlens-notification-service"
    "archlens-gateway"
    "archlens-ai-processing"
    "archlens-frontend"
)

SUCCESS=0
SKIPPED=0
FAILED=0

for repo in "${REPOS[@]}"; do
    REPO_PATH="$ROOT_DIR/$repo"

    if [ ! -d "$REPO_PATH/.git" ]; then
        echo -e "\n${YELLOW}⚠${NC} $repo - not a git repo, skipping"
        ((SKIPPED++))
        continue
    fi

    cd "$REPO_PATH"

    if [ -z "$(git status --porcelain)" ]; then
        echo -e "\n${YELLOW}-${NC} $repo - no changes"
        ((SKIPPED++))
        continue
    fi

    echo -e "\n${CYAN}▸${NC} $repo"

    git add -A
    PRE_COMMIT_ALLOW_NO_CONFIG=1 git commit -m "$MESSAGE" 2>&1 | tail -1
    echo -e "  ${GREEN}✓${NC} Committed"

    if [ "$PUSH" = "yes" ]; then
        BRANCH=$(git branch --show-current)
        if git remote get-url origin &>/dev/null; then
            git push origin "$BRANCH" 2>&1 | tail -1
            echo -e "  ${GREEN}✓${NC} Pushed to origin/$BRANCH"
        else
            echo -e "  ${YELLOW}⚠${NC} No remote 'origin' configured"
        fi
    fi

    ((SUCCESS++))
done

echo -e "\n${CYAN}========================================${NC}"
echo -e "${CYAN}  Summary${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "  ${GREEN}✓ Committed/Pushed:${NC} $SUCCESS"
echo -e "  ${YELLOW}- Skipped:${NC} $SKIPPED"
echo -e "  ${RED}✗ Failed:${NC} $FAILED"

# Also handle root repo if it has changes
cd "$ROOT_DIR"
if [ -d ".git" ] && [ -n "$(git status --porcelain)" ]; then
    echo -e "\n${CYAN}▸${NC} root (fase5)"
    git add -A
    PRE_COMMIT_ALLOW_NO_CONFIG=1 git commit -m "$MESSAGE" 2>&1 | tail -1
    if [ "$PUSH" = "yes" ] && git remote get-url origin &>/dev/null; then
        BRANCH=$(git branch --show-current)
        git push origin "$BRANCH" 2>&1 | tail -1
        echo -e "  ${GREEN}✓${NC} Root repo pushed"
    fi
fi

echo -e "\n${GREEN}Done!${NC}"
