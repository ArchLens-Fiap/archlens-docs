# ADR-005: Event-driven com RabbitMQ + Outbox Pattern

**Status**: aceita
**Data**: 2026-03-10
**Fase**: 2

## Contexto

Os microsservicos precisam se comunicar de forma assincrona (requisito do enunciado: "ao menos um fluxo assincrono"). Precisamos garantir:
1. Mensagens nao se percam (reliability)
2. Ordem de processamento (eventual consistency)
3. Nao publicar evento se o banco falhar (atomicidade)

## Decisao

**RabbitMQ** como message broker via **MassTransit** com **Outbox Pattern** para garantia de entrega.

### Outbox Pattern

```
1. Transacao DB: salva entidade + OutboxMessage na mesma transacao
2. Background service (OutboxProcessor): poll a cada 5s
3. Publica mensagens pendentes via MassTransit
4. Marca como processadas
```

Isso garante que o evento so e publicado se o dado foi persistido com sucesso (atomicidade).

### MassTransit

- Abstrai RabbitMQ (exchange + queue management automatico)
- Kebab-case endpoint naming (ex: `diagram-uploaded-event`)
- Message retry com intervals configurados (1s, 5s, 15s)

## Alternativas consideradas

| Alternativa | Motivo da rejeicao |
|------------|-------------------|
| Kafka | Overkill para o volume, complexidade operacional maior |
| Azure Service Bus | Vendor lock-in, nao roda local sem emulador |
| Publicacao direta (sem Outbox) | Risco de evento publicado sem dado persistido |
| CDC (Change Data Capture) | Complexidade desnecessaria para o escopo |

## Consequencias

**Positivas**:
- Garantia de entrega (at-least-once)
- Atomicidade DB + evento
- MassTransit simplifica consumer/publisher
- RabbitMQ roda facilmente local (Docker)

**Negativas**:
- Outbox adiciona latencia (poll interval de 5s)
- Possibilidade de mensagem duplicada (idempotencia nos consumers)
- Dependencia do MassTransit (mesmo broker para todos os servicos)
