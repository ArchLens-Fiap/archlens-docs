# Architecture Decision Records (ADRs)

Registro de decisoes arquiteturais do projeto ArchLens.

## Formato

Cada ADR segue a estrutura: **Contexto → Decisao → Consequencias**.

Status possiveis: `aceita` | `substituida` | `depreciada`

## Indice

| ADR | Titulo | Status | Data |
|-----|--------|--------|------|
| [001](001-monorepo-clean-architecture.md) | Monorepo com Clean Architecture por servico | aceita | 2026-03-10 |
| [002](002-polyglot-dotnet-python.md) | Arquitetura Polyglot (.NET 9 + Python) | aceita | 2026-03-10 |
| [003](003-multi-provider-ai-consensus.md) | Multi-provider AI com Consensus Engine | aceita | 2026-03-10 |
| [004](004-saga-orchestration-masstransit.md) | SAGA Orquestrada com MassTransit | aceita | 2026-03-10 |
| [005](005-event-driven-rabbitmq-outbox.md) | Event-driven com RabbitMQ + Outbox Pattern | aceita | 2026-03-10 |
| [006](006-observability-stack.md) | Stack de Observabilidade (OTel + Prometheus + Grafana + Jaeger + Loki) | aceita | 2026-03-10 |
| [007](007-signalr-realtime-redis.md) | SignalR para real-time com Redis backplane | aceita | 2026-03-10 |
| [008](008-kind-cluster-local.md) | KIND como cluster Kubernetes local | aceita | 2026-03-11 |
| [009](009-kustomize-manifests.md) | Kustomize para gerenciamento de manifestos Kubernetes | aceita | 2026-03-11 |

## Processo de revisao

> **Regra**: a cada nova fase do projeto, revisar os ADRs existentes e criar novos para decisoes relevantes.
> Se uma decisao anterior for invalidada, marcar como `substituida` e criar novo ADR referenciando o anterior.
