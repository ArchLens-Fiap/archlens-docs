# LGPD — Conformidade com a Lei Geral de Proteção de Dados

> Lei nº 13.709/2018 | Vigência: setembro de 2020

Este documento descreve como o ArchLens trata dados pessoais, as medidas técnicas implementadas e os mecanismos disponíveis para exercício dos direitos dos titulares.

---

## 1. Mapeamento de Dados Pessoais

| Dado | Classificação | Finalidade | Base Legal (Art. 7º) | Retenção |
|------|--------------|-----------|---------------------|----------|
| Nome de usuário | Pessoal | Autenticação, identificação | V — execução de contrato | Vida da conta |
| E-mail | Pessoal | Autenticação, comunicações | V — execução de contrato | Vida da conta |
| Hash de senha (bcrypt) | Pessoal (derivado) | Autenticação segura | V — execução de contrato | Vida da conta |
| Endereço IP | Pessoal | Segurança, rate limiting, logs | IX — interesse legítimo | 30 dias |
| Arquivos de diagrama | Pessoal (potencial) | Análise de arquitetura via IA | I — consentimento explícito | 90 dias |
| Relatórios gerados | Dado do usuário | Consulta e histórico | V — execução de contrato | 90 dias |
| Data/hora de acesso | Dados de uso | Auditoria de segurança | IX — interesse legítimo | 30 dias |
| Consentimento LGPD | Registro de consentimento | Demonstração de compliance | I — consentimento | Vida da conta |

### Dados NÃO coletados

- Dados de saúde ou biométricos
- Origem racial ou étnica
- Convicções religiosas ou políticas
- Dados financeiros ou bancários

---

## 2. Fluxo de Dados Pessoais

```
[Usuário] ─── HTTPS/TLS ──► [Auth Service]
                               │
                               ├── PostgreSQL (bcrypt hash, e-mail, username)
                               └── Logs Serilog (e-mail MASCARADO: u***@d***.com)

[Usuário] ─── HTTPS/TLS ──► [Upload Service]
                               │
                               ├── MinIO (arquivo de diagrama — SSE habilitado)
                               └── PostgreSQL (metadados do upload)

[Upload Service] ──────────► [AI Orchestrator]
                               │
                               ├── OpenAI API    ┐
                               ├── Google Gemini ├── Apenas conteúdo do diagrama
                               └── Claude API    ┘   SEM dados pessoais do usuário

[AI Orchestrator] ─────────► [Report Service]
                               └── PostgreSQL (relatório vinculado ao UserId)
```

### Garantias no fluxo de IA (Art. 20 LGPD)

- Apenas o conteúdo técnico do diagrama é enviado para provedores de IA
- Nenhum dado pessoal (nome, e-mail, IP) é incluído nas requisições
- Não há decisões automatizadas com efeito legal — os relatórios são sugestões
- Consentimento explícito é coletado no momento do upload

---

## 3. Direitos dos Titulares (Art. 17–22 LGPD)

| Direito | Endpoint | Método | Observação |
|---------|----------|--------|------------|
| Acesso e portabilidade | `GET /auth/me/data` | JWT Bearer | Retorna JSON com todos os dados |
| Exclusão (*direito ao esquecimento*) | `DELETE /auth/me` | JWT Bearer | Hard delete — processa cascade |
| Confirmação de tratamento | `GET /auth/me/data` | JWT Bearer | Inclui `lgpdConsentGivenAt` |
| Revogação de consentimento | `DELETE /auth/me` | JWT Bearer | Exclui conta + dados |

### Cascade de Exclusão

Ao executar `DELETE /auth/me`, o auth service remove o registro do usuário. Os demais serviços devem consumir o evento `UserAccountDeleted` (publicado via RabbitMQ) para excluir dados relacionados:

```
UserAccountDeleted event
  ├── Upload Service: excluir uploads e arquivos no MinIO
  ├── Report Service: excluir relatórios
  └── Notification Service: excluir notificações e preferências
```

---

## 4. Medidas Técnicas Implementadas

### Proteção em Trânsito
- ✅ HTTPS/TLS obrigatório via Kubernetes Ingress + cert-manager
- ✅ HSTS habilitado (`max-age=31536000; includeSubDomains`)

