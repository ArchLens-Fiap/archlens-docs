# ADR-011: MongoDB como banco do Report Service

**Status**: aceita
**Fase**: 5

## Contexto

O Report Service armazena relatorios de analise de arquitetura. Cada relatorio contem estruturas profundamente aninhadas e variavel: componentes identificados, conexoes, riscos, scores, metadata de providers. Os dados sao write-once (gerados pela IA) e consultados como documentos completos.

## Decisao

Usar **MongoDB** como banco de dados do Report Service, em vez de PostgreSQL com JSONB.

### Justificativa tecnica

Os relatorios sao **documentos semi-estruturados** com:
- Listas de componentes (tamanho variavel, 5-50 por diagrama)
- Listas de conexoes (tamanho variavel, 10-100 por diagrama)
- Listas de riscos (tamanho variavel)
- Scores aninhados (6 categorias)
- Metadata de providers (variavel por provider)

Esse formato mapeia naturalmente para documentos MongoDB, evitando JOINs e normalizacao forcada.

### Modelo de dados

```json
{
  "_id": "ObjectId",
  "analysisId": "GUID",
  "diagramId": "GUID",
  "userId": "GUID",
  "summary": "string",
  "diagramType": "string",
  "components": [{ "name": "", "type": "", "description": "", "providers": [] }],
  "connections": [{ "from": "", "to": "", "protocol": "", "description": "" }],
  "risks": [{ "title": "", "severity": "", "description": "", "recommendation": "" }],
  "scores": { "overall": 7.5, "modularity": 8.0, ... },
  "confidence": 0.85,
  "providersUsed": ["openai-gpt4o", "gemini-2.0-flash"],
  "createdAt": "ISODate"
}
```

### Polyglot Persistence

| Servico | Banco | Motivo |
|---------|-------|--------|
| Auth | PostgreSQL | Dados relacionais (users, roles) |
| Upload | PostgreSQL | Dados relacionais (diagrams, analysis processes) + Outbox |
| Orchestrator | PostgreSQL | Saga state machine (MassTransit requer relacional) |
| Report | **MongoDB** | Documentos semi-estruturados (relatorios) |
| Notification | Redis | Stateless, apenas backplane SignalR |
| AI Processing | Redis | Cache de resultados (TTL) |

## Alternativas consideradas

| Alternativa | Motivo da rejeicao |
|------------|-------------------|
| PostgreSQL + JSONB | Funciona, mas queries em JSONB sao menos ergonomicas; schema forcado via migrations; sem indice nativo em arrays aninhados |
| DynamoDB | Vendor lock-in (AWS), complexidade de partitioning |

## Consequencias

**Positivas**:
- Schema flexivel para documentos variados
- Queries naturais em arrays aninhados
- Demonstra polyglot persistence (diferencial tecnico)
- MongoDB Atlas free tier para producao academica

**Negativas**:
- Mais um banco para gerenciar (mitigado por Docker Compose)
- Sem transacoes cross-collection (desnecessario - relatorios sao write-once)
- Equipe precisa conhecer MongoDB Driver .NET
