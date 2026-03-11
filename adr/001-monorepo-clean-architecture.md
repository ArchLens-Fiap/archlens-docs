# ADR-001: Monorepo com Clean Architecture por servico

**Status**: aceita
**Data**: 2026-03-10
**Fase**: 1

## Contexto

O projeto exige multiplos microsservicos com responsabilidades distintas. Precisamos decidir entre:
- Monorepo (todos os servicos no mesmo repositorio)
- Polyrepo (um repositorio por servico)

E para cada servico, a organizacao interna:
- Clean Architecture (Domain, Application, Infrastructure, Api)
- Hexagonal Architecture
- Vertical Slice Architecture

## Decisao

**Monorepo** com uma unica solution `.sln` contendo 27 projetos .NET, organizados em Clean Architecture com 6 camadas por servico (Domain, Application.Contracts, Application, Infrastructure, Api, Tests).

Configuracao centralizada via `Directory.Build.props` (versoes de pacotes, target framework) e `global.json` (SDK version).

## Alternativas consideradas

| Alternativa | Motivo da rejeicao |
|------------|-------------------|
| Polyrepo | Overhead de manter multiplos repos para um time de 1 pessoa, complexidade de CI/CD |
| Vertical Slice | Menos familiar para avaliadores academicos, dificulta demonstrar separacao de responsabilidades |
| Hexagonal puro | Menos convencao no ecossistema .NET, Clean Arch tem mais tooling |

## Consequencias

**Positivas**:
- Refactoring atomico (muda contrato + todos os consumers em um commit)
- Compartilhamento de SharedKernel e Contracts sem NuGet interno
- CI/CD simplificado com path-based triggers
- Avaliadores verao claramente a separacao de camadas

**Negativas**:
- Solution grande (27 projetos) pode ser lenta para abrir em IDEs
- Risco de acoplamento acidental entre servicos (mitigado por architecture tests na Fase 7)

**Riscos**:
- Se o time crescer, monorepo pode gerar conflitos de merge (irrelevante para hackathon)

---

## Revisao Fase 8 (2026-03-11)

Durante a execucao do projeto, a estrutura evoluiu de **monorepo para polyrepo** com 12 repositorios separados na organizacao `ArchLens-Fiap` no GitHub:

| Repositorio | Conteudo |
|-------------|----------|
| archlens-auth-service | Auth Service (Clean Arch, 5 projetos .NET) |
| archlens-upload-service | Upload Service (Clean Arch, 6 projetos .NET) |
| archlens-orchestrator-service | Orchestrator/SAGA (Clean Arch, 5 projetos .NET) |
| archlens-notification-service | Notification Service (Clean Arch, 4 projetos .NET) |
| archlens-report-service | Report Service (Clean Arch, 6 projetos .NET) |
| archlens-ai-processing | AI Processing (Python FastAPI Hexagonal) |
| archlens-gateway | YARP Gateway (.NET) |
| archlens-frontend | Next.js 16 frontend |
| archlens-contracts | Eventos e DTOs compartilhados |
| archlens-infra-db | docker-compose.yml + infra scripts |
| archlens-infra-k8s | Manifestos K8s (Kustomize) + Terraform |
| archlens-docs | ADRs e documentacao |

**O principio de Clean Architecture por servico permanece identico** — a mudanca foi apenas na organizacao dos repositorios (motivada pelos requisitos de organizacao da turma no GitHub da FIAP).

Os workflows de CI/CD (`ci.yml`, `docker-build.yml`) foram criados em cada repositorio de servico, mantendo path-based triggers por servico. O `Directory.Build.props` e `global.json` permanecem em cada repo de servico .NET para padronizacao de versoes.
