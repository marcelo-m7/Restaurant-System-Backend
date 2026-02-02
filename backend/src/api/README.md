# Boteco Pro API

Esta pasta contém a implementação da API em **FastAPI** que serve de ponte entre o
banco de dados MSSQL e o frontend React.

## Instalação

```bash
pip install -r requirements.txt
```

A API depende da variável de ambiente `BOTECOPRO_DB_DSN` com a string de conexão
ODBC para o SQL Server.

## Execução em desenvolvimento

```bash
uvicorn app:app --reload
```

## Funcionamento

Ao iniciar, a aplicação consulta o banco para listar todas as **Views** e cria
automaticamente rotas de leitura baseadas no nome de cada view. Por exemplo,
`view_mesas_disponiveis` torna-se:

```
GET /mesas/disponiveis
```

Também há um endpoint genérico para execução de Stored Procedures:

```
POST /exec/{nome_da_procedure}
```

O corpo da requisição deve conter um JSON com os parâmetros necessários. O
resultado retornado pelo banco é entregue em JSON.
