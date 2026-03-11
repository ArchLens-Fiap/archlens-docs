# ArchLens - Task Tracker

> Sistema de Analise Inteligente de Diagramas de Arquitetura
> Hackathon FIAP Fase 5 (12SOAT + 6IADT) - Prazo: 22/05/2026

**Status**: Em andamento
**Fase Atual**: 8 - Infraestrutura K8s + Terraform (proximo)

---

## ESTRATEGIA PARA VENCER

### Premios (referencia Tech4Change Pos Tech Nov/2025)
- 1o lugar: Viagem SXSW Austin/Texas (passagem + hospedagem) ~R$20K
- 2o lugar: Alura 100% + Notebook
- 3o lugar: Notebook

### Criterios de avaliacao (banca externa de especialistas)
1. Cumprir TODOS os requisitos do enunciado (eliminatorio)
2. Demo funcional e visualmente impressionante
3. Inovacao pratica (resolver o problema de forma inteligente)
4. Apresentacao/Storytelling no video
5. Execucao tecnica solida
6. Impacto e aplicabilidade real

### Nossos diferenciais competitivos
- Multi-provider AI com motor de consenso (nenhum outro time tera)
- Chat follow-up contextual (transforma exercicio em produto)
- Frontend completo com real-time (enquanto outros mostram Postman)
- Observabilidade visual (Grafana dashboards no video)
- Polyglot architecture (.NET 9 + Python) com justificativa tecnica
- SAGA Orquestrada + Outbox Pattern + Circuit Breaker (patterns avancados)

### Regra de ouro
> Um sistema COMPLETO e POLIDO com 4 servicos ganha de 6 servicos pela metade.
> A demo e o video decidem o resultado. Priorizar fluxo end-to-end funcionando.

---

## CHECKLIST DE REQUISITOS (do PDF - nao pode faltar NADA)

### Requisitos Funcionais
- [ ] Upload de diagrama (imagem ou PDF)
- [ ] Criacao de um processo de analise
- [ ] Consulta de status: Recebido, Em processamento, Analisado, Erro
- [ ] Geracao de relatorio com: componentes identificados, riscos, recomendacoes

### Requisitos Tecnicos - Arquitetura (SOAT)
- [ ] Arquitetura baseada em microsservicos
- [ ] Comunicacao REST
- [ ] Ao menos um fluxo assincrono (fila/mensageria)
- [ ] Clean Architecture ou Hexagonal
- [ ] Cada servico com responsabilidade clara
- [ ] Cada servico com banco de dados proprio
- [ ] Testes automatizados em cada servico

### Requisitos Tecnicos - IA (IADT)
- [ ] Pipeline claro de IA
- [ ] Justificativa da abordagem escolhida
- [ ] Demonstracao pratica da analise
- [ ] Discussao de limitacoes do modelo
- [ ] Guardrails (controle entrada/saida, mitigacao alucinacoes)

### Requisitos Tecnicos - Integracao IA + Sistema
- [ ] IA e parte do fluxo (nao script isolado)
- [ ] Claro como a IA e acionada
- [ ] Sistema trata falhas da IA
- [ ] Resultado da IA e persistido
- [ ] Relatorio gerado a partir da analise

### Requisitos Tecnicos - Infra/DevOps
- [ ] Docker
- [ ] Docker Compose ou Kubernetes
- [ ] Pipeline CI/CD com Build, Testes, Deploy

### Requisitos - Qualidade e Observabilidade
- [ ] Logs estruturados
- [ ] Tratamento de erros
- [ ] Testes unitarios
- [ ] README explicativo

### Entregaveis
- [ ] Repositorio Git com codigo-fonte
- [ ] Dockerfiles
- [ ] docker-compose ou manifestos K8s
- [ ] Pipeline CI/CD
- [ ] README com: descricao, arquitetura, fluxo, instrucoes de execucao
- [ ] Diagrama de arquitetura
- [ ] Secao de Seguranca no README:
  - [ ] Requisitos basicos de seguranca adotados
  - [ ] Validacao/tratamento de entradas nao confiaveis
  - [ ] Uso controlado de modelos de IA
  - [ ] Tratamento seguro de falhas da IA
  - [ ] Seguranca na comunicacao entre servicos
  - [ ] Riscos e limitacoes de seguranca
- [ ] Video ate 15 minutos demonstrando tudo

---

## FASE 1 - Setup do Monorepo e Infraestrutura Base (Semana 1: 10-16 Mar)

### 1.1 Estrutura do Projeto
- [x] Criar pasta `archlens/` dentro de `fase5/`
- [x] Criar solution .NET 9 (`ArchLens.sln`) com 27 projetos
- [x] Criar projeto `ArchLens.Contracts` (class library - eventos e DTOs compartilhados)
- [x] Criar projeto `ArchLens.SharedKernel` (class library - base entities, value objects, interfaces)
- [x] Criar esqueleto do `ArchLens.Gateway` (API Gateway YARP)
- [x] Criar esqueleto Clean Arch do Upload Service (Domain, Application, Application.Contracts, Infrastructure, Api, Tests)
- [x] Criar esqueleto Clean Arch do Orchestrator Service
- [x] Criar esqueleto Clean Arch do Report Service
- [x] Criar esqueleto Clean Arch do Notification Service
- [x] Criar esqueleto do AI Processing Service (Python FastAPI - estrutura Hexagonal)
- [x] Criar esqueleto do Frontend (Next.js 14 com App Router)
- [x] Verificar que `dotnet build` compila sem erros (0 erros, 27 projetos)
- [ ] Verificar que `pip install -r requirements.txt` roda sem erros
- [ ] Verificar que `npm install` roda sem erros no frontend

### 1.2 Docker Compose Infra
- [x] Criar `docker-compose.infra.yml` com:
  - [x] RabbitMQ (com management UI)
  - [x] MinIO (S3 local) com bucket `archlens-diagrams`
  - [x] PostgreSQL (para dev local, fallback do Neon)
  - [x] MongoDB (para dev local, fallback do Atlas)
  - [x] Redis (para dev local, fallback do Upstash)
- [x] Criar `docker-compose.observability.yml` com:
  - [x] OpenTelemetry Collector
  - [x] Prometheus
  - [x] Grafana (com datasources pre-configurados)
  - [x] Jaeger
  - [x] Grafana Loki (logs)
- [ ] Testar `docker-compose -f docker-compose.infra.yml up` funciona
- [ ] Testar `docker-compose -f docker-compose.observability.yml up` funciona

