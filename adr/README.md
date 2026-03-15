# Architecture Decision Records (ADRs)

Registro de decisoes arquiteturais do projeto ArchLens.

## Formato

Cada ADR segue a estrutura: **Contexto → Decisao → Consequencias**.

Status possiveis: `aceita` | `substituida` | `depreciada`

## Indice

| ADR | Titulo | Status |
|-----|--------|--------|
| [001](001-monorepo-clean-architecture.md) | Polyrepo com Clean Architecture por servico | aceita |
| [002](002-polyglot-dotnet-python.md) | Arquitetura Polyglot (.NET 9 + Python) | aceita |
| [003](003-multi-provider-ai-consensus.md) | Multi-provider AI com Consensus Engine | aceita |
| [004](004-saga-orchestration-masstransit.md) | SAGA Orquestrada com MassTransit | aceita |
| [005](005-event-driven-rabbitmq-outbox.md) | Event-driven com RabbitMQ + Outbox Pattern | aceita |
| [006](006-observability-stack.md) | Stack de Observabilidade (OTel + Prometheus + Grafana + Jaeger + Loki) | aceita |
| [007](007-signalr-realtime-redis.md) | SignalR para real-time com Redis backplane | aceita |
| [008](008-kind-cluster-local.md) | KIND como cluster Kubernetes local | aceita |
| [009](009-kustomize-manifests.md) | Kustomize para gerenciamento de manifestos Kubernetes | aceita |
| [010](010-lgpd-compliance-strategy.md) | Estrategia de Conformidade LGPD | aceita |
| [011](011-mongodb-report-service.md) | MongoDB como banco do Report Service | aceita |
| [012](012-nextjs-shadcn-frontend.md) | Next.js 16 + shadcn/ui + React Query para Frontend | aceita |
| [013](013-testing-strategy.md) | Estrategia de Testes (Unit + Integration + Architecture) | aceita |
| [014](014-cicd-github-actions.md) | CI/CD com GitHub Actions e Path-based Triggers | aceita |

## Processo de revisao

> **Regra**: a cada nova fase do projeto, revisar os ADRs existentes e criar novos para decisoes relevantes.
> Se uma decisao anterior for invalidada, marcar como `substituida` e criar novo ADR referenciando o anterior.
