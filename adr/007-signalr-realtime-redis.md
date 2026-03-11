# ADR-007: SignalR para real-time com Redis backplane

**Status**: aceita
**Data**: 2026-03-10
**Fase**: 4

## Contexto

O frontend precisa atualizar o status das analises em tempo real (sem polling). Opcoes:
- WebSockets puro
- SignalR (abstrai WebSockets com fallback)
- Server-Sent Events (SSE)
- Polling

## Decisao

**SignalR** no Notification Service com **Redis backplane** para suportar multiplas instancias.

### Arquitetura

```
StatusChangedEvent (RabbitMQ)
  → StatusChangedConsumer (MassTransit)
  → IHubContext<AnalysisHub> (SignalR)
  → Push para clients via WebSocket

Frontend (Next.js)
  → @microsoft/signalr client
  → Conecta em /hubs/analysis
  → JoinAnalysisGroup(analysisId) para receber updates especificos
```

### Groups

- `{analysisId}`: recebe updates de uma analise especifica
- `dashboard`: recebe todos os updates (para pagina de listagem)

### Redis backplane

- Necessario para scaling horizontal (multiplas instancias do Notification Service)
- Channel prefix: `archlens`

## Alternativas consideradas

| Alternativa | Motivo da rejeicao |
|------------|-------------------|
| SSE | Unidirecional, nao suporta groups nativamente |
| WebSocket puro | Sem reconnection automatica, sem groups, sem fallback |
| Polling | Latencia alta, carga desnecessaria no servidor |
| Firebase Realtime | Vendor lock-in, nao roda local |

## Consequencias

**Positivas**:
- Real-time nativo do .NET (zero dependencia externa alem do Redis)
- Reconnection automatica pelo client
- Groups facilitam notificacao direcionada
- @microsoft/signalr tem client JavaScript oficial para Next.js
- Impressiona na demo: status mudando ao vivo

**Negativas**:
- Redis adicional para backplane (ja temos Redis para cache)
- SignalR e .NET-centric (client JS funciona, mas e mantido pela Microsoft)