### 1.3 Contratos de Eventos
- [x] Definir evento `DiagramUploadedEvent` (DiagramId, FileName, FileHash, StoragePath, UserId, Timestamp)
- [x] Definir evento `ProcessingStartedEvent` (AnalysisId, DiagramId, Timestamp)
- [x] Definir evento `AnalysisCompletedEvent` (AnalysisId, DiagramId, ResultJson, ProvidersUsed, ProcessingTimeMs)
- [x] Definir evento `AnalysisFailedEvent` (AnalysisId, DiagramId, ErrorMessage, FailedProviders)
- [x] Definir evento `ReportGeneratedEvent` (ReportId, AnalysisId, DiagramId, Timestamp)
- [x] Definir evento `ReportFailedEvent` (AnalysisId, ErrorMessage)
- [x] Definir evento `StatusChangedEvent` (AnalysisId, OldStatus, NewStatus, Timestamp)
- [x] Definir DTOs compartilhados (AnalysisStatus enum, PagedRequest, PagedResponse)

### 1.4 SharedKernel
- [x] Criar `Entity<TId>` base class
- [x] Criar `AggregateRoot<TId>` base class
- [x] Criar `ValueObject` base class
- [x] Criar `IDomainEvent` interface
- [x] Criar `IRepository<T>` interface generica
- [x] Criar `IUnitOfWork` interface
- [x] Criar `Result<T>` pattern (para retorno sem exceptions)
- [x] Criar `DomainException` base class
- [x] Criar `PagedRequest` / `PagedResponse<T>` base classes

### 1.5 Configuracao Base
- [x] Criar `.gitignore` (incluir TASKS.md, .env, appsettings.Development.json)
- [x] Criar `.editorconfig` para C# e Python
- [x] Criar `Directory.Build.props` (versoes compartilhadas de pacotes NuGet)
- [x] Criar `global.json` (fixar SDK .NET 9)
- [x] Criar `.env.example` com variaveis de ambiente necessarias
- [x] Inicializar repositorio Git local

---

## FASE 2 - Upload Service + API Gateway (Semana 2: 17-23 Mar)

### 2.1 Upload Service - Domain
- [x] Criar entidade `DiagramUpload` (Id, FileName, FileType, FileSize, FileHash, StoragePath, Status, CreatedAt, UserId)
- [x] Criar entidade `AnalysisProcess` (Id, DiagramUploadId, Status, StartedAt, CompletedAt, ErrorMessage)
- [x] Criar value object `FileHash` (SHA-256)
- [x] Criar value object `DiagramStatus` (Received, Processing, Analyzed, Error)
- [x] Criar `IDiagramUploadRepository`
- [x] Criar `IAnalysisProcessRepository`
- [x] Criar `IFileStorageService` (port para MinIO)
- [x] Criar domain events (DiagramUploadCreatedEvent, DiagramStatusChangedEvent)
- [x] Criar domain exceptions (InvalidFileTypeException, FileTooLargeException, InvalidStatusTransitionException)
- [ ] Testes unitarios do Domain

### 2.2 Upload Service - Application
- [x] Criar `UploadDiagramCommand` + `UploadDiagramHandler`
- [x] Criar `UploadDiagramValidator` (FluentValidation - tipo, tamanho, extensao)
- [x] Criar `GetDiagramStatusQuery` + `GetDiagramStatusHandler`
- [x] Criar `ListDiagramsQuery` + `ListDiagramsHandler` (com paginacao)
- [x] Criar `ValidationBehavior` (MediatR pipeline)
- [x] Criar `LoggingBehavior`
- [x] Criar DTOs (UploadDiagramResponse, DiagramStatusResponse)
- [x] Criar `DependencyInjection.cs` (Application)
- [ ] Testes unitarios dos handlers (NSubstitute para mocks)

### 2.3 Upload Service - Infrastructure
- [x] Criar `UploadDbContext` (EF Core + PostgreSQL + IUnitOfWork)
- [x] Criar `DiagramUploadConfiguration` (Fluent API)
- [x] Criar `AnalysisProcessConfiguration`
- [x] Criar migration inicial (20260310003115_InitialCreate)
- [x] Criar `DiagramUploadRepository`
- [x] Criar `AnalysisProcessRepository`
- [x] Criar `MinioStorageService` (implementa IFileStorageService)
- [x] Criar `OutboxMessage` entity + configuration
- [x] Criar `OutboxProcessor` (background service)
- [x] Criar MassTransit configuracao (RabbitMQ)
- [x] Criar `DependencyInjection.cs` (Infrastructure)
- [ ] Testes de integracao com Testcontainers (PostgreSQL)

### 2.4 Upload Service - Api
- [x] Criar `DiagramsController` (upload, get status, list, get by id)
- [x] Criar `GlobalExceptionHandler` com ProblemDetails
- [x] Criar `CorrelationIdMiddleware`
- [ ] Criar `IdempotencyMiddleware` + `X-Idempotency-Key`
- [ ] Criar `FileValidationFilter` (magic bytes check)
- [ ] Configurar Health Checks (PostgreSQL, MinIO, RabbitMQ)
- [ ] Configurar Rate Limiting (FixedWindowRateLimiter)
- [ ] Configurar Swagger/OpenAPI com JWT Bearer
- [ ] Configurar API Versioning (v1)
- [x] Configurar Serilog (JSON prod, texto dev)
- [ ] Configurar OpenTelemetry (ASP.NET, HTTP, SQL, OTLP exporter)
- [x] Criar Dockerfile (multi-stage build)
- [ ] Testes de integracao com WebApplicationFactory
- [ ] Testes BDD com Reqnroll (upload de diagrama completo)

### 2.5 API Gateway
- [x] Configurar YARP reverse proxy (rotas para cada servico)
- [ ] Configurar JWT authentication middleware
- [x] Configurar CORS
- [ ] Configurar Rate Limiting global
- [ ] Configurar Health Check aggregator
- [ ] Configurar Swagger aggregator (Swashbuckle)
- [ ] Criar Dockerfile
- [ ] Testar roteamento para Upload Service

### 2.6 Integracao
- [ ] Testar fluxo: Gateway -> Upload Service -> MinIO -> PostgreSQL -> RabbitMQ (evento publicado)
- [ ] Verificar correlation ID propagado
- [ ] Verificar logs estruturados
- [ ] Verificar metricas no Prometheus

---

## FASE 3 - AI Processing Service (Semana 3: 24-30 Mar)

### 3.1 Estrutura Base (Python)
- [x] Configurar FastAPI app com lifespan
- [x] Configurar pydantic-settings (config por env vars)
- [x] Configurar structlog (JSON logging)
- [ ] Configurar OpenTelemetry (OTLP exporter para Jaeger)
- [x] Configurar conexao RabbitMQ (aio-pika)
- [x] Configurar conexao Redis (aioredis)
- [x] Configurar conexao MinIO (boto3)
- [x] Criar Dockerfile (multi-stage build)
- [x] Criar health check endpoint

