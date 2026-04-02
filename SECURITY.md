# Segurança — Riscos, Mitigações e Limitações

---

## 1. Controles Implementados

| Controle | Serviço(s) | OWASP Ref |
|---|---|---|
| Security headers OWASP (X-Frame-Options, CSP, HSTS, etc.) | Todos os 6 serviços | A05 |
| Rate Limiting por IP (60 req/min global; 10 req/min em `/auth`) | Todos os serviços | A04 |
| Validação de entrada via FluentValidation (pipeline MediatR) | auth, upload, orchestrator, report | A03 |
| Validação de magic bytes (upload de arquivos) | upload-service | A04, A08 |
| Sanitização de nome de arquivo (path traversal prevention) | upload-service | A01, A03 |
| JWT Bearer authentication (SignalR + REST) | notification, gateway | A07 |
| JWT secrets via K8s secretKeyRef (não baked na imagem) | Todos | A02 |
| TLS/HTTPS via cert-manager + nginx Ingress | K8s (archlens-infra-k8s) | A02, A05 |
| K8s SecurityContext: `runAsNonRoot`, `readOnlyRootFilesystem`, drop ALL caps | Todos os deployments | A05 |
| Trivy scan em todas as imagens Docker (CI) | CI/CD (archlens-docs) | A06 |
| Sem secrets hardcoded nas imagens — apenas env vars ou K8s secrets | Todos | A02 |

---

## 2. Riscos Residuais e Limitações

### 2.1 Gestão de Secrets

| Risco | Severidade | Status |
|---|---|---|
| `secrets.yaml` versionado no git com valores de desenvolvimento | Médio | ⚠️ Documentado |
| JWT token não é revogável antes da expiração (sem blacklist) | Médio | ⚠️ Limitação aceita |
| Sem rotação automática de secrets em produção | Alto | ⚠️ Mitigação pendente |

