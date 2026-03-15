# ADR-012: Next.js 16 + shadcn/ui + React Query para Frontend

**Status**: aceita
**Fase**: 6

## Contexto

O projeto precisa de uma interface web que suporte: upload de diagramas, acompanhamento em tempo real via WebSocket, visualizacao de relatorios complexos, chat com IA, e dashboard administrativo com graficos. A maioria dos concorrentes no hackathon apresentara demos via Postman — um frontend funcional e visual e um diferencial competitivo decisivo.

## Decisao

Usar **Next.js 16** (React 19) com **App Router**, **shadcn/ui** para componentes, **React Query** para server state, e **SignalR client** para real-time.

### Stack

| Tecnologia | Versao | Papel |
|------------|--------|-------|
| Next.js | 16 | Framework SSR/SSG com App Router |
| React | 19 | UI library |
| TypeScript | 5.x | Tipagem estatica |
| Tailwind CSS | 4 | Utility-first styling |
| shadcn/ui | latest | Componentes acessiveis (Radix UI) |
| React Query | 5.x | Server state + cache |
| SignalR Client | latest | WebSocket real-time |
| Recharts | 2.x | Graficos do admin dashboard |
| Axios | 1.x | HTTP client com interceptors |
| Sonner | latest | Toast notifications |

### Arquitetura Frontend

```
App Router (pages) → React Query (cache) → Axios (HTTP) → API Gateway
                   → SignalR Client (WS) → Notification Hub
```

### Paginas

- `/` - Upload de diagramas (drag & drop)
- `/login`, `/register` - Autenticacao
- `/analyses` - Lista de analises
- `/analyses/[id]` - Relatorio detalhado
- `/analyses/[id]/chat` - Chat follow-up com IA
- `/compare` - Comparacao lado a lado
- `/admin` - Dashboard administrativo (protegido por role)

## Alternativas consideradas

| Alternativa | Motivo da rejeicao |
|------------|-------------------|
| Remix | Menor ecossistema de componentes, menos familiar ao time |
| Angular + Material | Overhead maior, curva de aprendizado, menos flexivel para prototipagem rapida |
| MUI (Material UI) | Componentes pesados, dificil customizar, bundle size maior |
| Vite + React puro | Sem SSR, sem routing nativo, mais config manual |

## Consequencias

**Positivas**:
- Demo visual impressionante (fator UAU para a banca)
- shadcn/ui e copy-paste (total controle, sem vendor lock-in)
- React Query elimina boilerplate de loading/error states
- SignalR integra nativamente com backend .NET
- Tailwind CSS v4 = zero config, performance otima

**Negativas**:
- Next.js 16 e recente (menor historico de producao)
- React 19 tem breaking changes em algumas bibliotecas
- Frontend adiciona complexidade de deploy (mitigado por Docker)