### Proteção em Repouso
- ✅ Bcrypt (custo 11) para hashes de senha
- ⚙️ PostgreSQL encryption at rest — habilitado via volume PVC cifrado no K8s
- ⚙️ MinIO SSE (Server-Side Encryption) configurado para uploads

### Controle de Acesso
- ✅ JWT Bearer para autenticação
- ✅ RBAC: roles `User` e `Admin`
- ✅ Rate limiting — 5 tentativas/min no endpoint de login

### Anonimização em Logs
- ✅ `EmailMaskingEnricher` no Serilog (auth-service): e-mails são mascarados como `u***@domain.tld`
- ✅ Logs não contêm senhas em nenhuma circunstância (bcrypt hash não é logado)

### Minimização de Dados
- ✅ Apenas dados estritamente necessários são coletados
- ✅ IPs são armazenados apenas em logs temporários (30 dias)
- ✅ Diagramas são retidos por no máximo 90 dias

### Consentimento
- ✅ Checkbox LGPD obrigatório no formulário de registro
- ✅ `lgpdConsentGivenAt` armazenado com timestamp UTC
- ✅ Validação backend: `LgpdConsent: true` é obrigatório

---

## 5. ROPA — Registro de Atividades de Tratamento

*(Registro simplificado conforme Art. 37 LGPD)*

| # | Atividade | Controlador | Dados Tratados | Base Legal | Finalidade | Retenção | Compartilhamento |
|---|-----------|-------------|----------------|------------|------------|----------|-----------------|
| 1 | Cadastro e autenticação | ArchLens | Username, e-mail, senha (hash), IP | Contrato (Art. 7º, V) | Criação e gestão de conta | Vida da conta | Nenhum |
| 2 | Análise de diagrama via IA | ArchLens + Provedores IA | Conteúdo do diagrama | Consentimento (Art. 7º, I) | Geração de relatório de arquitetura | 90 dias | OpenAI, Google, Anthropic (apenas diagrama) |
| 3 | Logs de segurança | ArchLens | IP, timestamp, endpoint | Interesse legítimo (Art. 7º, IX) | Prevenção de fraudes e monitoramento | 30 dias | Nenhum |
| 4 | Relatórios arquiteturais | ArchLens | UserId + conteúdo do relatório | Contrato (Art. 7º, V) | Consulta histórica pelo usuário | 90 dias | Nenhum |
| 5 | Notificações | ArchLens | UserId, status do processamento | Contrato (Art. 7º, V) | Feedback em tempo real | Vida da conta | Nenhum |

---

## 6. Subprocessadores de Dados

| Subprocessador | País | Dados Compartilhados | Base Legal | Garantias |
|---------------|------|---------------------|------------|-----------|
| OpenAI | EUA | Conteúdo de diagrama (sem PII) | Consentimento | Cláusulas contratuais padrão (SCC) |
| Google (Gemini) | EUA | Conteúdo de diagrama (sem PII) | Consentimento | Cláusulas contratuais padrão (SCC) |
| Anthropic (Claude) | EUA | Conteúdo de diagrama (sem PII) | Consentimento | Cláusulas contratuais padrão (SCC) |

> **Nota sobre transferências internacionais (Art. 33 LGPD):** Provedores de IA são localizados nos EUA. A transferência é realizada com base no consentimento explícito do titular e está condicionada a cláusulas contractuais adequadas.

---

## 7. Notificação de Incidentes (Art. 48 LGPD)

Em caso de incidente de segurança com dados pessoais:

1. Identificação e contenção em até **2 horas**
2. Avaliação de impacto em até **24 horas**
3. Notificação à ANPD em até **72 horas** (se risco relevante)
4. Notificação aos titulares afetados o mais breve possível

Contato para relatar incidentes: **security@archlens.dev** (ver também [SECURITY.md](./SECURITY.md))

---

## 8. Contato do Encarregado (DPO)

Para exercer direitos ou esclarecer dúvidas sobre o tratamento de dados:

- **E-mail:** privacy@archlens.dev
- **Prazo de resposta:** até 15 dias úteis
- **ANPD:** [www.gov.br/anpd](https://www.gov.br/anpd) — Para reclamações formais

---

*Documento mantido pelo time ArchLens. Revisão periódica: a cada 6 meses ou após mudanças significativas no tratamento de dados.*
