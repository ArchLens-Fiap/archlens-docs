# ADR-002: Arquitetura Polyglot (.NET 9 + Python)

**Status**: aceita
**Data**: 2026-03-10
**Fase**: 1

## Contexto

O sistema possui dois tipos de workload distintos:
1. **Servicos de dominio** (Upload, Orchestrator, Report, Notification): CRUD, CQRS, event handling, real-time
2. **AI Processing**: chamadas a APIs de IA (OpenAI, Gemini, Claude), processamento de imagens, NLP

Precisamos decidir se usamos uma unica linguagem ou combinamos linguagens especializadas.

## Decisao

**Polyglot**: .NET 9 (C#) para servicos de dominio + gateway, **Python (FastAPI)** para AI Processing.

## Justificativa tecnica

- Python tem o melhor ecossistema de IA/ML: SDKs oficiais (openai, google-generativeai, anthropic), bibliotecas de imagem (Pillow, pdf2image), e ferramentas de NLP
- .NET 9 tem performance superior para servicos I/O-bound, melhor tooling para DDD/CQRS (MediatR, FluentValidation, EF Core), e suporte nativo a SignalR
- A comunicacao entre .NET e Python e 100% via mensageria (RabbitMQ), eliminando acoplamento direto

## Alternativas consideradas

| Alternativa | Motivo da rejeicao |
|------------|-------------------|
| 100% .NET | SDKs de IA em C# sao imaturos (Semantic Kernel nao suporta Gemini/Claude nativamente) |
| 100% Python | Nao atende os requisitos de SOAT (Clean Arch, DDD, CQRS sao mais naturais em .NET) |
| Node.js para AI | Ecossistema de IA inferior ao Python, SDKs menos maduros |

## Consequencias

**Positivas**:
- Cada linguagem usada no seu ponto forte
- Demonstra competencia polyglot (diferencial para banca)
- Comunicacao desacoplada via eventos

**Negativas**:
- Dois runtimes para manter (Docker resolve)
- Equipe precisa dominar ambas linguagens

**Metricas de validacao**:
- AI Processing responde em < 60s para analise completa
- Todos os servicos .NET compilam em < 10s