### 3.2 Provider Abstraction
- [x] Criar `AIProviderPort` (ABC com analyze_diagram, chat, name, weight)
- [x] Criar `ProviderResponse` model (components, connections, risks, recommendations, scores)
- [x] Implementar `OpenAIProvider` (GPT-4o Vision)
- [x] Implementar `GeminiProvider` (Gemini 2.0 Flash)
- [x] Implementar `ClaudeProvider` (Claude Sonnet 4)
- [x] Criar `ProviderRegistry` (registry de providers ativos)
- [x] Configurar retry com backoff exponencial (tenacity)
- [ ] Testes unitarios de cada provider (com mocks de API)

### 3.3 Prompts
- [x] Criar `prompts/v1/system.md` (system prompt para analise)
- [x] Criar `prompts/v1/analysis.md` (prompt de analise)
- [x] Criar `prompts/v1/schema.json` (JSON Schema da resposta esperada)
- [x] Criar `prompts/v1/chat.md` (prompt de follow-up)
- [x] Criar loader de prompts (le arquivos .md e injeta no provider)

### 3.4 Preprocessing
- [x] Criar modulo de preprocessing de imagens (resize max 2048x2048)
- [x] Criar conversor PDF -> imagem (pdf2image + poppler)
- [x] Criar handler para PDFs multi-pagina
- [x] Criar hash SHA-256 do arquivo para deduplicacao
- [ ] Testes unitarios de preprocessing

### 3.5 Consensus Engine
- [x] Criar `ConsensusEngine` class
- [x] Implementar merge de componentes (fuzzy match Levenshtein)
- [x] Implementar merge de riscos (deduplicacao semantica)
- [x] Implementar merge de recommendations (dedup fuzzy)
- [x] Implementar score final (media ponderada)
- [x] Implementar calculo de confidence por consenso entre providers
- [ ] Testes unitarios com fixtures (golden tests)

### 3.6 Guardrails
- [x] Criar validacao de resposta (componentes, scores, ranges)
- [x] Criar cross-reference (filtra respostas invalidas)
- [ ] Criar fallback: retry com prompt simplificado se todos falham
- [ ] Testes de chaos (1 provider lixo, 1 timeout, 1 OK)

### 3.7 Pipeline Completo
- [x] Criar `AnalysisService` que orquestra: preprocess -> parallel providers -> consensus -> guardrails
- [x] Criar consumer RabbitMQ (consome `ProcessingStartedEvent`)
- [x] Criar publisher RabbitMQ (publica `AnalysisCompletedEvent` ou `AnalysisFailedEvent`)
- [x] Implementar cache Redis (hash dedup, TTL 24h)
- [x] Implementar graceful degradation (3 -> 2 -> 1 -> 0 providers com timeout 60s)
- [ ] Testar pipeline end-to-end com diagrama real

### 3.8 Chat Follow-up
- [x] Criar endpoint SSE `/chat` (streaming de resposta)
- [ ] Criar contexto completo: relatorio + diagrama + historico
- [x] Implementar guardrails de chat (escopo limitado a arquitetura via prompt)
- [ ] Armazenar historico no Redis (TTL 1h)
- [ ] Testes do endpoint de chat

---

## FASE 4 - Orchestrator + Notification (Semana 4: 31 Mar - 6 Abr)

### 4.1 Orchestrator Service - Domain + Application
- [x] Criar `AnalysisSagaState` (MassTransit SagaStateMachineInstance - CorrelationId, DiagramId, AnalysisId, Status, RetryCount, etc.)
- [x] Criar `SagaStatusResponse` DTO + `ISagaStateRepository` interface
- [x] Criar queries MediatR (GetByDiagram, GetByAnalysis, ListSagas)
- [x] Criar `DependencyInjection.cs` (Application)
- [x] Criar `GenerateReportCommand` nos Contracts (SAGA orquestrada comanda Report Service)
- [x] Atualizar `ReportFailedEvent` com DiagramId (necessario para correlacao da saga)

### 4.2 Orchestrator Service - Infrastructure
- [x] Criar `AnalysisSagaStateMachine` (MassTransit StateMachine)
  - [x] States: Processing -> Analyzed -> Completed / Failed
  - [x] Events: DiagramUploaded, AnalysisCompleted, AnalysisFailed, ReportGenerated, ReportFailed
  - [x] Retry logic: max 3 tentativas com re-publish de ProcessingStartedEvent
  - [x] Compensacao: em caso de falha permanente, marca como Failed
  - [x] Publica StatusChangedEvent em cada transicao (para Notification Service)
  - [x] Publica GenerateReportCommand quando analise completa (SAGA orquestrada)
- [x] Criar `SagaDbContext` (EF Core - saga state persistence)
- [x] Criar `AnalysisSagaStateConfiguration` (Fluent API com indices e row version)
- [x] Configurar MassTransit com EF Core saga repository (optimistic concurrency)
- [x] Configurar message retry (1s, 5s, 15s)
- [x] Criar `SagaStateRepository` (implementa ISagaStateRepository)
- [x] Criar migration inicial (InitialSagaCreate)
- [x] Criar `DependencyInjection.cs` (Infrastructure)
- [ ] Configurar DLQ para cada consumer
- [ ] Testes unitarios da StateMachine (MassTransit TestHarness)
- [ ] Testes de integracao

### 4.3 Orchestrator Service - Api
- [x] Criar `SagaController` (get by diagram, get by analysis, list)
- [x] Criar `GlobalExceptionHandler` com ProblemDetails
- [x] Criar `CorrelationIdMiddleware`
- [x] Configurar health checks + Swagger
- [x] Configurar Serilog
- [x] Configurar `appsettings.json` (PostgreSQL, RabbitMQ)
- [x] Criar Dockerfile (multi-stage build)

### 4.4 Notification Service
- [x] Criar `INotificationSender` interface (Domain)
- [x] Criar SignalR Hub (`AnalysisHub`) com groups por analysisId + dashboard
- [x] Criar `StatusChangedConsumer` (MassTransit consumer -> SignalR push)
- [x] Criar `SignalRNotificationSender` (implementa INotificationSender)
- [x] Configurar Redis backplane para scaling de SignalR
- [x] Configurar MassTransit com RabbitMQ
- [x] Configurar CORS para frontend
- [x] Configurar `appsettings.json` (RabbitMQ, Redis, CORS)
- [x] Criar `DependencyInjection.cs` (Infrastructure)
- [x] Criar Dockerfile (multi-stage build)
- [ ] Configurar autenticacao no SignalR (JWT)
- [ ] Testes do Hub

---

## FASE 5 - Report Service (Semana 5: 7-13 Abr)

### ADR Review (Fase 5)
- [ ] Revisar ADRs existentes (alguma decisao invalidada?)
- [ ] Criar ADR para: MongoDB como banco do Report Service (vs PostgreSQL JSONB)
- [ ] Criar ADR para: PDF export (QuestPDF vs iText vs outro)

