# Testes de Implementação do Banco de Dados

Esta pasta contém testes automatizados para validar a criação das tabelas e objetos presentes nos scripts SQL do Boteco Pro.

Os testes utilizam **pytest** e **pyodbc** para executar os scripts em uma instância SQL Server definida via variável de ambiente `BOTECOPRO_DB_DSN` (string de conexão ODBC).

Se a variável não estiver configurada, os testes serão automaticamente ignorados.

## Executando

1. Instale as dependências:
   ```bash
   pip install -r requirements.txt
   ```
2. Defina a variável `BOTECOPRO_DB_DSN` apontando para a instância de testes.
3. Execute:
   ```bash
   pytest -q
   ```

## Para uso de SQL Server no Cloud SQL (https://cloud.google.com/sdk/docs/install?hl=pt-br):

gcloud init
gcloud auth application-default login
cloud-sql-proxy boteco-pro:us-central1:botecopro --port=1433

Server Passa a ser 127.0.0.1:1433