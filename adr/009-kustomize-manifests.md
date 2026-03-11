# ADR-009: Kustomize para gerenciamento de manifestos Kubernetes

**Status**: aceita
**Data**: 2026-03-11
**Fase**: 8

## Contexto

Com 19 arquivos de manifesto Kubernetes em `k8s/base/` e a necessidade de personalizar configuracoes por ambiente (local KIND vs dev cloud), precisamos de uma estrategia de gerenciamento que:

- Permita diferenciacao por ambiente sem duplicar arquivos
- Mantenha os manifestos legiveis (YAML puro, sem templates)
- Seja compativel com `kubectl apply` sem ferramentas adicionais
- Integre bem com o pipeline CI/CD (GitHub Actions)
- Seja provisionavel via Terraform

## Decisao

**Kustomize** com estrutura `base/` + `overlays/local/` + `overlays/dev/`, nativo ao `kubectl` desde a versao 1.14.

### Estrutura adotada

```
k8s/
├── base/                    # manifestos canonicos (19 arquivos)
│   ├── namespace.yaml
│   ├── secrets.yaml
│   ├── configmap.yaml
│   ├── infra-*.yaml         # postgres, mongodb, rabbitmq, redis, minio
│   ├── deploy-*.yaml        # auth, upload, orchestrator, notification, report, ai, gateway, frontend
│   ├── hpa.yaml
│   ├── ingress.yaml
│   └── kustomization.yaml   # lista todos os recursos
└── overlays/
    ├── local/               # KIND: NodePort, StorageClass=standard
    │   └── kustomization.yaml
    └── dev/                 # dev/cloud: replicas aumentadas
        └── kustomization.yaml
```

### Como usar

```bash
# Ambiente local (KIND)
kubectl apply -k k8s/overlays/local/

# Ambiente dev
kubectl apply -k k8s/overlays/dev/

# Via Terraform (modulo kustomize)
terraform apply -var="kustomize_overlay=../k8s/overlays/local"
```

## Alternativas consideradas

| Alternativa | Motivo da rejeicao |
|------------|-------------------|
| **Helm** | Requer aprender Go templating (`{{ .Values.foo }}`). Manifestos se tornam ilegíveis com `{{- if .Values.enabled }}`. Para um unico projeto (nao distribuido como library), o overhead nao se justifica. Helm e ideal para distribuir charts publicos, nao para infra propria. |
| **Plain YAML duplicado por ambiente** | Duplicacao de ~19 arquivos por ambiente. Qualquer alteracao requer sincronizacao manual entre ambientes. Propenso a inconsistencias. |
| **Helm + umbrella chart** | Adiciona uma camada de indiracao (chart de charts). Complexidade muito alta para o escopo. |
| **Kapp (Carvel)** | Ferramenta interessante mas externa ao kubectl, sem adocao no curriculo FIAP, sem provider Terraform maduro. |
| **Skaffold** | Focado em inner loop de desenvolvimento, nao em deploy de producao. Nao integra bem com Terraform. |

## Consequencias

**Positivas**:
- **Zero templating**: base e YAML puro, 100% valido sem processamento
- `kubectl apply -k` funciona sem instalar nada alem do kubectl (built-in desde 1.14)
- Patches das overlays sao JSON Patch RFC 6902 (padrao, sem "dialeto" proprietario)
- Kustomize tem provider Terraform (`kbst/kustomization`) para usar `kustomization_build` como data source
- Overlay local modifica apenas o que muda (StorageClass e tipo de Service): base permanece identica para todos os ambientes
- Legibilidade para a banca: qualquer evaluador de K8s entende a estrutura imediatamente

**Negativas**:
- Nao tem mecanismo de valores tipo `values.yaml` do Helm (mas nao precisamos para o escopo atual)
- Para configuracoes complexas de ambiente (muitas variaveis), seria necessario usar `configMapGenerator` ou patches extensos
- Sem registry de charts publicos (irrelevante — nao queremos distribuir o ArchLens como chart)

**Nota sobre Helm**:
A escolha de Kustomize nao exclui Helm para dependencias externas. O NGINX Ingress Controller e instalado via `helm_release` no modulo Terraform `ingress-nginx` (ADR complementar com ADR-008). Kustomize gerencia os manifestos proprios do ArchLens; Helm gerencia charts de terceiros.