### 5.1 Report Service - Domain
- [x] Criar entidade `AnalysisReport` (Id, AnalysisId, DiagramId, Components, Risks, Scores, CreatedAt)
- [x] Criar value objects (IdentifiedComponent, IdentifiedConnection, ArchitectureRisk, ArchitectureScores)
- [x] Criar `IReportRepository`

### 5.2 Report Service - Application
- [x] Criar `GetReportByIdQuery` + `GetReportByAnalysisQuery` handlers
- [x] Criar `ListReportsQuery` + handler (paginado com total count)
- [x] Criar `ReportMapper` (Domain -> DTO)
- [x] Criar DTOs (ReportResponse, ReportSummaryResponse, ComponentDto, RiskDto, ScoresDto)
- [ ] Criar `ExportReportPdfQuery` + handler
- [ ] Criar `CompareReportsQuery` + handler (lado-a-lado)

### 5.3 Report Service - Infrastructure
- [x] Criar `ReportDocument` + `ReportDocumentMapper` (MongoDB POCO <-> Domain)
- [x] Criar `ReportRepository` (MongoDB.Driver: CRUD com paginacao)
- [x] Criar `GenerateReportConsumer` (MassTransit: deserializa ResultJson, cria Report, publica ReportGeneratedEvent)
- [x] Criar `GenerateReportFaultConsumer` (MassTransit Fault<T>: publica ReportFailedEvent sem try-catch no consumer)
- [x] Criar `DependencyInjection` (MongoDB + MassTransit RabbitMQ)
- [ ] Criar `PdfExportService` (QuestPDF ou iText)
- [ ] Testes com Testcontainers (MongoDB)

### 5.4 Report Service - Api
- [x] Criar `ReportsController` (get by id, get by analysis, list paginado)
- [x] Criar `GlobalExceptionHandler` + `CorrelationIdMiddleware`
- [x] Configurar Program.cs (Serilog, Swagger, health checks, MediatR, Infrastructure DI)
- [x] Criar `appsettings.json` + `appsettings.Docker.json`
- [x] Criar Dockerfile (multi-stage build)
- [x] Adicionar Report Service no docker-compose.yml (porta 5205)
- [ ] Testes de integracao
- [ ] Testes BDD (gerar relatorio completo)

### 5.5 Cleanup de codigo (aplicado globalmente)
- [x] Remover connection strings hardcoded de todos DependencyInjection.cs (Upload, Orchestrator, Notification, Report)
- [x] Usar `GetRequiredSection` + throw para config obrigatoria
- [x] Remover `#pragma warning disable/restore CA1812`
- [x] Remover try-catch de consumers (usar MassTransit Fault<T> pattern)

---

## FASE 6 - Frontend (Semana 6: 14-20 Abr)

### ADR Review (Fase 6)
- [ ] Revisar ADRs existentes
- [ ] Criar ADR para: Next.js 16 App Router + shadcn/ui (vs Remix, vs MUI)
- [ ] Criar ADR para: estrategia de data fetching (React Query + SignalR)

### 6.1 Setup
- [x] Inicializar Next.js 16 com App Router + TypeScript (React 19)
- [x] Instalar e configurar Tailwind CSS v4 + shadcn/ui (16 componentes)
- [x] Configurar React Query (TanStack Query) para data fetching
- [x] Configurar SignalR client (@microsoft/signalr)
- [x] Criar layout base (navbar, tema dark/light com next-themes)
- [x] Criar providers (query client, signalr connection, theme)
- [x] Criar API client (axios + interceptors + tipos)
- [x] Criar types (DiagramUpload, SagaStatus, ReportResponse, etc.)

### 6.2 Paginas
- [x] Landing page (`/`) com hero + upload drag-and-drop
- [ ] Login page (`/login`) com JWT
- [ ] Register page (`/register`)
- [x] Analyses list (`/analyses`) com paginacao, status real-time via SignalR
- [x] Analysis detail (`/analyses/[id]`) com:
  - [x] Status tracker visual (timeline: Received -> Processing -> Analyzed -> Completed)
  - [ ] Diagrama original (preview)
  - [x] Relatorio interativo (componentes, riscos, recomendacoes com badges)
  - [x] Score cards (escalabilidade, seguranca, confiabilidade, manutenibilidade)
  - [x] Score radar chart (recharts)
- [ ] Report viewer (`/analyses/[id]/report`) com export PDF
- [x] Chat follow-up (`/analyses/[id]/chat`) com:
  - [x] Interface de chat (mensagens + cursor animado)
  - [x] Sugestoes de perguntas pre-definidas
- [x] Compare page (`/compare`) com selecao de 2 analises lado-a-lado

### 6.3 Componentes Reutilizaveis
- [x] FileUploader (drag-drop + validacao + progress)
- [x] StatusBadge (Received/Processing/Analyzed/Completed/Error com cores + animate-pulse)
- [x] ConfidenceBadge (score visual SVG com cor gradiente)
- [x] ReportCard (card resumido com status, data, erros, retries)
- [x] ChatMessage (mensagem do usuario / IA com cursor streaming)
- [x] ScoreRadar (grafico radar recharts)
- [x] Navbar (navegacao + indicador SignalR live/offline)
- [x] ThemeToggle (dark/light com icones animados)

### 6.4 Real-time
- [x] Conectar SignalR ao Notification Service (provider com reconnect automatico)
- [x] Atualizar status das analises em tempo real (sem refresh)
- [ ] Notificacao toast quando analise completa

### 6.5 Testes Frontend
- [ ] Jest + React Testing Library para componentes
- [ ] Playwright E2E: fluxo upload -> status -> relatorio -> chat

---

## FASE 6.5 - Autenticacao JWT (Seguranca)

### 6.5.1 Auth Service (.NET 9 - Clean Architecture)
- [x] Domain: User entity (Username, Email, PasswordHash, Role, lockout 5 tentativas/15min)
- [x] Domain: IUserRepository, IPasswordHasher interfaces
- [x] Application.Contracts: IJwtTokenGenerator, JwtOptions, DTOs (AuthResponse, RegisterResponse)
- [x] Application: LoginCommand + handler (BCrypt verify, lockout, Result pattern)
- [x] Application: RegisterCommand + handler (FluentValidation, username regex, senha forte)
- [x] Infrastructure: EF Core + PostgreSQL (UserConfiguration, unique indexes)
- [x] Infrastructure: BcryptPasswordHasher (work factor 12)
- [x] Infrastructure: JwtTokenGenerator (HMAC-SHA256, claims: sub, name, role, jti)
- [x] Api: AuthController (POST /auth/login, POST /auth/register)
- [x] Api: GlobalExceptionHandler, Program.cs (auto-migrate), Dockerfile
- [x] Api: appsettings.json + appsettings.Docker.json
- [x] Adicionado a solution (5 projetos)
- [x] Build OK 0 erros