**Mitigação recomendada** para produção:
- Usar [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) ou [External Secrets Operator](https://external-secrets.io/) em vez de `secrets.yaml` diretamente
- Implementar refresh token com rotação para revogar JWTs comprometidos

### 2.2 Validação e Upload

| Risco | Severidade | Status |
|---|---|---|
| Arquivos polyglot (ex.: PDF com payload JS) podem passar pelas verificações | Baixo | ⚠️ Limitação aceita |
| SVG com tags `<script>` pode ser servido como `image/svg+xml` | Médio | ⚠️ SVG não está na allowlist |
| Sem antivírus/YARA scan no upload | Baixo | ⚠️ Fora do escopo |

**Nota**: A allowlist de extensões (`.png`, `.jpg`, `.jpeg`, `.webp`, `.pdf`) e a validação de magic bytes cobrem os principais vetores. SVG foi intencionalmente excluído.

### 2.3 Infraestrutura e Rede

| Risco | Severidade | Status |
|---|---|---|
| Sem Network Policy entre pods (todos os pods se comunicam livremente) | Alto | ⚠️ Recomendado para prod |
| Sem WAF (Web Application Firewall) | Médio | ⚠️ Fora do escopo atual |
| TLS self-signed em cluster KIND local (`archlens.local`) | Baixo | ✅ Let's Encrypt em produção |
| `exit-code: 0` no Trivy (não bloqueia build em CVEs CRITICAL) | Médio | ⚠️ Configurável |

### 2.4 Rate Limiting

| Risco | Severidade | Status |
|---|---|---|
| Rate limiting baseado em IP — pode ser contornado com IP rotation | Médio | ⚠️ Limitação aceita |
| Sem rate limiting por usuário autenticado | Baixo | ⚠️ Melhoria futura |

---

## 3. Recomendações para Produção

1. **Sealed Secrets**: substituir `secrets.yaml` por manifests criptografados via `kubeseal`
2. **Network Policies**: Kubernetes NetworkPolicy para isolar comunicação entre pods (ex.: somente gateway pode chamar upload-api)
3. **WAF**: ModSecurity com `nginx` ou AWS WAF na frente do Ingress
4. **Trivy com `exit-code: 1`**: bloquear deploys com vulnerabilidades CRITICAL
5. **JWT Refresh Token**: implementar rotação de tokens para permitir revogação
6. **RBAC K8s**: service accounts mínimas por pod (principle of least privilege)
7. **Auditoria de dependencies**: Dependabot ou Renovate para atualizações automáticas

---

## 4. Segurança da Inteligência Artificial

### 4.1 Uso Controlado dos Modelos de IA

O sistema utiliza LLMs (GPT-4o, GPT-4o Mini, Gemini 2.0 Flash) exclusivamente para analise de diagramas de arquitetura. O escopo dos modelos e rigidamente definido:

| Controle | Implementacao |
|---|---|
| **System prompt com role fixo** | `prompts/v1/system.md` — define o papel como "ArchLens, expert software architecture analyst", limitando o dominio de atuacao |
| **Prompt de analise estruturado** | `prompts/v1/analysis.md` — instrucoes explicitas sobre o que analisar (components, connections, risks, recommendations, scores) |
| **JSON Schema obrigatorio** | `prompts/v1/schema.json` — forca resposta em formato JSON rigido com campos, tipos e valores esperados |
| **Temperature baixa (0.2)** | Reduz aleatoriedade e criatividade excessiva, priorizando respostas deterministicas |
| **response_format: json_object** | OpenAI API forcada a retornar apenas JSON valido (nao aceita texto livre) |

### 4.2 Guardrails — Controle de Entrada e Saida

#### Entrada (Pre-processamento)
- **Validacao de tipo MIME**: apenas `image/png`, `image/jpeg`, `image/webp`, `application/pdf`
- **Validacao de magic bytes**: verificacao binaria no Upload Service (nao confia no Content-Type do browser)
- **Limite de tamanho**: maximo 20MB por arquivo
- **Sanitizacao de filename**: remocao de caracteres especiais e path traversal (`../`)
- **Hash SHA-256**: deduplicacao de diagramas ja analisados

#### Saida (Pos-processamento)
| Guardrail | Arquivo | Descricao |
|---|---|---|
| `validate_provider_response()` | `domain/guardrails.py` | Rejeita respostas sem componentes, sem scores, ou com scores fora do range 0-10 |
| `apply_cross_reference()` | `domain/guardrails.py` | Filtra respostas invalidas quando ha minimo de confirmacoes entre providers |
| **Consensus Engine** | `domain/consensus.py` | Fuzzy matching (Levenshtein ratio > 0.65) entre respostas de multiplos providers para mitigar alucinacoes |
| **MIN_CONFIDENCE_THRESHOLD** | `domain/consensus.py` | Componentes mencionados por menos de 30% dos providers sao descartados |
| **Weighted scoring** | `domain/consensus.py` | Scores finais sao media ponderada pelo peso (weight) de cada provider |

### 4.3 Mitigacao de Alucinacoes

A principal estrategia contra alucinacoes e o **Motor de Consenso Multi-Provider**:

1. O mesmo diagrama e enviado simultaneamente para 3 providers independentes (GPT-4o, GPT-4o Mini, Gemini)
2. As respostas sao comparadas via fuzzy matching (distancia de Levenshtein)
3. Componentes que aparecem em apenas 1 provider (< 30% de concordancia) sao descartados
4. Riscos duplicados entre providers sao mesclados, mantendo a descricao mais detalhada
5. Scores finais sao media ponderada — nenhum provider isolado domina a nota

**Metricas de confianca**:
- 1 provider respondendo: confidence = 50% (degradacao graceful)
- 2 providers concordando: confidence = 70-85%
- 3 providers concordando: confidence = 85-100%

### 4.4 Tratamento Seguro de Falhas da IA

| Cenario de falha | Tratamento | Arquivo |
|---|---|---|
| Provider nao responde (timeout) | Ignora e usa os que responderam (graceful degradation) | `domain/analysis_service.py` |
| Provider retorna JSON invalido | Parse falha, provider e descartado dessa analise | `adapters/*_provider.py` |
| Provider retorna resposta sem componentes | `validate_provider_response()` rejeita a resposta | `domain/guardrails.py` |
| Scores fora do range 0-10 | `_scores_in_range()` rejeita a resposta inteira | `domain/guardrails.py` |
| Todos os providers falham | SAGA transiciona para estado `Failed`, evento `AnalysisFailedEvent` publicado, usuario notificado via SignalR | SAGA state machine |
| SAGA retry (ate 3x) | Orchestrator reenvia `ProcessingStartedEvent` automaticamente | `AnalysisSagaStateMachine.cs` |

### 4.5 Comunicacao Segura entre Servicos

| Pratica | Implementacao |
|---|---|
| JWT Bearer em todas as rotas REST | Gateway valida token antes de rotear |
| RabbitMQ com credenciais autenticadas | Username/password em todos os ambientes |
| MinIO com access key/secret key | Nao utiliza acesso anonimo (corrigido) |
| Correlation ID propagado | `X-Correlation-Id` header em todas as requisicoes para rastreabilidade |
| CORS restrito | Apenas o frontend autorizado (`http://localhost:3000`) |

### 4.6 Riscos e Limitacoes de Seguranca da IA

| Risco | Severidade | Mitigacao | Status |
|---|---|---|---|
| Prompt injection via nome do arquivo | Baixo | Filename sanitizado antes de chegar ao prompt | ✅ Mitigado |
| Prompt injection via conteudo do diagrama | Baixo | Imagem binaria (nao texto), dificil injetar instrucoes | ⚠️ Risco aceito |
| Alucinacao: componentes inventados | Medio | Consensus Engine descarta componentes nao confirmados por multiplos providers | ✅ Mitigado |
| Alucinacao: scores inflados | Medio | Prompt instrui "don't inflate scores" + media ponderada entre providers | ✅ Mitigado |
| Vazamento de dados via API de IA | Medio | Diagramas sao enviados a APIs externas (OpenAI, Google) sem anonimizacao | ⚠️ Documentado |
| Dependencia de APIs externas | Alto | Graceful degradation — funciona com 1 provider; providers sao substituiveis | ⚠️ Risco aceito |
| Rate limit das APIs gratuitas | Medio | GitHub Models ~150 req/dia; Gemini sem limite no tier gratuito | ⚠️ Documentado |

---

---

## 5. Referências OWASP Top 10 (2021)

| Código | Vulnerabilidade | Cobertura |
|---|---|---|
| A01 | Broken Access Control | Rate limiting, JWT auth, sanitização de paths |
| A02 | Cryptographic Failures | HTTPS TLS, secrets via K8s, JWT com chave ≥ 32 chars |
| A03 | Injection | FluentValidation, sanitização de filename, parameterized queries (EF Core) |
| A04 | Insecure Design | Magic bytes, allowlist de extensões, rate limiting |
| A05 | Security Misconfiguration | SecurityHeadersMiddleware, K8s SecurityContext |
| A06 | Vulnerable Components | Trivy scan no CI |
| A07 | Auth Failures | JWT Bearer, auth-strict rate limiting |
| A08 | Software Integrity Failures | Magic bytes + hash deduplication |
| A09 | Logging & Monitoring | Serilog + OpenTelemetry (traces + metrics) |
| A10 | SSRF | N/A — sem HTTP client-side requests a URLs externas controladas pelo usuário |
