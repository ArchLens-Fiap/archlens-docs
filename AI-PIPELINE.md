# Pipeline de Inteligencia Artificial — ArchLens

---

## 1. Visao Geral

O ArchLens utiliza um **Motor de Consenso Multi-Provider** que submete o mesmo diagrama de arquitetura a multiplos modelos de IA simultaneamente e consolida as respostas via fuzzy matching para gerar um relatorio unico e confiavel.

```
Upload (PNG/PDF)
    |
    v
[Preprocess] ── convert PDF to images, resize, compute hash
    |
    v
[Multi-Provider Analysis] ── GPT-4o + GPT-4o Mini + Gemini 2.0 Flash (paralelo)
    |
    v
[Guardrails] ── validate_provider_response() + _scores_in_range()
    |
    v
[Consensus Engine] ── fuzzy matching (Levenshtein) + weighted scoring
    |
    v
[Report Generation] ── persistido no MongoDB via evento GenerateReportCommand
    |
    v
[Notification] ── usuario notificado em real-time via SignalR
```

---

## 2. Justificativa da Abordagem

### Por que Multi-Provider ao inves de Single-Provider?

| Aspecto | Single Provider | Multi-Provider (ArchLens) |
|---------|----------------|--------------------------|
| Alucinacoes | Alto risco — sem validacao cruzada | Mitigado — componentes nao confirmados sao descartados |
| Vies do modelo | Cada LLM tem vieses proprios | Vieses se cancelam na media ponderada |
| Disponibilidade | SPOF — se o provider cair, sistema para | Graceful degradation — funciona com 1 de 3 |
| Confianca | Binaria (funciona ou nao) | Gradual (50% a 100% baseado em concordancia) |
| Custo | Menor | Maior, mas aceitavel com tiers gratuitos |

### Por que Vision API ao inves de OCR + NLP?

- Diagramas de arquitetura sao **visuais** — posicao, cores, setas e agrupamentos carregam significado
- OCR perde contexto espacial (ex.: "Service A conecta a Database B" vs "Service A esta ao lado de Database B")
- LLMs com Vision (GPT-4o, Gemini) foram treinados para interpretar diagramas diretamente
- Elimina etapa intermediaria de OCR que introduziria erros

### Por que Levenshtein para Consenso?

- Cada provider usa nomenclatura diferente (ex.: "API Gateway" vs "Gateway API" vs "API GW")
- Comparacao exata (`==`) falharia em ~40% dos matches
- Levenshtein ratio > 0.65 captura sinonimos e variacoes de nomenclatura
- Normalizacao previa remove sufixos comuns ("Service", "Svc", "Server", "DB")

---

## 3. Componentes do Pipeline

### 3.1 Pre-processamento (`domain/preprocessing.py`)

| Etapa | Descricao |
|-------|-----------|
| `compute_file_hash()` | SHA-256 para deduplicacao — diagramas identicos nao sao reprocessados |
| `convert_pdf_to_images()` | Converte PDF em imagens PNG via poppler (uma imagem por pagina) |
| `preprocess_image()` | Redimensiona imagens grandes para otimizar tempo de inferencia |

### 3.2 Providers (`adapters/*_provider.py`)

Cada provider implementa a interface `AIProviderPort`:

| Provider | Modelo | Peso | Características |
|----------|--------|------|-----------------|
| `openai-gpt4o` | GPT-4o | 1.0 | Melhor qualidade geral, mais lento |
| `openai-gpt4o-mini` | GPT-4o Mini | 0.8 | Mais rapido, leve trade-off em qualidade |
| `gemini` | Gemini 2.0 Flash | 0.9 | Rapido, bom com diagramas complexos |
| `claude` | Claude 3.5 Sonnet | 1.0 | Opcional, via Anthropic API |

Todos os providers recebem:
- **System prompt**: define o papel do modelo (expert architecture analyst)
- **Analysis prompt**: instrucoes de o que analisar (componentes, riscos, etc.)
- **JSON Schema**: formato rigido de resposta esperado
- **Imagem**: o diagrama em bytes

### 3.3 Guardrails (`domain/guardrails.py`)

```python
# Validacao pos-resposta
def validate_provider_response(response) -> bool:
    - Rejeita se nao tem componentes
    - Rejeita se nao tem scores
    - Rejeita se scores estao fora do range 0-10

# Cross-reference entre providers
def apply_cross_reference(responses, min_confirmations=2):
    - Filtra respostas invalidas quando ha confirmacoes suficientes
```

### 3.4 Consensus Engine (`domain/consensus.py`)

| Etapa | Funcao | Descricao |
|-------|--------|-----------|
| Merge Components | `_merge_components()` | Agrupa componentes por similaridade (Levenshtein > 0.65), descarta os com < 30% de concordancia |
| Merge Connections | `_merge_connections()` | Remove conexoes duplicadas via fuzzy match em source+target |
| Merge Risks | `_merge_risks()` | Mescla riscos similares, mantem a descricao mais detalhada, ordena por severity |
| Merge Recommendations | `_merge_recommendations()` | Remove recomendacoes duplicadas via similaridade textual |
| Merge Scores | `_merge_scores()` | Media ponderada pelo weight de cada provider |
| Calculate Confidence | `_calculate_confidence()` | Baseada na concordancia entre providers sobre os componentes identificados |