### 6.5.2 Gateway JWT
- [x] JWT Bearer authentication no YARP Gateway
- [x] Policy "Authenticated" nas rotas protegidas (upload, orchestrator, report, ai)
- [x] Rotas /auth e /hubs sem autenticacao (anonimas)
- [x] Header Token-Expired quando JWT expira
- [x] Rotas realinhadas com frontend: /api/upload, /api/orchestrator, /api/reports, /api/ai
- [x] Auth cluster + AI cluster adicionados

### 6.5.3 Frontend Auth
- [x] lib/auth.ts (token storage, getUser, setAuth, logout, isAuthenticated)
- [x] API client: axios interceptor com Bearer token + redirect 401
- [x] Login page (/login) com form + toast + redirect
- [x] Register page (/register) com form + validacao visual
- [x] Navbar atualizada: mostra username logado, botao logout, botao sign-in

### 6.5.4 Infraestrutura
- [x] PostgreSQL: banco archlens_auth no init script
- [x] docker-compose.yml: auth-api service
- [x] Gateway depends_on auth-api
- [x] LOCAL-DEV.md atualizado

---

## FASE 7 - Testes, Observabilidade e CI/CD (Semana 7: 21-27 Abr)

### ADR Review (Fase 7)
- [x] Revisar ADRs existentes
- [ ] Criar ADR para: estrategia de testes (unit vs integration vs E2E, Testcontainers)
- [ ] Criar ADR para: CI/CD pipeline (GitHub Actions, path-based triggers)

### 7.1 Architecture Tests (ArchUnitNET)
- [x] Upload Service: Domain nao referencia Infrastructure/Api
- [x] Upload Service: Application referencia apenas Domain
- [x] Replicar para Report, Auth (9 layer-dependency tests + 2 naming conventions)
- [x] Validar naming conventions (Controllers terminam em Controller, interfaces com I)
- [x] Projeto `ArchLens.ArchitectureTests` criado com TngTech.ArchUnitNET.xUnit

### 7.2 Testes Unitarios e Integracao
- [x] Upload Domain: DiagramUpload (12 testes), FileHash (6), DiagramStatus (6)
- [x] Upload Application: GetDiagramStatusHandler (2 testes)
- [x] Upload Integration: WebApplicationFactory + MassTransitTestHarness (5 testes)
- [x] Auth Domain: User entity (10 testes)
- [x] Auth Application: LoginCommandHandler (5), RegisterCommandHandler (3)
- [x] Report Domain: AnalysisReport (6), ValueObjects (8)
- [x] Report Application: GetReportHandler (4)
- [x] AI Processing Python: conftest.py com fixtures, test_models, test_consensus, test_preprocessing, test_guardrails
- [x] Auth Tests project criado e adicionado a solution

### 7.3 Observabilidade
- [x] Dashboard Grafana: Services Overview (request rate, latencia p95, taxa erros, servicos ativos, RabbitMQ, PostgreSQL)
- [x] Dashboard Grafana: AI Pipeline (analises por status, tempo medio, taxa sucesso provider, cache hit rate, SAGA transitions)
- [x] Provisioning automatico: dashboards.yml + 2 JSONs em grafana/provisioning/dashboards/
- [x] Alertas Prometheus: 6 regras (HighErrorRate, HighLatency, ServiceDown, AIProviderHighFailureRate, RabbitMQQueueBacklog, HighAnalysisProcessingTime)
- [x] Prometheus config atualizado com auth-service e ai-processing scrape targets
- [ ] Verificar distributed tracing completo no Jaeger (.NET -> RabbitMQ -> Python -> RabbitMQ -> .NET)
- [ ] Verificar logs correlacionados no Loki (x-correlation-id)

### 7.4 CI/CD
- [x] Criar workflow `ci.yml` (build .NET, test Python, build frontend, Trivy security scan)
- [x] Criar workflow `docker-build.yml` (path-based triggers, GHCR push, Trivy scan por imagem)
- [x] Configurar path-based triggers (dorny/paths-filter - so rebuilda servico alterado)
- [x] Configurar Trivy scan nas imagens Docker e filesystem
- [ ] Configurar SonarCloud (quality gate)
- [ ] Configurar coverage report com PR comment

---

## FASE 8 - Infraestrutura K8s + Terraform (Semana 8: 28 Abr - 4 Mai)

### ADR Review (Fase 8)
- [ ] Revisar ADRs existentes
- [ ] Criar ADR para: KIND vs Minikube vs k3d (cluster local)
- [ ] Criar ADR para: Kustomize vs Helm (gerenciamento de manifests)

### 8.1 Dockerfiles
- [x] Criar `.dockerignore` na raiz do monorepo
- [x] Criar `docker-compose.yml` master (infra + servicos + observability com profile)
- [x] Criar Dockerfile do Gateway
- [x] Criar `appsettings.Docker.json` para Upload, Orchestrator, Notification, Gateway
- [x] Instalar `curl` em todos os Dockerfiles (healthcheck)
- [ ] Otimizar Dockerfiles de cada servico (layers, cache)
- [ ] Testar `docker compose up --build` sobe tudo e funciona end-to-end

### 8.2 Kubernetes Manifests (Kustomize)
- [ ] Criar `k8s/base/` com deployments, services, HPA para cada servico
- [ ] Configurar probes (startup, readiness, liveness) em cada deployment
- [ ] Configurar security context (runAsNonRoot, drop capabilities)
- [ ] Configurar resource requests/limits
- [ ] Configurar HPA (CPU 70%, Memory 80%, min 2, max 10)
- [ ] Criar ConfigMaps e Secrets
- [ ] Criar Ingress NGINX
- [ ] Criar overlay `k8s/overlays/local/` (KIND-specific)
- [ ] Criar overlay `k8s/overlays/dev/` (para futuro cloud)

### 8.3 Terraform
- [ ] Criar modulo `kind-cluster` (provisiona cluster KIND)
- [ ] Criar modulo `ingress-nginx` (instala NGINX ingress no KIND)
- [ ] Criar modulo `kustomize` (aplica manifests)
- [ ] Criar `main.tf` + `variables.tf` + `outputs.tf`
- [ ] Testar: `terraform apply` cria cluster KIND + deploya tudo
- [ ] Documentar modulos EKS (comentados, prontos para cloud)

### 8.4 Validacao
- [ ] Testar fluxo completo no KIND (upload -> analise -> relatorio)
- [ ] Verificar HPA escala com carga
- [ ] Verificar probes funcionam (restart em caso de falha)
- [ ] Verificar observabilidade funciona no K8s

---

## FASE 9 - Seguranca, LGPD e Polimento (Semana 9: 5-11 Mai)

