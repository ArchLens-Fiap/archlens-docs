# Segurança — Riscos, Mitigações e Limitações

> **Versão**: 1.0 | **Data**: 2026-01-10 | **Fase**: 9.1

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

## 4. Referências OWASP Top 10 (2021)

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
