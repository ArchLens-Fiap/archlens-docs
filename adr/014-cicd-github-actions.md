# ADR-014: CI/CD com GitHub Actions e Path-based Triggers

**Status**: aceita
**Fase**: 7

## Contexto

Com 12 repositorios independentes (polyrepo), precisamos de CI/CD que: builde apenas servicos alterados, rode testes automaticamente, faca scan de seguranca, e publique imagens Docker.

## Decisao

Usar **GitHub Actions** com **path-based triggers** (dorny/paths-filter) para CI/CD eficiente em polyrepo.

### Workflow: ci.yml

Trigger: push/PR em qualquer branch

```
1. Build .NET 9 (dotnet build + dotnet test)
2. Build Python (pip install + pytest)
3. Build Frontend (npm install + npm run build)
4. Trivy security scan (filesystem)
```

### Workflow: docker-build.yml

Trigger: push em main (path-based)

```
1. dorny/paths-filter → detecta quais servicos mudaram
2. Para cada servico alterado:
   a. docker build (multi-stage)
   b. Trivy scan na imagem
   c. Push para GHCR (GitHub Container Registry)
```

### Seguranca

| Ferramenta | Tipo | Alvo |
|-----------|------|------|
| Trivy | Vulnerabilidades | Filesystem + imagens Docker |
| GitHub Dependabot | Dependencias | NuGet, npm, pip |
| GHCR | Registry | Imagens Docker (private) |

### Vantagens do path-based

- Servico X alterado → so rebuilda servico X
- Reduz tempo de CI de ~15min (tudo) para ~3min (servico afetado)
- Cada repo tem seu proprio workflow independente

## Alternativas consideradas

| Alternativa | Motivo da rejeicao |
|------------|-------------------|
| Jenkins | Self-hosted, mais complexo de configurar, sem integracao nativa GitHub |
| GitLab CI | Projeto ja esta no GitHub, migracao desnecessaria |
| Build tudo sempre | Desperdicio de CI minutes, feedback loop lento |
| ArgoCD | Over-engineering para escopo academico |

## Consequencias

**Positivas**:
- CI/CD automatico em cada push
- Scan de seguranca integrado (Trivy)
- Path-based = eficiente e rapido
- GHCR integrado ao GitHub (sem registry externo)

**Negativas**:
- GitHub Actions free tier tem limites (2000 min/mes)
- Path-filter adiciona complexidade ao workflow
- Sem deploy automatico em K8s (manual via Terraform/Kustomize)