### ADR Review (Fase 9)
- [ ] Revisar TODOS os ADRs (revisao final pre-entrega)
- [ ] Atualizar status de ADRs que mudaram
- [ ] Verificar que cada decisao tem justificativa clara para o video
- [ ] Criar ADR-008: Estrategia de Conformidade LGPD

### 9.1 Seguranca
- [ ] Validacao de entrada em todos os endpoints (FluentValidation)
- [ ] Verificar magic bytes no upload (nao so extensao)
- [ ] Sanitizacao de nomes de arquivo
- [ ] Configurar HTTPS no Ingress
- [ ] Configurar OWASP headers (X-Content-Type-Options, X-Frame-Options, etc.)
- [ ] Revisar secrets (nenhum hardcoded, tudo via env vars)
- [ ] Scan Trivy em todas as imagens finais
- [ ] Documentar riscos e limitacoes de seguranca

### 9.1.1 LGPD e Privacidade de Dados

> Conteudo das aulas da Fase 5: LGPD no desenvolvimento de software, IA na LGPD,
> governanca de dados. Mostrar conformidade no video e um diferencial competitivo.

**Mapeamento de Dados Pessoais (Data Mapping)**
- [ ] Documentar quais dados pessoais o sistema coleta (email, nome, IP, uploads)
- [ ] Classificar dados por sensibilidade (dados cadastrais vs dados de uso)
- [ ] Documentar finalidade de cada dado coletado (Art. 7 LGPD - base legal)
- [ ] Documentar tempo de retencao de cada tipo de dado

**Direitos do Titular (Art. 17-22 LGPD)**
- [ ] Endpoint DELETE /api/auth/me - exclusao de conta e dados (direito ao esquecimento)
- [ ] Endpoint GET /api/auth/me/data - exportacao dos dados do usuario (portabilidade)
- [ ] Cascata de exclusao: deletar usuario -> deletar uploads -> deletar reports -> deletar notifications
- [ ] Anonimizacao de dados em logs (nao logar email/nome em plaintext)

**Consentimento e Transparencia**
- [ ] Tela de consentimento no registro (checkbox LGPD com texto claro)
- [ ] Pagina /privacy-policy no frontend (politica de privacidade)
- [ ] Pagina /terms no frontend (termos de uso)
- [ ] Banner de cookies (se aplicavel)

**IA e LGPD (Aula 4 - IA na LGPD)**
- [ ] Documentar que dados do usuario sao enviados para IAs externas (OpenAI, Google, Anthropic)
- [ ] Informar usuario que diagramas serao processados por IA (consentimento explicito no upload)
- [ ] Garantir que nenhum dado pessoal do usuario e enviado aos providers de IA (apenas o diagrama)
- [ ] Documentar que nao ha decisao automatizada com efeito legal (Art. 20 LGPD)
- [ ] Transparencia: mostrar quais providers analisaram cada diagrama (ja temos no report)

**Medidas Tecnicas de Protecao**
- [ ] Criptografia em transito (HTTPS/TLS entre todos os servicos)
- [ ] Criptografia em repouso (PostgreSQL encryption, MinIO SSE)
- [ ] Audit log de acesso a dados pessoais (quem acessou o que e quando)
- [ ] Data retention policy: deletar uploads antigos apos X dias (configuravel)
- [ ] Minimizacao de dados: nao coletar mais do que o necessario

**Documentacao LGPD (para o README e video)**
- [ ] Secao LGPD no README com medidas adotadas
- [ ] Diagrama de fluxo de dados pessoais (data flow diagram)
- [ ] Registro de atividades de tratamento (ROPA simplificado)
- [ ] Mencionar no video: "conformidade LGPD by design"

### 9.2 Cobertura de Testes (meta: 90%+)

> Referencia fase4: 1.152 testes, 91%+ cobertura em todos os servicos.
> Atual: 92 testes. Precisamos triplicar no minimo.

- [ ] Configurar Coverlet em todos os projetos de teste (medir cobertura real)
- [ ] Upload: aumentar testes unitarios (handlers, validators) - meta 80+ testes
- [ ] Auth: aumentar testes (edge cases, validators) - meta 40+ testes
- [ ] Report: aumentar testes (mapper, handlers, VOs completos) - meta 40+ testes
- [ ] Orchestrator: criar testes unitarios da StateMachine (MassTransit TestHarness)
- [ ] AI Processing Python: aumentar testes (providers mock, pipeline e2e)
- [ ] Testcontainers: PostgreSQL (Upload, Auth), MongoDB (Report)
- [ ] Testes BDD com Reqnroll: pelo menos 1 feature por servico (fluxo upload completo)
- [ ] SonarCloud: configurar Quality Gate (80%+ coverage, badges nos READMEs)
- [ ] Verificar cobertura >= 90% em cada servico antes de seguir

### 9.3 Polimento
- [ ] Revisar e melhorar UI do frontend
- [ ] Adicionar loading states e error states em todas as paginas
- [ ] Adicionar animacoes de transicao
- [ ] Otimizar performance do frontend (lazy loading, code splitting)
- [ ] Revisar mensagens de erro (amigaveis ao usuario)
- [ ] Testar com diagramas reais variados (microservices, monolito, event-driven, etc.)
- [ ] Configurar Rate Limiting em todos os servicos (FixedWindowRateLimiter)
- [ ] Configurar Swagger com JWT Bearer (AuthorizeOperationFilter)
- [ ] Idempotency Middleware no Upload Service (X-Idempotency-Key)

### 9.4 Resilience Testing
- [ ] Testar com 1 provider AI fora do ar
- [ ] Testar com RabbitMQ reiniciando
- [ ] Testar com banco fora do ar (health checks devem refletir)
- [ ] Verificar circuit breakers abrem e fecham corretamente

---

## FASE 10 - Documentacao e Video (Semana 10: 12-22 Mai)

### 10.1 Database Seeders + Teste End-to-End

> Referencia fase4: DatabaseSeeder em cada servico + Saga Happy Path testado completo.
> Fazer ANTES de gravar o video.

- [ ] Criar DatabaseSeeder no Auth (usuario admin + usuario demo)
- [ ] Criar DatabaseSeeder no Upload (diagramas de exemplo pre-carregados)
- [ ] Criar dados de exemplo no Report (relatorio completo para demonstracao)
- [ ] Testar `docker compose up --build` sobe tudo sem erros
- [ ] Testar fluxo completo end-to-end: Upload -> SAGA -> AI -> Report -> Notification
- [ ] Verificar frontend conecta no backend via Gateway
- [ ] Verificar SignalR funciona (status real-time)
- [ ] Documentar bugs encontrados e corrigir antes de gravar

### 10.2 Postman Collections

> Referencia fase4: 4 collections + environment. Banca tecnica usa para validar APIs.

