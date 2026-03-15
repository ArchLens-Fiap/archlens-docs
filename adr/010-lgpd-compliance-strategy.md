# ADR-010: Estrategia de Conformidade LGPD

**Status**: aceita
**Fase**: 9

## Contexto

O sistema processa dados pessoais (email, username) e envia diagramas para providers de IA externos (OpenAI, Google). A Lei Geral de Protecao de Dados (LGPD) exige medidas tecnicas e organizacionais para proteger dados pessoais dos titulares.

## Decisao

Implementar **Privacy by Design** com as seguintes medidas:

### Direitos do Titular (Art. 18 LGPD)

| Direito | Implementacao |
|---------|--------------|
| Acesso aos dados | `GET /api/auth/me/data` - exporta todos os dados do usuario em JSON |
| Eliminacao | `DELETE /api/auth/me` - cascata via evento `UserAccountDeletedEvent` para todos os servicos |
| Portabilidade | Exportacao em formato JSON padrao |
| Revogacao de consentimento | Exclusao da conta remove todos os dados |

### Cascata de Exclusao (Event-Driven)

```
Auth (delete user) → UserAccountDeletedEvent → RabbitMQ
  → Upload Service (deleta diagramas + MinIO files)
  → Report Service (deleta relatorios)
  → Orchestrator Service (deleta sagas)
```

### Minimizacao de Dados

- Apenas email e username coletados (minimo necessario)
- Diagramas enviados para IA NAO contem dados pessoais (apenas a imagem)
- Nenhum dado pessoal e armazenado nos providers de IA (APIs stateless)

### Medidas Tecnicas

- Criptografia em transito (HTTPS/TLS)
- Audit log de acesso a dados pessoais (`PersonalDataAccessAuditMiddleware`)
- Rate Limiting (protecao contra forca bruta)
- Data retention policy (configuravel)
- Consentimento explicito no upload (informamos que diagramas serao processados por IA)

### Transparencia

- Pagina `/privacy-policy` com politica de privacidade completa
- Pagina `/terms` com termos de uso
- Relatorio mostra quais providers analisaram cada diagrama
- Documentacao ROPA simplificada no README

## Alternativas consideradas

| Alternativa | Motivo da rejeicao |
|------------|-------------------|
| Nao implementar LGPD | Requisito obrigatorio do hackathon |
| Anonimizacao completa | Desnecessaria - diagramas nao contem dados pessoais |
| Consentimento granular por provider | Over-engineering - todos os providers fazem a mesma funcao |

## Consequencias

**Positivas**:
- Conformidade com LGPD desde o design (Privacy by Design)
- Direitos do titular implementados via API
- Cascata de exclusao garante nenhum dado orfao
- Diferencial para a banca (demonstra maturidade)

**Negativas**:
- Complexidade da cascata de exclusao (mitigado por eventos assincronos)
- Audit log gera volume de dados (mitigado por log rotation)
