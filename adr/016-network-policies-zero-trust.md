# ADR-016: Network Policies — Zero Trust no Kubernetes

**Status**: aceita
**Fase**: 10

## Contexto

O namespace `archlens` contem 13 workloads (8 aplicativos + 5 infraestrutura) que se comunicam entre si. Por padrao, Kubernetes permite que qualquer pod comunique com qualquer outro pod no cluster — modelo "flat network". Isso viola o principio de menor privilegio e expoe a superficie de ataque caso um container seja comprometido (movimentacao lateral).

Requisitos de seguranca do projeto:
- OWASP Top 10: principio de defesa em profundidade
- LGPD: medidas tecnicas de protecao de dados pessoais
- Avaliacao de seguranca para hackathon FIAP Fase 5

## Decisao

Implementar **Network Policies com abordagem Zero Trust**: negar todo o trafego por padrao e liberar apenas as conexoes estritamente necessarias, com granularidade por servico e porta.

### Estrategia

1. **Default Deny All** — bloqueia todo ingress/egress no namespace
2. **Allow DNS** — libera resolucao DNS (kube-dns) para todos os pods
3. **Per-service policies** — cada servico tem uma policy dedicada que lista exatamente quais pods pode receber (ingress) e para quais pode enviar (egress)
4. **Infrastructure isolation** — bancos de dados e message brokers so aceitam conexoes dos servicos que realmente os utilizam

### Mapa de comunicacao

```
Ingress Controller (nginx)
  ├── frontend        :3000
  ├── auth-api        :8080  → postgres :5432
  ├── upload-api      :8080  → postgres :5432, rabbitmq :5672, minio :9000
  ├── orchestrator-api:8080  → postgres :5432, rabbitmq :5672
  ├── report-api      :8080  → mongodb :27017, rabbitmq :5672
  ├── notification-api:8080  → rabbitmq :5672, redis :6379
  └── ai-processing   :8000  → rabbitmq :5672, redis :6379, minio :9000, external :443

Gateway (YARP) :8080 → todos os backend services
```

### Destaque: AI Processing egress externo

O `ai-processing` e o unico servico que precisa de acesso a internet (APIs OpenAI, Google AI, Anthropic). A policy permite egress HTTPS (porta 443) apenas para IPs publicos, bloqueando ranges privados (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16).

## Alternativas consideradas

| Alternativa | Pros | Contras |
|---|---|---|
| **Sem Network Policies** | Simples, sem configuracao | Flat network, zero isolamento |
| **Istio/Linkerd Service Mesh** | mTLS automatico, observabilidade | Overhead operacional, complexidade, sidecar em cada pod |
| **Calico Global Policies** | Policies por namespace global | Depende de CNI especifico |
| **Network Policies nativas (escolhido)** | Standard K8s API, sem dependencias, portavel | Requer CNI compativel (Calico, Cilium, etc.) |

## Consequencias

### Positivas
- **Isolamento**: compromisso de um container nao permite movimentacao lateral
- **Menor superficie de ataque**: PostgreSQL so aceita de 3 servicos, MongoDB de 1
- **Auditavel**: cada policy documenta exatamente quem fala com quem
- **Standard K8s**: funciona com qualquer CNI compativel (Calico, Cilium, Canal)
- **Defesa em profundidade**: complementa runAsNonRoot, drop ALL capabilities, readOnlyRootFilesystem

### Negativas
- Requer CNI que suporte Network Policies (KinD com Calico ou Cilium)
- Mais manifests para manter (16 policies em 1 arquivo)
- Erros em policies podem causar comunicacao intermitente (debugging mais complexo)

## Validacao

```bash
# Verificar policies aplicadas
kubectl get networkpolicies -n archlens

# Testar isolamento: pod temporario nao deve acessar postgres
kubectl run test-pod --rm -it --image=busybox -n archlens -- wget -qO- http://postgres:5432

# Testar comunicacao permitida: auth-api deve acessar postgres
kubectl exec -n archlens deploy/auth-api -- curl -sf http://postgres:5432 || echo "TCP OK (connection refused is expected, not timeout)"
```
