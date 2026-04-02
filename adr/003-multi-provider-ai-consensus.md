# ADR-003: Multi-provider AI com Consensus Engine

**Status**: aceita
**Fase**: 3

## Contexto

O sistema precisa analisar diagramas de arquitetura usando IA. Depender de um unico provider e arriscado:
- Pode alucinar sem contrapartida
- Downtime de um provider para o sistema inteiro
- Sem forma de medir confianca da resposta

## Decisao

Usar **3 providers de IA em paralelo** (OpenAI GPT-4o, OpenAI GPT-4o Mini via GitHub Models, Google Gemini 2.0 Flash) com um **Consensus Engine** que faz merge dos resultados. A arquitetura suporta N providers — novos podem ser adicionados apenas registrando no `ProviderRegistry`.

### Pipeline

```
Diagrama → Preprocessing → [OpenAI GPT-4o | GPT-4o Mini | Gemini 2.0 Flash] → Consensus Engine → Guardrails → Resultado
```

### Consensus Engine

- **Componentes**: merge via fuzzy matching (Levenshtein distance, threshold 65%) + contagem de votos
- **Riscos/Recomendacoes**: deduplicacao semantica via similaridade fuzzy
- **Scores**: media ponderada por peso do provider (configuravel)
- **Confidence**: calculada por nivel de concordancia entre providers (N/N = alta, parcial = media, 1/N = baixa)

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
- Resiliencia: sistema funciona com 1/N providers ativos
- Confianca mensuravel: score de consenso por componente
- Reducao de alucinacoes: cross-reference entre providers
- Diferencial competitivo: nenhum outro time tera isso

**Negativas**:
- Custo Nx maior por analise (mitigado por cache Redis com hash dedup)
- Latencia: espera o mais lento dos N (mitigado por timeout de 60s e chamadas paralelas)
- Complexidade do Consensus Engine

**Metricas de validacao**:
- Confidence > 70% em media para diagramas padrao (microservices, monolito)
- Tempo total < 60s com N providers em paralelo
- Sistema funcional com apenas 1 provider ativo
- Providers atuais: OpenAI GPT-4o (weight 1.0), OpenAI GPT-4o Mini (weight 0.8) via GitHub Models, e Google Gemini 2.0 Flash (weight 1.0) via Google AI Studio — todos gratuitos
