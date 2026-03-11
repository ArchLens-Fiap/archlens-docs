# ADR-003: Multi-provider AI com Consensus Engine

**Status**: aceita
**Data**: 2026-03-10
**Fase**: 3

## Contexto

O sistema precisa analisar diagramas de arquitetura usando IA. Depender de um unico provider e arriscado:
- Pode alucinar sem contrapartida
- Downtime de um provider para o sistema inteiro
- Sem forma de medir confianca da resposta

## Decisao

Usar **3 providers de IA em paralelo** (OpenAI GPT-4o Vision, Google Gemini 2.0 Flash, Anthropic Claude Sonnet 4) com um **Consensus Engine** que faz merge dos resultados.

### Pipeline

```
Diagrama → Preprocessing → [OpenAI | Gemini | Claude] → Consensus Engine → Guardrails → Resultado
```

### Consensus Engine

- **Componentes**: merge via fuzzy matching (Levenshtein distance, threshold 80%) + contagem de votos
- **Riscos/Recomendacoes**: deduplicacao semantica via similaridade fuzzy
- **Scores**: media ponderada por peso do provider (configuravel)
- **Confidence**: calculada por nivel de concordancia entre providers (3/3 = alta, 2/3 = media, 1/3 = baixa)

### Guardrails

- Validacao de schema da resposta (componentes, scores entre 0-10)
- Cross-reference: filtra respostas que divergem demais do consenso
- Fallback: graceful degradation (3 → 2 → 1 → 0 providers)

## Alternativas consideradas

| Alternativa | Motivo da rejeicao |
|------------|-------------------|
| Provider unico (GPT-4o) | SPOF, sem medida de confianca, sem fallback |
| Ensemble simples (melhor score) | Perde informacao dos outros providers |
| Fine-tuning de modelo proprio | Tempo insuficiente, custo alto, dados de treino limitados |

## Consequencias

**Positivas**:
- Resiliencia: sistema funciona com 1/3 providers ativos
- Confianca mensuravel: score de consenso por componente
- Reducao de alucinacoes: cross-reference entre providers
- Diferencial competitivo: nenhum outro time tera isso

**Negativas**:
- Custo 3x maior por analise (mitigado por cache Redis com hash dedup)
- Latencia: espera o mais lento dos 3 (mitigado por timeout de 60s e chamadas paralelas)
- Complexidade do Consensus Engine

**Metricas de validacao**:
- Confidence > 70% em media para diagramas padrao (microservices, monolito)
- Tempo total < 60s com 3 providers
- Sistema funcional com apenas 1 provider ativo
