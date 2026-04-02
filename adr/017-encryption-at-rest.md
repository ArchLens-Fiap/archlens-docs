# ADR-017: Criptografia em Repouso (Encryption at Rest)

**Status**: aceita
**Fase**: 10

## Contexto

O projeto armazena dados sensíveis em múltiplos sistemas de persistência:
- **PostgreSQL**: credenciais de usuários (bcrypt hashes), metadados de análises
- **MongoDB**: relatórios de análise com scores e recomendações
- **MinIO**: diagramas de arquitetura (imagens PNG/PDF) enviados pelos usuários
- **Redis**: cache de resultados, sessões SignalR (dados transitórios)

A LGPD (Art. 46) exige "medidas técnicas aptas a proteger os dados pessoais de acessos não autorizados e de situações acidentais ou ilícitas de destruição, perda, alteração, comunicação ou difusão". Criptografia em repouso é uma dessas medidas.

## Decisão

Implementar criptografia em repouso com abordagem pragmática por camada:

### 1. MinIO — SSE-S3 (Server-Side Encryption) ✅ Implementado

MinIO suporta SSE-S3 nativamente com chave gerenciada internamente:

- **`MINIO_KMS_SECRET_KEY`**: chave AES-256 configurada via variável de ambiente
- **Auto-encryption**: `mc encrypt set sse-s3` no bucket `archlens-diagrams`
- Todo objeto gravado é criptografado transparentemente; descriptografia automática na leitura por clientes autenticados
- Zero mudança no código da aplicação

```
MINIO_KMS_SECRET_KEY=archlens-key:<base64-encoded-256-bit-key>
```

### 2. PostgreSQL — Data Checksums + Estratégia de Volume

PostgreSQL Community não possui TDE (Transparent Data Encryption) nativo.

**O que implementamos:**
- `POSTGRES_INITDB_ARGS=--data-checksums`: habilita verificação de integridade em cada página de dados, detectando corrupção silenciosa no disco
- Senhas já armazenadas com bcrypt (work factor 12) — inúteis mesmo se extraídas

**Estratégia de produção:**
- Volume criptografado (AWS EBS encryption, GCP Persistent Disk encryption, Azure Disk encryption)
- Ou LUKS/dm-crypt no host para clusters bare-metal
- PostgreSQL 17+ com extensão `pg_tde` (experimental, quando disponível)

### 3. MongoDB — Community Limitation

MongoDB Community Edition **não suporta** encryption at rest nativo (recurso exclusivo do MongoDB Enterprise/Atlas).

**Estratégia de produção:**
- MongoDB Atlas (encryption at rest habilitado por padrão em todas as tiers)
- Volume criptografado no host (mesmo approach do PostgreSQL)

### 4. Redis — Cache Transitório

Redis é in-memory por natureza. Dados persistidos em RDB/AOF são cache e podem ser reconstruídos.

**Mitigação já existente:**
- `requirepass` em todas as conexões
- Network Policies isolam acesso (ADR-016)
- Dados transitórios com TTL

## Alternativas consideradas

| Alternativa | Pros | Contras |
|---|---|---|
| **pgcrypto column-level** | Criptografia por campo | Mudança invasiva em queries, overhead de CPU, complexidade |
| **HashiCorp Vault KMS** | Chaves rotacionáveis, auditoria | Infraestrutura adicional, complexidade operacional |
| **Application-layer encryption** | Controle total | Overhead em cada serviço, gerenciamento de chaves complexo |
| **Volume-level + SSE-S3 (escolhido)** | Transparente, sem mudança de código | Requer volume criptografado para PostgreSQL/MongoDB em produção |

## Consequências

### Positivas
- MinIO: **criptografia real** — objetos ilegíveis sem a chave KMS
- PostgreSQL: **integridade verificável** + estratégia clara para produção
- **LGPD-compliant**: medida técnica documentada e implementada
- **Zero impacto** no código da aplicação (transparente para os serviços)
- **Defesa em profundidade**: complementa JWT, Network Policies, runAsNonRoot

### Negativas
- PostgreSQL e MongoDB dependem de volume criptografado em produção (responsabilidade do provedor cloud)
- Chave MinIO KMS em variável de ambiente (em produção, usar Sealed Secrets ou External Secrets Operator)
- Overhead mínimo de CPU no MinIO (~1-3% para AES-NI)
