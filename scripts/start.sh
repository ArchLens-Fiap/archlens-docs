#!/bin/bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  ArchLens - Starting All Services${NC}"
echo -e "${CYAN}========================================${NC}"

MODE="${1:-local}"

if [ "$MODE" = "docker" ]; then
    echo -e "\n${YELLOW}[1/2] Starting infrastructure + services via Docker Compose...${NC}"
    docker-compose up -d --build
    echo -e "\n${YELLOW}[2/2] Waiting for services to be healthy...${NC}"
    sleep 10
else
    echo -e "\n${YELLOW}[1/4] Starting infrastructure (Docker)...${NC}"
    docker-compose up -d postgres rabbitmq minio minio-init mongodb redis
    echo -e "Waiting for infrastructure to be ready..."
    sleep 10

    echo -e "\n${YELLOW}[2/4] Starting observability stack (Prometheus)...${NC}"
    docker-compose --profile obs up -d
    echo -e "  Prometheus: ${CYAN}http://localhost:9090${NC}"

    echo -e "\n${YELLOW}[3/4] Starting .NET services locally...${NC}"

    declare -A SERVICES=(
        ["auth"]="archlens-auth-service/src/ArchLens.Auth.Api"
        ["upload"]="archlens-upload-service/src/ArchLens.Upload.Api"
        ["orchestrator"]="archlens-orchestrator-service/src/ArchLens.Orchestrator.Api"
        ["report"]="archlens-report-service/src/ArchLens.Report.Api"
        ["notification"]="archlens-notification-service/src/ArchLens.Notification.Api"
        ["gateway"]="archlens-gateway/src/ArchLens.Gateway"
    )

    mkdir -p /tmp/archlens-logs

    for name in auth upload orchestrator report notification gateway; do
        path="${SERVICES[$name]}"
        echo -e "  Starting ${CYAN}$name${NC}..."
        cd "$ROOT_DIR/$path"
        nohup dotnet run --launch-profile http > "/tmp/archlens-logs/$name.log" 2>&1 &
        cd "$ROOT_DIR"
    done

    echo -e "\n${YELLOW}[4/4] Starting AI Processing (Python) + Frontend...${NC}"
    PYTHON_BIN=$(command -v python3.13 || command -v python3.12 || command -v python3.11 || command -v python3)
    cd "$ROOT_DIR/archlens-ai-processing"
    nohup "$PYTHON_BIN" -m uvicorn app.main:app --host 0.0.0.0 --port 8000 > /tmp/archlens-logs/ai-processing.log 2>&1 &
    cd "$ROOT_DIR"

    echo -e "  Starting ${CYAN}frontend${NC}..."
    cd "$ROOT_DIR/archlens-frontend"
    nohup npm run dev > /tmp/archlens-logs/frontend.log 2>&1 &
    cd "$ROOT_DIR"

    echo -e "\nWaiting for services to start..."
    sleep 20
fi

echo -e "\n${CYAN}========================================${NC}"
echo -e "${CYAN}  Health Checks${NC}"
echo -e "${CYAN}========================================${NC}"

declare -A ENDPOINTS=(
    ["Gateway:5000"]="http://localhost:5000/health"
    ["Auth:5120"]="http://localhost:5120/health"
    ["Upload:5066"]="http://localhost:5066/health"
    ["Orchestrator:5089"]="http://localhost:5089/health"
    ["Report:5205"]="http://localhost:5205/health"
    ["Notification:5150"]="http://localhost:5150/health"
    ["AI Processing:8000"]="http://localhost:8000/api/health"
    ["Frontend:3000"]="http://localhost:3000"
    ["Prometheus:9090"]="http://localhost:9090/-/healthy"
)

for name in "Gateway:5000" "Auth:5120" "Upload:5066" "Orchestrator:5089" "Report:5205" "Notification:5150" "AI Processing:8000" "Frontend:3000" "Prometheus:9090"; do
    url="${ENDPOINTS[$name]}"
    status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$url" 2>/dev/null || echo "000")
    if [ "$status" = "200" ]; then
        echo -e "  ${GREEN}✓${NC} $name ${GREEN}Healthy${NC}"
    else
        echo -e "  ${RED}✗${NC} $name ${RED}Unreachable ($status)${NC}"
    fi
done

echo -e "\n${GREEN}Done!${NC} Logs at: /tmp/archlens-logs/"
echo -e "Frontend: ${CYAN}http://localhost:3000${NC}"
echo -e "Gateway:  ${CYAN}http://localhost:5000${NC}"
echo -e "\nTest logins:"
echo -e "  User:  ${YELLOW}user${NC} / ${YELLOW}User@123${NC}"
echo -e "  Admin: ${YELLOW}admin${NC} / ${YELLOW}Admin@123${NC}"
