# Snippets

Este diretório contém utilitários pequenos para o projeto.

## svg_to_ico.py

- O que faz: procura recursivamente por `favicon.svg` e `placeholder.svg` dentro da pasta `assets`
  e gera arquivos `.ico` correspondentes.
- Requisitos: `cairosvg` e `Pillow`.

Instalação das dependências (PowerShell):

```powershell
pip install cairosvg pillow
```

Exemplos de uso (PowerShell):

```powershell
# Dry-run — mostra arquivos encontrados
python .\snippets\svg_to_ico.py --assets .\assets

# Gerar/atualizar .ico (sobrescreve se existir)
python .\snippets\svg_to_ico.py --assets .\assets --yes --verbose
```

Observações:
- O script tenta gerar um `.ico` com múltiplos tamanhos para melhor compatibilidade.
- Se preferir, chame o script apontando outra pasta de assets via `--assets`.
