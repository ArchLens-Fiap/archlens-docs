# ADR-006: Stack de Observabilidade (OTel + Prometheus + Grafana + Jaeger + Loki)

**Status**: aceita
**Fase**: 1

## Contexto

O enunciado exige logs estruturados e tratamento de erros. Para demonstrar maturidade tecnica e impressionar a banca, precisamos de observabilidade completa: metricas, traces distribuidos e logs centralizados.

## Decisao

Stack completa baseada em **OpenTelemetry** como coletor universal:

| Pilar | Ferramenta | Funcao |
|-------|-----------|--------|
| Metricas | Prometheus + Grafana | Coleta e visualizacao de metricas (requests/s, latencia, erros) |
| Traces | Jaeger | Distributed tracing (.NET → RabbitMQ → Python → RabbitMQ → .NET) |
| Logs | Loki + Grafana | Logs centralizados com correlacao por X-Correlation-Id |
| Coleta | OpenTelemetry Collector | Recebe OTLP de todos os servicos e roteia para backends |

### Instrumentacao

- **.NET**: Serilog (structured logging) + OpenTelemetry SDK (ASP.NET, HTTP, SQL)
- **Python**: structlog (JSON) + OpenTelemetry SDK (FastAPI, HTTP)
- **Correlacao**: `X-Correlation-Id` header propagado em todos os requests e mensagens

## Alternativas consideradas

| Alternativa | Motivo da rejeicao |
|------------|-------------------|
| ELK Stack (Elasticsearch + Logstash + Kibana) | Pesado para rodar local, consome muita RAM |
| Datadog/New Relic | SaaS pago, nao demonstra competencia de infra |
| Apenas console logs | Nao impressiona a banca, impossivel correlacionar entre servicos |

## Consequencias

**Positivas**:
- Visibilidade completa do sistema (WOW moment no video com Grafana)
- Debug facilitado: trace unico do upload ao relatorio
- Demonstra maturidade operacional

**Negativas**:
- 5 containers extras de observabilidade (RAM adicional)
- Configuracao inicial do OTel Collector requer cuidado
- Grafana dashboards precisam ser criados manualmente (provisionamento na Fase 7)
