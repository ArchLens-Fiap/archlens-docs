# ADR-001: Polyrepo com Clean Architecture por servico

**Status**: aceita
**Data**: 2026-03-10
**Fase**: 1

## Contexto

O projeto exige multiplos microsservicos com responsabilidades distintas. Precisamos decidir:

1. **Organizacao dos repositorios**: um repositorio por servico (polyrepo) ou todos juntos
2. **Organizacao interna de cada servico**: Clean Architecture, Hexagonal ou Vertical Slice

Restricoes relevantes:
- A organizacao da turma no GitHub da FIAP exige que cada servico tenha seu proprio repositorio
- O time e pequeno (2 pessoas), mas os servicos tem ciclos de vida e tecnologias distintos (.NET 9 e Python)

## Decisao

**Polyrepo**: 12 repositorios separados na organizacao `ArchLens-Fiap`, cada um com seu proprio ciclo de vida, pipeline de CI/CD e Dockerfile.

**Clean Architecture** para todos os servicos .NET (6 camadas por servico: Domain, Application.Contracts, Application, Infrastructure, Api, Tests). **Arquitetura Hexagonal** para o AI Processing Service (Python).

### Estrutura dos repositorios

| Repositorio | Conteudo |
|-------------|----------|
| archlens-auth-service | Auth Service (Clean Arch, 5 projetos .NET) |
| archlens-upload-service | Upload Service (Clean Arch, 6 projetos .NET) |
| archlens-orchestrator-service | Orchestrator/SAGA (Clean Arch, 5 projetos .NET) |
| archlens-notification-service | Notification Service (Clean Arch, 4 projetos .NET) |
| archlens-report-service | Report Service (Clean Arch, 6 projetos .NET) |
| archlens-ai-processing | AI Processing (Python FastAPI, Hexagonal) |
| archlens-gateway | YARP API Gateway (.NET) |
| archlens-frontend | Next.js 16 frontend |
| archlens-contracts | Eventos e DTOs compartilhados (NuGet source-link) |
| archlens-infra-db | docker-compose.yml + init scripts de banco |
| archlens-infra-k8s | Manifestos K8s (Kustomize) + Terraform |
| archlens-docs | ADRs e documentacao |

### Padronizacao entre repositorios .NET

Cada repositorio de servico .NET possui:
- `Directory.Build.props`: versoes de pacotes NuGet e target framework centralizados por servico
- `global.json`: SDK .NET 9 fixado
- `.editorconfig`: convencoes de codigo
- Pipeline proprio (`ci.yml` + `docker-build.yml`)

## Alternativas consideradas

| Alternativa | Motivo da rejeicao |
|------------|-------------------|
| Monorepo (repositorio unico) | Conflita com os requisitos de organizacao da turma no GitHub da FIAP. Tambem dificulta pipelines de build independentes por servico |
| Vertical Slice Architecture | Menos familiar para avaliadores academicos; dificulta demonstrar separacao de responsabilidades em microsservicos |
| Hexagonal para todos | Menos convencao no ecossistema .NET; Clean Arch tem melhor tooling (MediatR, FluentValidation, EF Core) |

## Consequencias

**Positivas**:
- Cada servico tem seu proprio ciclo de vida: deploy, rollback e versioning independentes
- Pipelines de CI/CD isolados: falha em um servico nao bloqueia os outros
- Separacao de responsabilidades reforcada pela fronteira do repositorio
- Avaliadores visualizam claramente a separacao de camadas dentro de cada servico
- Contratos compartilhados via repositorio `archlens-contracts` (sem acoplamento direto)

**Negativas**:
- Mudancas que afetam contratos compartilhados exigem commits em multiplos repositorios
- Cada servico .NET exige sua propria configuracao de `Directory.Build.props` e `global.json`
- Mais overhead de setup inicial (mitigado com templates padronizados desde o inicio)

**Metricas de validacao**:
- Cada servico builda de forma independente com `dotnet build` (0 erros)
- Cada servico tem seu proprio Dockerfile e pipeline de CI/CD funcionando
