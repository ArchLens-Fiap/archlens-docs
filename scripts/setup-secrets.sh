#!/bin/bash
set -e

# ========================================
# ArchLens - Setup de Secrets para Ambiente Local
# ========================================
# Este script copia as credenciais do arquivo .secrets-academico.env
# para os locais corretos em cada microsservico, permitindo rodar
# a aplicacao localmente sem configuracao manual.
#
# Uso: ./setup-secrets.sh
# ========================================

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
SECRETS_FILE="$ROOT_DIR/archlens-docs/.secrets-academico.env"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  ArchLens - Setup de Secrets${NC}"
echo -e "${CYAN}========================================${NC}"

if [ ! -f "$SECRETS_FILE" ]; then
    echo -e "${RED}Erro: Arquivo de secrets nao encontrado em:${NC}"
    echo -e "  $SECRETS_FILE"
    echo -e "${YELLOW}Certifique-se de que o repositorio archlens-docs esta clonado.${NC}"
    exit 1
fi

# ----------------------------------------
# 1. Copiar .env para archlens-infra-db (Docker Compose)
# ----------------------------------------
echo -e "\n${YELLOW}[1/3] Configurando archlens-infra-db (.env para Docker Compose)...${NC}"

INFRA_DIR="$ROOT_DIR/archlens-infra-db"
if [ -d "$INFRA_DIR" ]; then
    cat > "$INFRA_DIR/.env" <<'ENVEOF'
# Gerado automaticamente por setup-secrets.sh
POSTGRES_USER=archlens
POSTGRES_PASSWORD=archlens_dev_2026
POSTGRES_DB=archlens
RABBITMQ_DEFAULT_USER=archlens
RABBITMQ_DEFAULT_PASS=archlens_dev_2026
MINIO_ROOT_USER=archlens
MINIO_ROOT_PASSWORD=archlens_dev_2026
MONGO_INITDB_ROOT_USERNAME=archlens
MONGO_INITDB_ROOT_PASSWORD=archlens_dev_2026
REDIS_PASSWORD=archlens_dev_2026
ENVEOF
    echo -e "  ${GREEN}OK${NC} $INFRA_DIR/.env"
else
    echo -e "  ${RED}SKIP${NC} archlens-infra-db nao encontrado"
fi

# ----------------------------------------
# 2. Copiar .env para archlens-ai-processing (Python)
# ----------------------------------------
echo -e "\n${YELLOW}[2/3] Configurando archlens-ai-processing (.env)...${NC}"

AI_DIR="$ROOT_DIR/archlens-ai-processing"
if [ -d "$AI_DIR" ]; then
    cat > "$AI_DIR/.env" <<'ENVEOF'
# Gerado automaticamente por setup-secrets.sh
ENVIRONMENT=development
DEBUG=true

# RabbitMQ
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
RABBITMQ_USER=archlens
RABBITMQ_PASSWORD=archlens_dev_2026

# MinIO
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=archlens
MINIO_SECRET_KEY=archlens_dev_2026
MINIO_BUCKET=archlens-diagrams

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=archlens_dev_2026

# AI Providers (preencha ao menos 1 para analise funcionar)
# Google Gemini (gratuito): https://aistudio.google.com
GOOGLE_AI_API_KEY=

# GitHub Models (GPT-4o + Claude via GitHub Pro - gratuito)
# Token: https://github.com/settings/tokens (nenhum scope necessario)
OPENAI_API_KEY=
OPENAI_BASE_URL=https://models.inference.ai.azure.com

# Direto nos providers (pago, opcional)
ANTHROPIC_API_KEY=
ANTHROPIC_BASE_URL=

# OpenTelemetry
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
ENVEOF
    echo -e "  ${GREEN}OK${NC} $AI_DIR/.env"
else
    echo -e "  ${RED}SKIP${NC} archlens-ai-processing nao encontrado"
fi

# ----------------------------------------
# 3. Copiar .env.local para archlens-frontend (Next.js)
# ----------------------------------------
echo -e "\n${YELLOW}[3/3] Configurando archlens-frontend (.env.local)...${NC}"

FRONTEND_DIR="$ROOT_DIR/archlens-frontend"
if [ -d "$FRONTEND_DIR" ]; then
    cat > "$FRONTEND_DIR/.env.local" <<'ENVEOF'
# Gerado automaticamente por setup-secrets.sh
NEXT_PUBLIC_API_URL=http://localhost:5000
NEXT_PUBLIC_NOTIFICATION_HUB_URL=http://localhost:5150/hubs/analysis
ENVEOF
    echo -e "  ${GREEN}OK${NC} $FRONTEND_DIR/.env.local"
else
    echo -e "  ${RED}SKIP${NC} archlens-frontend nao encontrado"
fi

# ----------------------------------------
# Resumo
# ----------------------------------------
echo -e "\n${CYAN}========================================${NC}"
echo -e "${GREEN}  Setup concluido!${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e ""
echo -e "Proximos passos:"
echo -e "  ${CYAN}1.${NC} Suba a infra:  ${YELLOW}cd archlens-infra-db && docker compose up -d${NC}"
echo -e "  ${CYAN}2.${NC} Inicie tudo:   ${YELLOW}cd archlens-docs && ./scripts/start.sh${NC}"
echo -e ""
echo -e "  Ou use o modo Docker completo:"
echo -e "  ${YELLOW}cd archlens-docs && ./scripts/start.sh docker${NC}"
echo -e ""
echo -e "${YELLOW}NOTA:${NC} Para analise de diagramas funcionar, preencha ao menos"
echo -e "1 chave de IA no arquivo ${CYAN}archlens-ai-processing/.env${NC}"
echo -e "Veja instrucoes em ${CYAN}archlens-docs/.secrets-academico.env${NC} (secao AI PROVIDERS)"
echo -e ""
echo -e "Logins de teste:"
echo -e "  Admin: ${YELLOW}admin${NC} / ${YELLOW}Admin@123${NC}"
echo -e "  User:  ${YELLOW}user${NC} / ${YELLOW}User@123${NC}"