### 3.5 Cache e RAG (`infrastructure/cache.py`, `infrastructure/vector_store.py`)

- Resultados de analise sao cacheados no **Redis** por `analysis_id`
- **Embeddings** sao gerados e indexados no **Redis Vector Store** para busca semantica
- O chat (ArchLens AI) usa **RAG** (Retrieval Augmented Generation) para responder perguntas com contexto do relatorio

---

## 4. Integracao com o Sistema

A IA **nao e um script isolado** — e parte integral do fluxo event-driven:

```
[Upload Service] -- DiagramUploadedEvent --> [RabbitMQ]
                                                |
                                                v
[Orchestrator] -- ProcessingStartedEvent --> [RabbitMQ]
                                                |
                                                v
[AI Processing] -- consume, analisa, publica --> [RabbitMQ]
        |                                          |
        |-- AnalysisCompletedEvent (sucesso)       |
        |-- AnalysisFailedEvent (falha)            |
                                                   v
                                        [Orchestrator] -- decide proximo passo
                                                |
                                        [sucesso] -- GenerateReportCommand --> [Report Service]
                                        [falha + retry < 3] -- reenvia ProcessingStartedEvent
                                        [falha + retry >= 3] -- marca como Failed
```

### Tratamento de falhas

| Falha | Comportamento |
|-------|---------------|
| 1 provider falha, 2 respondem | Gera relatorio com 2 providers (confidence ~80%) |
| 2 providers falham, 1 responde | Gera relatorio com 1 provider (confidence 50%) |
| Todos os 3 falham | Publica `AnalysisFailedEvent`, SAGA faz retry (ate 3x) |
| 3 retries esgotados | SAGA vai para estado `Failed`, usuario notificado |

---

## 5. Limitacoes Conhecidas

### 5.1 Limitacoes do Modelo

| Limitacao | Impacto | Mitigacao |
|-----------|---------|-----------|
| LLMs podem inventar componentes nao visíveis | Relatorio com dados falsos | Consensus Engine descarta componentes sem concordancia |
| Diagramas de baixa resolucao ou muito complexos | Analise incompleta ou imprecisa | Pre-processamento de imagem + nota de confidence baixa |
| Diagramas com texto em idiomas nao-ingleses | Menor acuracia | Prompts em ingles, modelos multi-idioma |
| Diagramas UML vs diagramas informais | Qualidade da analise varia | Funciona melhor com diagramas informais/boxes-and-arrows |

### 5.2 Limitacoes Operacionais

| Limitacao | Impacto | Mitigacao |
|-----------|---------|-----------|
| APIs gratuitas (GitHub Models) tem rate limit ~150 req/dia | Sistema pode parar de funcionar apos limite | Graceful degradation para Gemini (sem rate limit) |
| Latencia alta em PDFs complexos (>45s por provider) | Timeout em diagramas grandes | Timeout de 90s + degradacao para providers que responderam |
| Custo em producao com APIs pagas | Budget pode limitar uso | Caching agressivo (hash dedup) + Gemini como fallback gratuito |
| Dados enviados a APIs externas | Privacidade de diagramas confidenciais | Documentado como risco aceito; em prod, considerar modelos self-hosted |

### 5.3 Limitacoes do Consenso

| Limitacao | Impacto | Mitigacao |
|-----------|---------|-----------|
| Com apenas 1 provider, confidence = 50% | Sem validacao cruzada | Sistema funciona mas sinaliza baixa confianca ao usuario |
| Fuzzy matching pode gerar falsos positivos | Componentes diferentes tratados como iguais | Threshold de 0.65 equilibra precision vs recall |
| Providers com mesmo vies podem concordar em erros | Falsa confianca alta | Uso de providers de fabricantes diferentes (OpenAI + Google) |

---

## 6. Metricas e Avaliacao

### Como avaliamos a qualidade das respostas

1. **Confidence Score**: metrica automatica baseada na concordancia entre providers (0.0 a 1.0)
2. **Component Count**: numero de componentes identificados — muito poucos sugere analise superficial
3. **Risk Severity Distribution**: distribuicao de severidades — resultados balanceados indicam analise honesta
4. **Processing Time**: tempo total — util para monitorar degradacao de providers
5. **Providers Used**: quantos providers responderam — menos de 3 indica timeout ou falha

### Observabilidade da IA

- Logs estruturados (structlog) com `provider`, `analysis_id`, `elapsed_ms`
- Metricas via OpenTelemetry: request duration, provider success rate, consensus confidence
- Dashboard admin com metricas agregadas (endpoint `/admin/metrics`)