- [ ] Criar `docs/postman/` com collections organizadas
- [ ] Auth Service Collection (POST /auth/login, POST /auth/register)
- [ ] Upload Service Collection (POST /diagrams, GET /diagrams, GET /diagrams/{id})
- [ ] Orchestrator Service Collection (GET /sagas, GET /sagas/{id})
- [ ] Report Service Collection (GET /reports, GET /reports/{id}, GET /reports/analysis/{id})
- [ ] AI Processing Collection (POST /analyze, POST /chat)
- [ ] Environment file (localhost + Docker)
- [ ] Testar todas as requests passam com JWT token

### 10.3 README
- [ ] Descricao do problema
- [ ] Arquitetura proposta (diagrama Mermaid)
- [ ] Fluxo da solucao (passo a passo)
- [ ] Stack tecnologico
- [ ] Instrucoes de execucao (docker-compose e KIND)
- [ ] Secao de Seguranca (obrigatoria):
  - [ ] Requisitos basicos de seguranca adotados
  - [ ] Validacao e tratamento de entradas nao confiaveis
  - [ ] Uso controlado de modelos de IA
  - [ ] Tratamento seguro de falhas da IA
  - [ ] Seguranca na comunicacao entre servicos
  - [ ] Riscos e limitacoes de seguranca
- [ ] Decisoes arquiteturais (ADRs resumidos)
- [ ] Como rodar testes
- [ ] Estrutura de pastas

### 10.4 Diagrama de Arquitetura
- [ ] Diagrama C4 - Context
- [ ] Diagrama C4 - Container
- [ ] Diagrama de sequencia do fluxo principal
- [ ] Diagrama do pipeline de IA

### 10.5 Video (ate 15 minutos) -- STORYTELLING, nao tutorial

O video DECIDE o resultado. Formato: narrativa de produto, nao aula tecnica.

- [ ] Roteiro do video (storytelling):
  1. **HOOK - O Problema** (1 min): "Empresas tem centenas de diagramas que ninguem analisa. Revisoes manuais nao escalam. E se existisse uma ferramenta que analisasse automaticamente?"
  2. **A Solucao - ArchLens** (1 min): Mostrar o dashboard, explicar a proposta de valor. "Upload, analise automatica, relatorio em segundos."
  3. **Demo ao vivo - Upload** (1.5 min): Drag-and-drop de um diagrama real. Mostrar a validacao, o status mudando em tempo real.
  4. **Demo ao vivo - Analise** (2 min): Mostrar 3 IAs processando em paralelo. Status atualizando via WebSocket. "Nao dependemos de uma unica IA."
  5. **Demo ao vivo - Relatorio** (2 min): Relatorio interativo com componentes, riscos, scores de confianca. Destacar o consenso entre providers.
  6. **Demo ao vivo - Chat** (1.5 min): Perguntar "como resolver esse risco de SPOF?" e ver a resposta streaming. WOW moment.
  7. **Arquitetura por tras** (2 min): Diagrama C4, microsservicos, SAGA, event-driven. Clean Arch. Justificar cada decisao brevemente.
  8. **Observabilidade** (1.5 min): Grafana dashboard com metricas reais. Jaeger com trace distribuido .NET->Python. "Sabemos exatamente o que acontece."
  9. **LGPD e Privacidade** (1 min): Direito ao esquecimento, consentimento explicito para IA, data flow diagram. "Privacy by design desde o dia 1."
  10. **Infra e Seguranca** (1 min): K8s rodando, CI/CD, testes passando, scan de seguranca.
  11. **Conclusao** (0.5 min): "ArchLens: de diagrama a insight em segundos. Pronto para producao, conforme LGPD."
- [ ] Preparar diagramas de exemplo impactantes para a demo (microsservicos complexo, monolito com problemas)
- [ ] Ensaiar o roteiro (timing e fluencia)
- [ ] Gravar video
- [ ] Editar e revisar (legendas, transicoes limpas)
- [ ] Submeter

---

## AUDITORIA DE ARQUITETURA DE PASTAS

> Revisao feita em 10/03/2026. Verificar antes de cada fase para evitar retrabalho.

### Estrutura Atual (validada)

```
archlens/
├── .editorconfig / .env.example / .gitignore / .dockerignore / global.json / Directory.Build.props
├── ArchLens.sln                          (27 projetos)
├── docker-compose.yml                    (master: infra + servicos + obs com profile)
├── docs/adr/                             (7 ADRs documentados)
├── infra/
│   ├── docker/
│   │   ├── docker-compose.infra.yml      (RabbitMQ, MinIO, PostgreSQL, MongoDB, Redis)
│   │   ├── docker-compose.observability.yml (OTel, Prometheus, Grafana, Jaeger, Loki)
│   │   ├── grafana/provisioning/datasources/
│   │   ├── init-scripts/postgres/
│   │   ├── otel/
│   │   └── prometheus/
│   ├── kubernetes/
│   │   ├── base/                         (vazio - Fase 8)
│   │   └── overlays/local/ + dev/        (vazio - Fase 8)
│   └── terraform/                        (vazio - Fase 8)
├── src/
│   ├── AIProcessing/                     (Python FastAPI - Hexagonal)
│   │   ├── app/api/ adapters/ domain/ messaging/ prompts/
│   │   ├── tests/
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   ├── ApiGateway/ArchLens.Gateway/      (YARP)
│   ├── Contracts/ArchLens.Contracts/     (Events/ + Enums/)
│   ├── SharedKernel/ArchLens.SharedKernel/ (Domain/ + Application/)
│   ├── Frontend/archlens-web/            (Next.js 14 + Tailwind)
│   └── Services/
│       ├── Upload/       (Domain, Application, Application.Contracts, Infrastructure, Api, Tests)
│       ├── Orchestrator/ (idem - skeleton)
│       ├── Report/       (idem - skeleton)
│       └── Notification/ (idem - skeleton)
```

### Problemas Identificados e Acoes

