# ADR-015: RAG com Redis Vector Search para Chat Contextual

**Status:** aceita
**Data:** 2026-03-19
**Decisores:** Rafael Henrique Barbosa Pereira

## Contexto

O chat follow-up do ArchLens permite ao usuario fazer perguntas sobre o relatorio de analise. Na implementacao original, o contexto enviado ao LLM era o relatorio inteiro convertido em texto plano (`_build_context`). Isso apresentava dois problemas:

1. **Token waste**: relatorios grandes enviam todo o conteudo como contexto, mesmo que a pergunta seja sobre um unico componente ou risco
2. **Qualidade das respostas**: com contexto muito amplo, o LLM tende a dar respostas genericas ao inves de focadas no trecho relevante

O curso de IA para Devs (6IADT) aborda RAG na Fase 4 (LLMs e GenAI), incluindo chunking, embeddings e retrieval. Implementar RAG alinha o projeto com o conteudo academico e melhora a qualidade do chat.

## Decisao

Implementar **Retrieval-Augmented Generation (RAG)** para o chat, utilizando:

- **Chunking semantico**: dividir o resultado do consensus em chunks por tipo (componente, risco, conexao, recomendacao, scores, metadata)
- **Embeddings**: OpenAI `text-embedding-3-small` (1536 dimensoes, mais barato e rapido que ada-002)
- **Vector store**: Redis com busca KNN por similaridade coseno (reutilizando o Redis ja existente no projeto)
- **Retrieval**: buscar os top-5 chunks mais relevantes para cada pergunta do usuario
- **Fallback graceful**: se embeddings/Redis nao estiverem disponiveis, cai para o contexto plaintext original

## Alternativas Consideradas

### Pinecone / Weaviate / Qdrant (vector DB dedicado)
- Pros: otimizado para busca vetorial, escalavel
- Contras: mais um servico para manter, custo adicional, overengineering para o volume de dados do ArchLens
- **Rejeitado**: cada analise gera ~10-20 chunks; Redis atende sem problemas

### ChromaDB (in-memory / SQLite)
- Pros: simples, sem infra adicional
- Contras: nao persiste entre restarts sem config adicional, nao integra com o stack existente
- **Rejeitado**: Redis ja esta no projeto e atende melhor

### LangChain + FAISS
- Pros: framework popular, muitas abstractions
- Contras: dependencia pesada, abstraction leak, curva de aprendizado desnecessaria
- **Rejeitado**: implementacao manual com numpy e redis e mais simples e transparente para o escopo

## Consequencias

### Positivas
- Respostas do chat mais precisas e focadas no trecho relevante
- Menor consumo de tokens (top-5 chunks vs relatorio inteiro)
- Respostas mais rapidas (menos tokens = menos tempo de geracao)
- Alinhamento com conteudo IADT Fase 4 (RAG, embeddings, retrieval)
- Fallback transparente: sistema funciona mesmo sem OpenAI embeddings

### Negativas
- Dependencia do OpenAI embeddings API (custo adicional, ~$0.02 por 1M tokens)
- Latencia extra de ~100-200ms para gerar embedding da query
- Numpy como dependencia adicional (~30MB)

### Neutras
- Redis continua com a mesma imagem Docker (redis:7-alpine), sem necessidade do RediSearch module — a busca KNN e feita via scan + cosine similarity no Python (suficiente para ~20 chunks por analise)
