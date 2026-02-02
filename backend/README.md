# Boteco Pro Backend

**Autor original:** Marcelo Santos (<a79433@ualg.pt>)

---

## Descrição

Este diretório reúne a documentação do banco de dados, os scripts SQL e, futuramente, a implementação da API que será consumida pelo frontend.

### Estrutura de Pastas

```
backend/
  README.md
  docs/                - modelagem e documentos de referência
  src/
    db/                - scripts SQL e configurações de conexão
      sql/             - arquivos .sql com criação de tabelas, views, SPs
    api/               - código da API (a ser desenvolvido)
    test/              - testes automatizados (pytest)
```

- **docs/**
  - `01_overview.md`: visão geral do projeto e requisitos.
  - `02_modelagem.md`: descrição das entidades e do modelo de dados.
  - `03_objetos_consumo.md`: lista de Views, Functions e Stored Procedures que a API irá expor.

- **src/db/**
  - Contém todos os scripts SQL de criação e manutenção do banco.
  - Inclui arquivos para execução local em um servidor **Microsoft SQL Server**. Conexões futuras com a nuvem Google deverão ser configuradas aqui.

- **src/api/**
  - Diretório reservado para a implementação da API que conectará o banco ao frontend.

- **src/test/**
  - Scripts `pytest` que validam a execução dos scripts SQL. Defina a variável de ambiente `BOTECOPRO_DB_DSN` para apontar para a instância de testes.

### Variáveis de Ambiente

Copie o arquivo `.env.example` para `.env` e ajuste a string de conexão `BOTECOPRO_DB_DSN` conforme sua instalação do SQL Server.


### Banco de Dados

Os scripts SQL foram preparados para Microsoft SQL Server e podem ser executados no **SQL Server Management Studio** localmente. A API deverá acessar este banco através de `localhost`. Em um próximo estágio poderemos publicar o banco na Google Cloud para acesso remoto.
