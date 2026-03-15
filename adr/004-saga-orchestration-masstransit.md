# ADR-004: SAGA Orquestrada com MassTransit

**Status**: aceita
**Fase**: 4

## Contexto

O fluxo principal do sistema envolve multiplos servicos em sequencia:

```
Upload → AI Processing → Report Generation → Notification
```

Cada passo pode falhar. Precisamos de uma estrategia para coordenar o fluxo, tratar falhas e manter o estado consistente.

## Decisao

**SAGA Orquestrada** usando MassTransit StateMachine com persistencia em PostgreSQL (EF Core) e optimistic concurrency.

### Fluxo da SAGA

```
DiagramUploadedEvent
  → Saga cria instancia (Processing)
  → Publica ProcessingStartedEvent
  
AnalysisCompletedEvent
  → Saga armazena resultado (Analyzed)
  → Publica GenerateReportCommand
  
AnalysisFailedEvent
  → Se retry < 3: re-publica ProcessingStartedEvent
  → Se retry >= 3: marca como Failed

ReportGeneratedEvent
  → Saga armazena reportId (Completed)
  → Finalize

ReportFailedEvent
  → Saga marca como Failed
```

### Retry

- Ate 3 tentativas automaticas para falha de AI Processing
- Re-publica `ProcessingStartedEvent` com mesmo `AnalysisId`

### Notificacao

- Cada transicao de estado publica `StatusChangedEvent`
- Notification Service consome e faz push via SignalR

## Alternativas consideradas

| Alternativa | Motivo da rejeicao |
|------------|-------------------|
| Coreografia pura (cada servico reage a eventos) | Dificil rastrear estado do fluxo, sem retry centralizado, debug complexo |
| SAGA coreografada | Mesmos problemas + sem compensacao centralizada |
| Process Manager manual | Reinventando a roda, MassTransit ja resolve |
| Temporal.io | Overhead de infra adicional, curva de aprendizado |

## Consequencias

**Positivas**:
- Estado do fluxo 100% rastreavel (query na tabela saga_states)
- Retry automatico com logica centralizada
- Pattern avancado reconhecido por avaliadores
- MassTransit TestHarness permite testar state machine sem infraestrutura

**Negativas**:
- Dependencia forte do MassTransit (acoplamento ao framework)
- Complexidade adicional vs coreografia simples
- PostgreSQL como saga store (vs Redis) adiciona latencia marginal

**Metricas de validacao**:
- Fluxo completo (upload → report) em < 90s
- Retry funciona: 1 falha + 1 sucesso = Completed
- 3 falhas consecutivas = Failed (nao fica preso)
