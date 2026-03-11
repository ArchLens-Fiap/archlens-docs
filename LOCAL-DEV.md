# ArchLens - Desenvolvimento Local

## Comandos

```bash
# Subir tudo (infra + servicos)
docker compose up --build

# Subir tudo + observabilidade (Grafana, Jaeger, Prometheus, Loki)
docker compose --profile obs up --build

# Subir so infra (para dev local com dotnet run)
docker compose up postgres rabbitmq minio minio-init redis mongodb

# Parar tudo
docker compose down

# Parar tudo e limpar volumes (reset completo)
docker compose down -v
```

## Enderecos dos Servicos

| Servico | URL | Notas |
|---------|-----|-------|
| Gateway (ponto de entrada) | http://localhost:5080 | YARP reverse proxy + JWT |
| Auth API | http://localhost:5120 | Swagger: /swagger |
| Upload API | http://localhost:5066 | Swagger: /swagger |
| Orchestrator API | http://localhost:5089 | Swagger: /swagger |
| Notification API | http://localhost:5150 | SignalR Hub: /hubs/analysis |
| Report API | http://localhost:5205 | Swagger: /swagger |
| AI Processing | http://localhost:8000 | FastAPI docs: /docs |
| Frontend | http://localhost:3000 | Next.js (quando implementado) |

## UIs de Infraestrutura

| Servico | URL | Credenciais |
|---------|-----|-------------|
| RabbitMQ Management | http://localhost:15672 | archlens / archlens_dev_2026 |
| MinIO Console | http://localhost:9001 | archlens / archlens_dev_2026 |
| Grafana | http://localhost:3001 | admin / admin |
| Jaeger UI | http://localhost:16686 | - |
| Prometheus | http://localhost:9090 | - |

## Health Checks

| Servico | Endpoint |
|---------|----------|
| Upload API | http://localhost:5066/health |
| Orchestrator API | http://localhost:5089/health |
| Notification API | http://localhost:5150/health |
| AI Processing | http://localhost:8000/health |
| Gateway | http://localhost:5080/health |

## Portas Internas (dentro do Docker network)

| Servico | Hostname:Porta |
|---------|---------------|
| PostgreSQL | postgres:5432 |
| RabbitMQ | rabbitmq:5672 |
| MinIO | minio:9000 |
| MongoDB | mongodb:27017 |
| Redis | redis:6379 |

## Bancos de Dados

| Banco | Database | Servico |
|-------|----------|---------|
| PostgreSQL | archlens_upload | Upload Service |
| PostgreSQL | archlens_orchestrator | Orchestrator Service |
| MongoDB | archlens_reports | Report Service (Fase 5) |
| Redis | - | Cache + SignalR backplane |

## Variaveis de Ambiente (AI providers)

Criar arquivo `.env` na raiz de `archlens/` com:

```env
OPENAI_API_KEY=sk-...
GOOGLE_API_KEY=AI...
ANTHROPIC_API_KEY=sk-ant-...
```
