#!/bin/bash

# ============================================================
# 🚀 ArchLens - Script de Inicialização do Ambiente de Dev
# ============================================================
# Uso: ./scripts/run-dev.sh [--seed]
# --seed  Após subir a infra, aguarda os serviços e roda o seed de demo
# ============================================================

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
INFRA_DIR="$(dirname "$BASE_DIR")/archlens-infra-db"

log()      { echo -e "${GREEN}[$(date +'%H:%M:%S')] ✓ $1${NC}"; }
log_info() { echo -e "${BLUE}[$(date +'%H:%M:%S')] ℹ $1${NC}"; }
log_warn() { echo -e "${YELLOW}[$(date +'%H:%M:%S')] ⚠ $1${NC}"; }
log_err()  { echo -e "${RED}[$(date +'%H:%M:%S')] ✗ $1${NC}"; }

print_header() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║            🔍 ArchLens - Dev Environment Setup               ║${NC}"
    echo -e "${CYAN}║               FIAP 12SOAT - Tech Challenge Fase 5            ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ============================================================
# VERIFICAR DEPENDÊNCIAS
# ============================================================
check_deps() {
    log_info "Verificando dependências..."
    local missing=0

    if ! command -v docker &>/dev/null; then
        log_err "Docker não encontrado. Instale em: https://docs.docker.com/get-docker/"
        missing=1
    fi

    if ! command -v dotnet &>/dev/null; then
        log_err ".NET SDK não encontrado. Instale em: https://dotnet.microsoft.com/download"
        missing=1
    fi

    [ $missing -eq 1 ] && exit 1
    log "Docker: $(docker --version | cut -d' ' -f3 | tr -d ',')"
    log ".NET SDK: $(dotnet --version)"
}

# ============================================================
# SUBIR INFRA
# ============================================================
start_infra() {
    log_info "Subindo infraestrutura (PostgreSQL, MongoDB, Redis, RabbitMQ, MinIO)..."

    if [ ! -d "$INFRA_DIR" ]; then
        log_err "Pasta archlens-infra-db não encontrada em: $INFRA_DIR"
        log_warn "Clone o repositório: git clone https://github.com/ArchLens-Fiap/archlens-infra-db.git"
        exit 1
    fi

    cd "$INFRA_DIR"
    docker compose up -d
    log "Infraestrutura iniciada"
}

# ============================================================
# AGUARDAR SERVIÇOS
# ============================================================
wait_for_service() {
    local name=$1
    local url=$2
    local max_attempts=$3
    local attempt=0

    log_info "Aguardando $name em $url..."
    while [ $attempt -lt $max_attempts ]; do
        if curl -sf "$url" &>/dev/null; then
            log "$name pronto"
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 3
    done

    log_warn "$name não respondeu após $((max_attempts * 3))s"
    return 1
}

# ============================================================
# MOSTRAR STATUS
# ============================================================
show_status() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  🌐 URLs da Infraestrutura${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "  PostgreSQL:        localhost:5432"
    echo -e "  MongoDB:           localhost:27017"
    echo -e "  Redis:             localhost:6379"
    echo -e "  RabbitMQ:          localhost:5672"
    echo -e "  RabbitMQ Manager:  http://localhost:15672 (archlens / archlens_dev_2026)"
    echo -e "  MinIO Console:     http://localhost:9001  (archlens / archlens_dev_2026)"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  🔧 Iniciar serviços .NET (em terminais separados)${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "  Auth Service:"
    echo -e "    cd archlens-auth-service && dotnet run --project src/ArchLens.Auth.Api"
    echo -e "  Upload Service:"
    echo -e "    cd archlens-upload-service && dotnet run --project src/ArchLens.Upload.Api"
    echo -e "  Orchestrator Service:"
    echo -e "    cd archlens-orchestrator-service && dotnet run --project src/ArchLens.Orchestrator.Api"
    echo -e "  Report Service:"
    echo -e "    cd archlens-report-service && dotnet run --project src/ArchLens.Report.Api"
    echo -e "  Notification Service:"
    echo -e "    cd archlens-notification-service && dotnet run --project src/ArchLens.Notification.Api"
    echo -e "  Gateway:"
    echo -e "    cd archlens-gateway && dotnet run --project src/ArchLens.Gateway"
    echo -e "  Frontend:"
    echo -e "    cd archlens-frontend && npm run dev"
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  📖 Seed de dados de demo${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "  Após iniciar os serviços, execute:"
    echo -e "    ./scripts/seed-demo-data.sh"
    echo ""
}

# ============================================================
# MAIN
# ============================================================
print_header
check_deps
start_infra

echo ""
log_info "Aguardando PostgreSQL ficar pronto..."
sleep 5

if [ "$1" = "--seed" ]; then
    log_info "Modo --seed: aguardando Auth Service na porta 5120..."
    wait_for_service "Auth Service" "http://localhost:5120/health" 40
    "$SCRIPT_DIR/seed-demo-data.sh"
fi

show_status
