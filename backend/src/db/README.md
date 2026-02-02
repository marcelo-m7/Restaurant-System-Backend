# Boteco Pro DB Utilities

Este diretório contém ferramentas para gerenciar o banco de dados do Boteco Pro.

## Variável de Ambiente

Antes de executar qualquer comando, defina a string de conexão ODBC na variável
`BOTECOPRO_DB_DSN`.

## Executar Scripts SQL

```bash
python service.py run
```

Executa todos os arquivos `.sql` em ordem alfabética da pasta `sql/`.

## Testar Conectividade

```bash
python service.py test
```

Conecta ao servidor Microsoft SQL Server e imprime a versão retornada.

Estes comandos funcionam tanto para uma instância local quanto para uma Google
Cloud SQL, desde que a conexão esteja configurada corretamente no DSN.
