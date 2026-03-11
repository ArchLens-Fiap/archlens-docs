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