| # | Problema | Impacta Fase | Acao |
|---|---------|-------------|------|
| 1 | ~~Falta `.dockerignore` em cada servico~~ | ~~8~~ | RESOLVIDO: `.dockerignore` criado na raiz do monorepo. |
| 2 | ~~Falta `docker-compose.yml` master~~ | ~~8~~ | RESOLVIDO: `docker-compose.yml` master criado (infra + servicos + obs com profile). |
| 3 | ~~Falta `grafana/provisioning/dashboards/`~~ | ~~7~~ | RESOLVIDO: 2 dashboards + provisioner YAML criados na Fase 7.3. |
| 4 | TASKS.md diz `k8s/base/` mas pasta real e `infra/kubernetes/base/` | 8 | Ja esta correto na estrutura. Atualizar referencias no TASKS se necessario. |
| 5 | ~~Falta `docs/` para ADRs e diagramas~~ | ~~10~~ | RESOLVIDO: `docs/adr/` criado com 7 ADRs. Falta `docs/diagrams/` (Fase 10). |
| 6 | ~~Falta `conftest.py` no AIProcessing/tests~~ | ~~3~~ | RESOLVIDO: conftest.py criado com fixtures na Fase 7. |
| 7 | Falta `appsettings.json` proprios para Orchestrator, Report, Notification | 4, 5 | Criar com connection strings corretas ao implementar cada servico. |
| 8 | ~~Falta projeto de Architecture Tests~~ | ~~7~~ | RESOLVIDO: `ArchLens.ArchitectureTests` criado com ArchUnitNET (11 testes). |
| 9 | Frontend aninhado `src/Frontend/archlens-web/` (1 nivel extra) | 6, 8 | Manter assim - Dockerfile fica em `src/Frontend/archlens-web/Dockerfile`. Nao mover agora. |
| 10 | `Fase Atual` no header esta desatualizado | - | Manter atualizado ao final de cada sessao. |
| 11 | Falta `src/AIProcessing/.dockerignore` | 8 | Criar para excluir `__pycache__/`, `.venv/`, `tests/`, `.mypy_cache/`. |

### Checklist Pre-Fase (verificar antes de iniciar cada fase)

**Antes da Fase 4 (Orchestrator + Notification): CONCLUIDO**
- [x] Criar `appsettings.json` para Orchestrator com connection strings (PostgreSQL, RabbitMQ)
- [x] Criar `appsettings.json` para Notification com connection strings (RabbitMQ, Redis)
- [x] Verificar que Orchestrator.Infrastructure referencia MassTransit (ja esta)
- [x] Verificar que Notification.Infrastructure referencia SignalR + Redis (ja esta)

**Antes da Fase 5 (Report Service): CONCLUIDO**
- [x] Criar `appsettings.json` para Report com connection strings (MongoDB, RabbitMQ)
- [x] Verificar que Report.Infrastructure referencia MongoDB.Driver (ja esta)

**Antes da Fase 6 (Frontend):**
- [ ] Instalar shadcn/ui (`npx shadcn-ui@latest init`)
- [ ] Criar pastas: `src/components/ui/`, `src/lib/`, `src/hooks/`, `src/services/`, `src/types/`
- [ ] Configurar `next.config.ts` com rewrite para API Gateway

**Antes da Fase 7 (Testes + CI/CD): CONCLUIDO**
- [x] Criar `grafana/provisioning/dashboards/` com JSONs
- [x] Criar projeto `ArchLens.ArchitectureTests` com ArchUnitNET
- [x] Criar `conftest.py` para AIProcessing com fixtures
- [x] Criar `ArchLens.Auth.Tests` (faltava)

**Antes da Fase 8 (K8s + Terraform): PARCIALMENTE CONCLUIDO**
- [x] Criar `.dockerignore` para todos os servicos (.NET e Python)
- [x] Criar `docker-compose.yml` master
- [x] Criar Dockerfile do Gateway
- [x] Criar Dockerfile do Report Service

**Antes da Fase 10 (Docs):**
- [x] Criar `docs/adr/` (7 ADRs documentados: monorepo, polyglot, multi-provider AI, SAGA, event-driven, observability, SignalR)
- [ ] Criar `docs/diagrams/` (C4, sequencia, pipeline IA)

---

## Registro de Progresso

| Data | Fase | O que foi feito |
|------|------|-----------------|
| 09/03/2026 | Planejamento | Plano completo criado, decisoes arquiteturais definidas |
| 10/03/2026 | Fase 1 | Monorepo completo: 27 projetos .NET (Clean Arch), Python FastAPI, Next.js 14, Docker Compose (infra + observabilidade), SharedKernel, Contracts, Gateway YARP. Build OK. |
| 10/03/2026 | Fase 2 | Upload Service completo (Domain DDD, Application CQRS+MediatR, Infrastructure EF Core+MinIO+MassTransit+Outbox, API com Controller+ProblemDetails+CorrelationId). Migration gerada. Dockerfile. |
| 10/03/2026 | Fase 3 | AI Processing Service: 3 providers (OpenAI GPT-4o, Gemini 2.0 Flash, Claude Sonnet 4), Consensus Engine com fuzzy matching Levenshtein, Guardrails, AnalysisService pipeline, prompts v1, preprocessing, Dockerfile. |
| 10/03/2026 | Fase 4 | Orchestrator: SAGA StateMachine MassTransit (Processing->Analyzed->Completed/Failed), retry 3x, EF Core saga repo, GenerateReportCommand, migration. Notification: SignalR Hub, StatusChangedConsumer, Redis backplane. Build OK. |
| 10/03/2026 | Docs | 7 ADRs documentados (monorepo, polyglot, multi-provider AI, SAGA, event-driven, observability, SignalR). Checkpoints de revisao por fase. |
| 10/03/2026 | DevOps | docker-compose.yml master (infra + 5 servicos + obs com profile), .dockerignore, Dockerfile Gateway, appsettings.Docker.json x4. |
| | | |
| 10/03/2026 | Fase 5 | Report Service: Domain (AnalysisReport, 4 VOs), Application (queries MediatR, mapper, DTOs), Infra (MongoDB repo, GenerateReportConsumer, FaultConsumer), Api (controller, Dockerfile, docker-compose). Cleanup global: conn strings hardcoded removidas de 4 servicos. |
| 10/03/2026 | Fase 3 (gaps) | AI Processing: MinIO download (aioboto3), Redis cache dedup (TTL 24h), RabbitMQ publisher MassTransit-compatible (AnalysisCompleted/FailedEvent com envelope format), consumer completo integrado no lifespan com retry (tenacity). Pipeline end-to-end conectado. |
| 10/03/2026 | DevOps | git init, branch main, commit inicial (233 files, 15.7K lines), push para github.com/rafahenrique1/archlens (privado). |
| 10/03/2026 | Fase 6 | Frontend Next.js 16 + React 19 + Tailwind v4 + shadcn/ui. 5 paginas, 8 componentes custom, SignalR real-time, React Query, dark/light theme. Build OK. |
| 10/03/2026 | Fase 6.5 | Auth Service: Clean Arch + DDD, JWT HMAC-SHA256, BCrypt, lockout, FluentValidation. Gateway: JWT Bearer + policies. Frontend: Login/Register pages, axios interceptor, 401 redirect. Build OK (backend 0 erros, frontend 8 rotas). |
| 10/03/2026 | Fase 7 | 92 testes .NET: ArchUnitNET (11 layer+naming), Upload (42: domain+app+integration), Auth (21: domain+app), Report (18: domain+app). Python: 4 suites (models, consensus, preprocessing, guardrails). Grafana: 2 dashboards provisionados + 6 alertas Prometheus. CI/CD: ci.yml + docker-build.yml com path-based triggers e Trivy. |
| | | |
