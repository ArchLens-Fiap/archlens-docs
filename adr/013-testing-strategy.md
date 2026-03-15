# ADR-013: Estrategia de Testes (Unit + Integration + Architecture)

**Status**: aceita
**Fase**: 7

## Contexto

O projeto precisa de cobertura de testes >= 90% em todos os microsservicos para demonstrar maturidade tecnica. A arquitetura distribui logica entre 7 servicos (5 .NET, 1 Python, 1 Gateway), cada um com camadas distintas (Domain, Application, Infrastructure, API).

## Decisao

Adotar uma estrategia de testes em **3 niveis** com meta de 90%+ de cobertura por servico.

### Piramide de Testes

```
          /  E2E  \        ← Playwright (futuro)
         /  Integ  \       ← WebApplicationFactory, InMemory DB
        /   Unit    \      ← xUnit, pytest (base da piramide)
       / Architecture\     ← ArchUnitNET (layer dependencies)
```

### Nivel 1: Testes Unitarios (base)

| Framework | Servicos | Ferramentas |
|-----------|----------|-------------|
| xUnit 2.9.2 | Auth, Upload, Orchestrator, Report, Notification, Gateway | NSubstitute (mocks), FluentAssertions |
| pytest 8.3.4 | AI Processing | respx (HTTP mocking), pytest-asyncio, pytest-cov |

**Cobertura por camada**:
- Domain: entidades, value objects, validacoes, domain events
- Application: handlers, validators, behaviors (ValidationBehavior, LoggingBehavior)
- API: controllers (via mock MediatR), middlewares, exception handlers, filters
- Infrastructure: consumers, mappers, autenticacao (JWT, BCrypt)
- Contracts: DTOs, records

### Nivel 2: Testes de Integracao

| Tipo | Ferramenta | Uso |
|------|-----------|-----|
| WebApplicationFactory | Microsoft.AspNetCore.Mvc.Testing | Endpoints HTTP com InMemory DB |
| MassTransitTestHarness | MassTransit.Testing | Consumers e sagas |
| InMemory Database | EF Core InMemory | Repositorios sem infra real |

### Nivel 3: Testes de Arquitetura

- **ArchUnitNET**: valida que Domain nao referencia Infrastructure/API
- **Naming conventions**: Controllers terminam em `Controller`, interfaces com `I`
- **Layer dependency**: Application referencia apenas Domain

### Resultados Alcancados (15/03/2026)

| Servico | Testes | Cobertura |
|---------|--------|-----------|
| Upload | 230 | 98.4% |
| Auth | 178 | 91.5% |
| Report | 170 | 92.8% |
| AI Processing | 166 | 92.0% |
| Orchestrator | 103 | 90%+ |
| Notification | 48 | 90%+ |
| Gateway | 28 | 93.3% |
| **Total** | **923** | **90%+ todos** |

## Alternativas consideradas

| Alternativa | Motivo da rejeicao |
|------------|-------------------|
| Testcontainers para tudo | Lento demais para CI, InMemory DB suficiente para unit/integration |
| Apenas testes E2E | Feedback loop lento, dificil debugar falhas, piramide invertida |
| 80% coverage target | Fase4 teve 91%+, precisamos manter ou superar |

## Consequencias

**Positivas**:
- 923 testes = confianca alta em refatoracoes
- 90%+ cobertura demonstra maturidade para a banca
- Testes de arquitetura previnem violacoes de camada
- Cada servico e testavel isoladamente

**Negativas**:
- Tempo de execucao (~10s por servico, ~1min total)
- Manutencao de mocks quando APIs internas mudam
- InMemory DB nao replica 100% do comportamento do PostgreSQL/MongoDB
