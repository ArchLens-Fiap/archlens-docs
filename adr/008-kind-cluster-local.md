# ADR-008: KIND como cluster Kubernetes local

**Status**: aceita
**Data**: 2026-03-11
**Fase**: 8

## Contexto

Para desenvolver, testar e demonstrar os manifestos Kubernetes localmente, precisamos de um cluster K8s que rode na maquina do desenvolvedor. Os principais requisitos sao:

- Leve o suficiente para rodar junto com Docker Compose e os servicos durante o desenvolvimento
- Suporte a multi-node (ao menos 1 control-plane + 2 workers para testar scheduling real)
- Suporte a NGINX Ingress Controller (necessario para expor servicos via HTTP)
- Provisionavel via Terraform (para automacao completa do ambiente)
- Compativel com pipelines CI/CD (para validacao de manifestos no GitHub Actions)
- Port mapping do host para o cluster (porta 80/443 do host → Ingress controller)

## Decisao

**KIND (Kubernetes-in-Docker)** como cluster local, provisionado via Terraform com o provider `tehcyx/kind`.

### Configuracao adotada

```
control-plane (ingress-ready=true, hostPort 80/443)
  + 2 worker nodes
```

O control-plane recebe o label `ingress-ready=true` e tem `extraPortMappings` para 80 e 443, permitindo que o NGINX Ingress Controller receba trafego diretamente do host.

### Integracao com Terraform

```hcl
resource "kind_cluster" "archlens" {
  name = "archlens"
  kind_config {
    node { role = "control-plane"
      extra_port_mappings { container_port = 80; host_port = 80 }
      extra_port_mappings { container_port = 443; host_port = 443 }
    }
    node { role = "worker" }
    node { role = "worker" }
  }
}
```

## Alternativas consideradas

| Alternativa | Motivo da rejeicao |
|------------|-------------------|
| **Minikube** | Usa VM ou driver dedicado (hyperkit, VirtualBox), mais pesado. Nao tem provider Terraform oficial. Port forwarding menos direto (requer `minikube tunnel`). |
| **k3d** | Wrappper do k3s em Docker, valida. Porem o provider Terraform (`pvotal/k3d`) e menos maduro que o KIND. k3s tem componentes reduzidos que podem mascarar incompatibilidades com K8s padrao. |
| **Docker Desktop K8s** | Nao configuravel via Terraform. Nao suporta multi-node. Nao roda em CI/CD (GitHub Actions). |
| **Minikube com driver Docker** | Suporte multi-node limitado e experimental em versoes recentes. Provider Terraform sem suporte oficial. |

## Consequencias

**Positivas**:
- KIND e o cluster K8s padrao usado nos proprios testes de conformidade do Kubernetes (projeto oficial da CNCF)
- Runs entirely in Docker: sem VM, sem overhead de hypervisor
- Multi-node real: scheduling de pods entre workers, testes de HPA mais realistas
- Provider Terraform `tehcyx/kind` maduro e mantido
- Compativel com GitHub Actions (docker disponivel nos runners)
- Facil reset: `kind delete cluster` + `terraform apply` recria tudo em ~2 minutos

**Negativas**:
- Imagens precisam ser carregadas explicitamente no cluster (`kind load docker-image`) em desenvolvimento local sem registry
- Networking do KIND e diferente do cloud (LoadBalancer nao funciona, usa NodePort/HostPort)
- Mais lento que k3d para provisionar o cluster inicial (~60s vs ~30s)

**Mitigacoes**:
- Registry issue: resolvido usando `imagePullPolicy: IfNotPresent` no overlay local ou subindo as imagens para o GHCR
- Networking: resolvido com NGINX Ingress + `hostPort` no control-plane (porta 80 do host vai direto para o Ingress)
