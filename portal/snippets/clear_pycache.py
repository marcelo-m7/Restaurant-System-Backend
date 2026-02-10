#!/usr/bin/env python3
"""Remove recursivamente diretórios `__pycache__` sob um caminho raiz.

Uso:
  python snippets/clear_pycache.py --path . [--yes] [--verbose]

Por padrão o script faz um "dry-run" e apenas lista os diretórios encontrados.
Passe `--yes` para efetuar a remoção.
"""
import argparse
import os
import shutil
import sys


def find_pycache(root):
    matches = []
    for dirpath, dirnames, _ in os.walk(root):
        for d in list(dirnames):
            if d == "__pycache__":
                matches.append(os.path.join(dirpath, d))
    return matches


def delete_paths(paths, verbose=False):
    for p in paths:
        if verbose:
            print(f"Deleting: {p}")
        shutil.rmtree(p)


def main():
    parser = argparse.ArgumentParser(description="Limpa diretórios __pycache__ recursivamente.")
    parser.add_argument("--path", "-p", default=".", help="Caminho raiz para buscar (padrão: .)")
    parser.add_argument("--yes", "-y", action="store_true", help="Efetua a remoção. Sem esta flag, é apenas um dry-run.")
    parser.add_argument("--verbose", "-v", action="store_true", help="Mostra cada diretório enquanto deleta.")
    args = parser.parse_args()

    root = os.path.abspath(args.path)
    if not os.path.exists(root):
        print(f"Caminho não existe: {root}")
        return 2

    matches = find_pycache(root)

    if not matches:
        print(f"Nenhum diretório __pycache__ encontrado em: {root}")
        return 0

    print(f"Encontrados {len(matches)} diretórios __pycache__ em: {root}")
    for m in matches:
        print(" -", m)

    if not args.yes:
        print("\nDry-run: nenhum diretório será removido. Rode com --yes para remover.")
        return 0

    try:
        delete_paths(matches, verbose=args.verbose)
    except Exception as exc:
        print(f"Erro ao deletar: {exc}", file=sys.stderr)
        return 1

    print("Remoção concluída.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
