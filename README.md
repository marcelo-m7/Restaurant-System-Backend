# Boteco Pro Repository

Este repositório agrupa os códigos e documentos do Boteco Pro, um sistema de gestão para restaurantes. O projeto está dividido em frontend (React) e backend (SQL Server + API), além de documentação complementar.

## Estrutura do Repositório

```
frontend/
  docs/   - guias e especificações da interface web
  src/    - implementação em React
backend/
  docs/   - modelagem do banco e descrição da API
  src/
    db/   - scripts SQL e arquivos relacionados ao banco de dados
    api/  - implementação da API (a ser desenvolvida)
docs/      - outros documentos do projeto
```

O banco de dados está sendo executado localmente em **Microsoft SQL Server** e ficará disponível para a API em `localhost`. Futuramente poderá ser movido para a Google Cloud, utilizando scripts de conexão na pasta `backend/src/db`.

O frontend consome a API para obter ou persistir dados. Enquanto a implementação da API não estiver pronta, o frontend utiliza arquivos mockados para simular as respostas.

## Documentação Complementar

- `backend/docs/` contém detalhes de modelagem e dos objetos (Views, SPs etc.).
- `docs/MVP.md` descreve o plano de implementação inicial do frontend.
«
Consulte cada pasta para informações específicas de instalação e execução.

## Docker Compose

Para executar todo o projeto via contêineres utilize:

```bash
docker compose up
```

A API lê a string de conexão do SQL Server a partir da variável `BOTECOPRO_DB_DSN`. Defina-a em um arquivo `.env` na raiz ou exporte antes de iniciar os serviços. O frontend pode receber `VITE_API_BASE_URL` e `VITE_API_TOKEN` para apontar para o backend desejado. Consulte os arquivos `.env.example` em cada pasta para valores de exemplo.
