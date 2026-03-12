#!/bin/bash

# ============================================================
# 🌱 ArchLens - Script de Seed de Dados de Demonstração
# ============================================================
# Cria usuários de demo via API para facilitar a avaliação
#
# Uso: ./scripts/seed-demo-data.sh [BASE_URL]
# Exemplo:  ./scripts/seed-demo-data.sh http://localhost
# ============================================================

set -e

BASE_URL="${1:-http://localhost}"
AUTH_URL="${BASE_URL}:5120"
GATEWAY_URL="${BASE_URL}:5080"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log()       { echo -e "${GREEN}[$(date +'%H:%M:%S')] ✓ $1${NC}"; }
log_info()  { echo -e "${BLUE}[$(date +'%H:%M:%S')] ℹ $1${NC}"; }
log_warn()  { echo -e "${YELLOW}[$(date +'%H:%M:%S')] ⚠ $1${NC}"; }
log_err()   { echo -e "${RED}[$(date +'%H:%M:%S')] ✗ $1${NC}"; }
log_skip()  { echo -e "${YELLOW}[$(date +'%H:%M:%S')] ↷ $1 (já existe)${NC}"; }

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         🌱 ArchLens - Seed de Dados de Demo                  ║${NC}"
echo -e "${CYAN}║              FIAP 12SOAT - Tech Challenge Fase 5             ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

log_info "Configuração:"
echo "  • Auth Service: $AUTH_URL"
echo "  • Gateway:      $GATEWAY_URL"
echo ""

# ============================================================
# AGUARDAR AUTH SERVICE
# ============================================================
log_info "Verificando Auth Service..."
max_wait=60
attempt=0
while [ $attempt -lt $max_wait ]; do
    if curl -sf "${AUTH_URL}/health" &>/dev/null; then
        log "Auth Service online"
        break
    fi
    attempt=$((attempt + 1))
    if [ $attempt -eq $max_wait ]; then
        log_err "Auth Service não está respondendo após ${max_wait}s."
        log_err "Certifique-se de que os serviços estão rodando e tente novamente."
        exit 1
    fi
    sleep 1
done

# ============================================================
# FUNÇÃO PARA REGISTRAR USUÁRIO
# ============================================================
register_user() {
    local username=$1
    local email=$2
    local password=$3
    local role_label=$4

    local response
    response=$(curl -s -o /dev/null -w "%{http_code}" \
        -X POST "${AUTH_URL}/auth/register" \
        -H "Content-Type: application/json" \
        -d "{
              \"username\": \"${username}\",
              \"email\": \"${email}\",
              \"password\": \"${password}\",
              \"lgpdConsent\": true
            }" 2>/dev/null || echo "000")

    case $response in
        200|201) log "Usuário $role_label criado: $email / $password" ;;
        409)     log_skip "Usuário $role_label ($email)" ;;
        *)       log_warn "Usuário $role_label ($email) - HTTP $response" ;;
    esac
}

# ============================================================
# CRIAR USUÁRIOS DE DEMO
# ============================================================
echo ""
log_info "Criando usuários de demonstração..."

register_user "admin"     "admin@archlens.com"      "Admin@2026!"     "Admin"
register_user "professor" "professor@archlens.com"  "Professor@2026!" "Professor (Avaliador)"
register_user "demo"      "demo@archlens.com"        "Demo@2026!"      "Demo"

# ============================================================
# RESUMO
# ============================================================
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  ✅ Seed concluído - Credenciais de Acesso${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BLUE}Usuário Admin:${NC}"
echo -e "    Email:  admin@archlens.com"
echo -e "    Senha:  Admin@2026!"
echo ""
echo -e "  ${BLUE}Usuário Professor (Avaliador):${NC}"
echo -e "    Email:  professor@archlens.com"
echo -e "    Senha:  Professor@2026!"
echo ""
echo -e "  ${BLUE}Usuário Demo:${NC}"
echo -e "    Email:  demo@archlens.com"
echo -e "    Senha:  Demo@2026!"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  🌐 URLs de Acesso${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  Frontend:  http://localhost:3000"
echo -e "  Gateway:   $GATEWAY_URL"
echo -e "  Auth API:  ${AUTH_URL}/swagger"
echo ""
