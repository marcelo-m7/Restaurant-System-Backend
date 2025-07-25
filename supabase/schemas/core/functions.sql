-- ============================================
-- core/functions.sql
-- ============================================

-- Por enquanto, nenhuma função RPC definida diretamente para o schema `core`.
-- Funções como `calculate_price(recipe_id, additions)` podem ser adicionadas futuramente.

-- Sugestão de exemplo (placeholder):
create or replace function core.get_recipe_cost(recipe_id integer)
returns numeric as $$
begin
  -- calcular custo total dos ingredientes da receita
end;
$$ language plpgsql;
