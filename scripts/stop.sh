#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  ArchLens - Stopping All Services${NC}"
echo -e "${CYAN}========================================${NC}"

MODE="${1:-local}"

if [ "$MODE" = "docker" ]; then
    echo -e "\n${YELLOW}Stopping all Docker Compose services...${NC}"
    ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
    cd "$ROOT_DIR"
    docker-compose --profile obs down
else
    echo -e "\n${YELLOW}[1/3] Stopping .NET services...${NC}"
    for proc in ArchLens.Auth.Api ArchLens.Upload.Api ArchLens.Orchestrator.Api ArchLens.Report.Api ArchLens.Notification.Api ArchLens.Gateway; do
        pids=$(pgrep -f "$proc" 2>/dev/null || true)
        if [ -n "$pids" ]; then
            echo "$pids" | xargs kill 2>/dev/null || true
            echo -e "  ${GREEN}✓${NC} Stopped $proc"
        else
            echo -e "  ${YELLOW}-${NC} $proc not running"
        fi
    done

    echo -e "\n${YELLOW}[2/3] Stopping AI Processing (Python)...${NC}"
    pids=$(pgrep -f "uvicorn app.main:app" 2>/dev/null || true)
    if [ -n "$pids" ]; then
        echo "$pids" | xargs kill 2>/dev/null || true
        echo -e "  ${GREEN}✓${NC} Stopped AI Processing"
    else
        echo -e "  ${YELLOW}-${NC} AI Processing not running"
    fi

    echo -e "\n${YELLOW}[3/3] Stopping Frontend (Next.js)...${NC}"
    pids=$(pgrep -f "next dev" 2>/dev/null || true)
    if [ -n "$pids" ]; then
        echo "$pids" | xargs kill 2>/dev/null || true
        echo -e "  ${GREEN}✓${NC} Stopped Frontend"
    else
        echo -e "  ${YELLOW}-${NC} Frontend not running"
    fi

    echo -e "\n${YELLOW}Stopping infrastructure (Docker)...${NC}"
    ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
    cd "$ROOT_DIR"
    docker-compose --profile obs down
fi

echo -e "\n${GREEN}All services stopped!${NC}"
