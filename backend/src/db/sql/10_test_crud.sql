USE botecopro_db;
GO

-- =========================================================================
-- Script: 09_testes_crud.sql
-- Objetivo: Testar CRUD via Stored Procedures da API Boteco Pro
-- =========================================================================

/* =========================================================================
   INSTRUÇÕES
   ----------
   Execute este script após ter carregado todos os objetos (tabelas, SPs, etc.).
   Cada seção testa uma entidade diferente via suas SPs de CRUD.
   Remova/Comente os GO internos conforme indicado para evitar perda de variáveis.
   ========================================================================= */

----------------------------------------
-- 1. Teste CRUD de Cliente
----------------------------------------
PRINT '--- TESTE CRUD: CLIENTE ---';

-- 1.1. Cadastrar novo cliente
DECLARE @cliente_id INT;
EXEC sp_cadastrar_cliente
    @nome = 'Teste Cliente',
    @telefone = '912345000',
    @email = 'teste.cliente@exemplo.com',
    @morada = 'Rua Teste, 1',
    @cidade = 'Lisboa',
    @codigo_postal = '1000-000',
    @contribuinte = '111222333';
SELECT @cliente_id = SCOPE_IDENTITY();
PRINT 'Novo cliente_id: ' + CAST(@cliente_id AS VARCHAR(10));

-- 1.2. Atualizar cliente existente
EXEC sp_atualizar_cliente
    @cliente_id = @cliente_id,
    @nome = 'Teste Cliente Alterado',
    @telefone = '919999000',
    @email = 'cliente.alterado@exemplo.com',
    @morada = 'Rua Teste, 2',
    @cidade = 'Porto',
    @codigo_postal = '4000-000',
    @contribuinte = '444555666';
PRINT 'Cliente atualizado com sucesso.';

-- 1.3. Tentar atualizar cliente inexistente (deve falhar)
BEGIN TRY
    EXEC sp_atualizar_cliente
        @cliente_id = 9999,
        @nome = 'Inexistente';
END TRY
BEGIN CATCH
    PRINT 'Erro esperado: ' + ERROR_MESSAGE();
END CATCH;

GO


----------------------------------------
-- 2. Teste CRUD de Mesa
----------------------------------------
PRINT '--- TESTE CRUD: MESA ---';

-- 2.1. Cadastrar nova mesa
DECLARE @mesa_id INT;
EXEC sp_cadastrar_mesa
    @numero = 10,
    @capacidade = 4;
SELECT @mesa_id = SCOPE_IDENTITY();
PRINT 'Novo mesa_id: ' + CAST(@mesa_id AS VARCHAR(10));

-- 2.2. Atualizar mesa existente
EXEC sp_atualizar_mesa
    @mesa_id = @mesa_id,
    @numero = 11,
    @capacidade = 6,
    @status = 'reservada';
PRINT 'Mesa atualizada com sucesso.';

-- 2.3. Tentar cadastrar mesa duplicada (mesmo número)
BEGIN TRY
    EXEC sp_cadastrar_mesa
        @numero = 11,
        @capacidade = 2;
END TRY
BEGIN CATCH
    PRINT 'Erro esperado: ' + ERROR_MESSAGE();
END CATCH;

GO


----------------------------------------
-- 3. Teste CRUD de Carreira
----------------------------------------
PRINT '--- TESTE CRUD: CARREIRA ---';

-- 3.1. Cadastrar nova carreira
DECLARE @carreira_id INT;
EXEC sp_cadastrar_carreira
    @nome = 'Testador',
    @salario_mensal = 1500.00;
SELECT @carreira_id = SCOPE_IDENTITY();
PRINT 'Novo carreira_id: ' + CAST(@carreira_id AS VARCHAR(10));

-- 3.2. Atualizar carreira existente
EXEC sp_atualizar_carreira
    @carreira_id = @carreira_id,
    @nome = 'Testador Sênior',
    @salario_mensal = 1800.00;
PRINT 'Carreira atualizada com sucesso.';

-- 3.3. Tentar atualizar carreira inexistente
BEGIN TRY
    EXEC sp_atualizar_carreira
        @carreira_id = 9999,
        @nome = 'Inválida';
END TRY
BEGIN CATCH
    PRINT 'Erro esperado: ' + ERROR_MESSAGE();
END CATCH;

GO


----------------------------------------
-- 4. Teste CRUD de Funcionário
----------------------------------------
PRINT '--- TESTE CRUD: FUNCIONÁRIO ---';

-- 4.1. Cadastrar novo funcionário
DECLARE @funcionario_id INT;
EXEC sp_cadastrar_funcionario
    @nome = 'Teste Funcionario',
    @data_nascimento = '1995-10-10',
    @telefone = '913333000',
    @email = 'funcionario.teste@exemplo.com',
    @cargo = 'Testador',
    @carreira_id = @carreira_id,
    @data_admissao = '2025-05-01';
SELECT @funcionario_id = SCOPE_IDENTITY();
PRINT 'Novo funcionario_id: ' + CAST(@funcionario_id AS VARCHAR(10));

-- 4.2. Atualizar funcionário existente
EXEC sp_atualizar_funcionario
    @funcionario_id = @funcionario_id,
    @nome = 'Teste Funcionario Alterado',
    @email = 'funcionario.alt@exemplo.com';
PRINT 'Funcionário atualizado com sucesso.';

-- 4.3. Tentar cadastrar funcionário com carreira inválida
BEGIN TRY
    EXEC sp_cadastrar_funcionario
        @nome = 'Invalido',
        @data_nascimento = '1990-01-01',
        @cargo = 'Testador',
        @carreira_id = 9999,
        @data_admissao = '2025-05-01';
END TRY
BEGIN CATCH
    PRINT 'Erro esperado: ' + ERROR_MESSAGE();
END CATCH;

GO


----------------------------------------
-- 5. Teste CRUD de Fornecedor
----------------------------------------
PRINT '--- TESTE CRUD: FORNECEDOR ---';

-- 5.1. Cadastrar novo fornecedor
DECLARE @fornecedor_id INT;
EXEC sp_cadastrar_fornecedor
    @nome = 'Fornecedor Teste',
    @telefone = '918888000',
    @email = 'fornecedor.teste@exemplo.com',
    @endereco = 'Rua Fornecedor, 5',
    @cidade = 'Coimbra',
    @codigo_postal = '3000-000',
    @pais = 'Portugal';
SELECT @fornecedor_id = SCOPE_IDENTITY();
PRINT 'Novo fornecedor_id: ' + CAST(@fornecedor_id AS VARCHAR(10));

-- 5.2. Atualizar fornecedor existente
EXEC sp_atualizar_fornecedor
    @fornecedor_id = @fornecedor_id,
    @telefone = '919111000',
    @cidade = 'Faro';
PRINT 'Fornecedor atualizado com sucesso.';

-- 5.3. Tentar atualizar fornecedor inexistente
BEGIN TRY
    EXEC sp_atualizar_fornecedor
        @fornecedor_id = 9999,
        @nome = 'Inexistente';
END TRY
BEGIN CATCH
    PRINT 'Erro esperado: ' + ERROR_MESSAGE();
END CATCH;

GO


----------------------------------------
-- 6. Teste CRUD de Produto
----------------------------------------
PRINT '--- TESTE CRUD: PRODUTO ---';

-- 6.1. Cadastrar novo produto
DECLARE @produto_id INT;
EXEC sp_cadastrar_produto
    @nome = 'Ingrediente Teste',
    @tipo = 'ingrediente',
    @custo_unitario = 1.00,
    @preco_venda = 2.50,
    @stock_atual = 100,
    @stock_minimo = 10,
    @stock_encomenda = 50,
    @fornecedor_id = @fornecedor_id;
SELECT @produto_id = SCOPE_IDENTITY();
PRINT 'Novo produto_id: ' + CAST(@produto_id AS VARCHAR(10));

-- 6.2. Atualizar produto existente
EXEC sp_atualizar_produto
    @produto_id = @produto_id,
    @preco_venda = 3.00,
    @stock_minimo = 20;
PRINT 'Produto atualizado com sucesso.';

-- 6.3. Tentar cadastrar produto com fornecedor inválido
BEGIN TRY
    EXEC sp_cadastrar_produto
        @nome = 'Inválido',
        @tipo = 'ingrediente',
        @custo_unitario = 0.50,
        @preco_venda = 1.00,
        @stock_atual = 50,
        @stock_minimo = 5,
        @stock_encomenda = 20,
        @fornecedor_id = 9999;
END TRY
BEGIN CATCH
    PRINT 'Erro esperado: ' + ERROR_MESSAGE();
END CATCH;

GO


----------------------------------------
-- 7. Teste CRUD de Prato e PratoIngrediente
----------------------------------------
PRINT '--- TESTE CRUD: PRATO ---';

-- 7.1. Cadastrar novo prato
DECLARE @prato_id INT;
EXEC sp_cadastrar_prato
    @nome = 'Prato Teste',
    @categoria_id = 1,
    @descricao = 'Descrição teste',
    @tempo_preparo = 15,
    @preco_base = 5.00;
SELECT @prato_id = SCOPE_IDENTITY();
PRINT 'Novo prato_id: ' + CAST(@prato_id AS VARCHAR(10));

-- 7.2. Atualizar prato existente
EXEC sp_atualizar_prato
    @prato_id = @prato_id,
    @tempo_preparo = 20,
    @preco_base = 6.00;
PRINT 'Prato atualizado com sucesso.';

-- 7.3. Adicionar ingrediente ao prato
EXEC sp_cadastrar_prato_ingrediente
    @prato_id = @prato_id,
    @produto_id = @produto_id,
    @quantidade_necessaria = 0.050;  -- 50g
PRINT 'Ingrediente vinculado ao prato com sucesso.';

-- 7.4. Tentar adicionar ingrediente duplicado
BEGIN TRY
    EXEC sp_cadastrar_prato_ingrediente
        @prato_id = @prato_id,
        @produto_id = @produto_id,
        @quantidade_necessaria = 0.050;
END TRY
BEGIN CATCH
    PRINT 'Erro esperado: ' + ERROR_MESSAGE();
END CATCH;

-- 7.5. Remover ingrediente do prato
EXEC sp_remover_prato_ingrediente
    @prato_id = @prato_id,
    @produto_id = @produto_id;
PRINT 'Ingrediente removido do prato.';

-- 7.6. Tentar remover vínculo inexistente
BEGIN TRY
    EXEC sp_remover_prato_ingrediente
        @prato_id = @prato_id,
        @produto_id = @produto_id;
END TRY
BEGIN CATCH
    PRINT 'Erro esperado: ' + ERROR_MESSAGE();
END CATCH;

GO


----------------------------------------
-- 8. Teste CRUD de MenuEspecial e MenuEspecialPrato
----------------------------------------
PRINT '--- TESTE CRUD: MENU ESPECIAL ---';

-- 8.1. Cadastrar novo menu especial
DECLARE @menu_especial_id INT;
EXEC sp_cadastrar_menu_especial
    @nome = 'Menu Teste',
    @descricao = 'Descrição do menu teste',
    @data_inicio = '2025-07-01',
    @data_fim = '2025-07-05',
    @preco_total = 25.00;
SELECT @menu_especial_id = SCOPE_IDENTITY();
PRINT 'Novo menu_especial_id: ' + CAST(@menu_especial_id AS VARCHAR(10));

-- 8.2. Atualizar menu especial existente
EXEC sp_atualizar_menu_especial
    @menu_especial_id = @menu_especial_id,
    @preco_total = 30.00;
PRINT 'MenuEspecial atualizado com sucesso.';

-- 8.3. Vincular prato ao menu especial
EXEC sp_cadastrar_menu_especial_prato
    @menu_especial_id = @menu_especial_id,
    @prato_id = @prato_id,
    @ordem = 1;
PRINT 'Prato vinculado ao MenuEspecial com sucesso.';

-- 8.4. Tentar vincular prato duplicado
BEGIN TRY
    EXEC sp_cadastrar_menu_especial_prato
        @menu_especial_id = @menu_especial_id,
        @prato_id = @prato_id,
        @ordem = 2;
END TRY
BEGIN CATCH
    PRINT 'Erro esperado: ' + ERROR_MESSAGE();
END CATCH;

-- 8.5. Remover vínculo prato-menu
EXEC sp_remover_menu_especial_prato
    @menu_especial_id = @menu_especial_id,
    @prato_id = @prato_id;
PRINT 'Prato removido do MenuEspecial.';

-- 8.6. Tentar remover vínculo inexistente
BEGIN TRY
    EXEC sp_remover_menu_especial_prato
        @menu_especial_id = @menu_especial_id,
        @prato_id = @prato_id;
END TRY
BEGIN CATCH
    PRINT 'Erro esperado: ' + ERROR_MESSAGE();
END CATCH;

GO


----------------------------------------
-- 9. Teste CRUD de Reserva
----------------------------------------
PRINT '--- TESTE CRUD: RESERVA ---';

-- 9.1. Cadastrar nova reserva
DECLARE @reserva_id INT;
EXEC sp_cadastrar_reserva
    @cliente_id = @cliente_id,
    @mesa_id = @mesa_id,
    @data_reserva = '2025-08-01',
    @hora_reserva = '18:00',
    @quantidade_pessoas = 3;
SELECT @reserva_id = SCOPE_IDENTITY();
PRINT 'Novo reserva_id: ' + CAST(@reserva_id AS VARCHAR(10));

-- 9.2. Atualizar reserva existente
EXEC sp_atualizar_reserva
    @reserva_id = @reserva_id,
    @mesa_id = @mesa_id,
    @quantidade_pessoas = 4,
    @status = 'confirmada';
PRINT 'Reserva atualizada com sucesso.';

-- 9.3. Tentar atualizar reserva inexistente
BEGIN TRY
    EXEC sp_atualizar_reserva
        @reserva_id = 9999,
        @status = 'cancelada';
END TRY
BEGIN CATCH
    PRINT 'Erro esperado: ' + ERROR_MESSAGE();
END CATCH;

GO


----------------------------------------
-- 10. Teste CRUD de Pedido e PedidoItem
----------------------------------------
PRINT '--- TESTE CRUD: PEDIDO ---';

-- 10.1. Cadastrar novo pedido
DECLARE @novo_pedido_id INT;
EXEC sp_cadastrar_pedido
    @mesa_id = @mesa_id,
    @funcionario_id = @funcionario_id,
    @cliente_id = @cliente_id;
SELECT @novo_pedido_id = SCOPE_IDENTITY();
PRINT 'Novo pedido_id: ' + CAST(@novo_pedido_id AS VARCHAR(10));

-- 10.2. Adicionar item de prato ao pedido
EXEC sp_adicionar_item_pedido
    @pedido_id = @novo_pedido_id,
    @prato_id = @prato_id,
    @produto_id = NULL,
    @quantidade = 2,
    @preco_unitario = 6.00,
    @iva = 13.00;
PRINT 'Item de prato adicionado ao pedido.';

-- 10.3. Adicionar item de produto (bebida) ao pedido
EXEC sp_adicionar_item_pedido
    @pedido_id = @novo_pedido_id,
    @prato_id = NULL,
    @produto_id = 7,       -- produto_id 7 = 'Cerveja'
    @quantidade = 3,
    @preco_unitario = 2.50,
    @iva = 23.00;
PRINT 'Item de produto adicionado ao pedido.';

-- 10.4. Atualizar status do pedido para 'em_preparo'
EXEC sp_atualizar_status_pedido
    @pedido_id = @novo_pedido_id,
    @status = 'em_preparo';
PRINT 'Status do pedido atualizado para em_preparo.';

-- 10.5. Finalizar pedido (gera fatura via trigger)
EXEC sp_atualizar_status_pedido
    @pedido_id = @novo_pedido_id,
    @status = 'finalizado';
PRINT 'Pedido finalizado; fatura deve ter sido gerada automaticamente.';

-- 10.6. Tentar cancelar pedido já finalizado (não faz reversão)
BEGIN TRY
    EXEC sp_cancelar_pedido
        @pedido_id = @novo_pedido_id;
END TRY
BEGIN CATCH
    PRINT 'Erro esperado (pedido já finalizado): ' + ERROR_MESSAGE();
END CATCH;

-- 10.7. Cadastrar outro pedido para testar cancelamento antes de finalizar
DECLARE @pedido_cancelar_id INT;
EXEC sp_cadastrar_pedido
    @mesa_id = @mesa_id,
    @funcionario_id = @funcionario_id,
    @cliente_id = @cliente_id;
SELECT @pedido_cancelar_id = SCOPE_IDENTITY();
PRINT 'Novo pedido para cancelar: ' + CAST(@pedido_cancelar_id AS VARCHAR(10));

-- Adicionar item de prato
EXEC sp_adicionar_item_pedido
    @pedido_id = @pedido_cancelar_id,
    @prato_id = @prato_id,
    @produto_id = NULL,
    @quantidade = 1,
    @preco_unitario = 6.00,
    @iva = 13.00;
PRINT 'Item adicionado ao pedido de cancelamento.';

-- Cancelar pedido pendente (reverte estoque)
EXEC sp_cancelar_pedido
    @pedido_id = @pedido_cancelar_id;
PRINT 'Pedido cancelado e estoque revertido com sucesso.';

GO


----------------------------------------
-- 11. Teste CRUD de Encomenda e EncomendaItem
----------------------------------------
PRINT '--- TESTE CRUD: ENCOMENDA ---';

-- 11.1. Cadastrar nova encomenda
DECLARE @encomenda_id INT;
EXEC sp_cadastrar_encomenda
    @fornecedor_id = @fornecedor_id;
SELECT @encomenda_id = SCOPE_IDENTITY();
PRINT 'Novo encomenda_id: ' + CAST(@encomenda_id AS VARCHAR(10));

-- 11.2. Adicionar item à encomenda
EXEC sp_adicionar_item_encomenda
    @encomenda_id = @encomenda_id,
    @produto_id = @produto_id,
    @quantidade = 20,
    @preco_unitario = 1.00;
PRINT 'Item adicionado à encomenda.';

-- 11.3. Cancelar encomenda pendente
EXEC sp_cancelar_encomenda
    @encomenda_id = @encomenda_id;
PRINT 'Encomenda cancelada com sucesso.';

-- 11.4. Tentar adicionar item em encomenda cancelada
BEGIN TRY
    EXEC sp_adicionar_item_encomenda
        @encomenda_id = @encomenda_id,
        @produto_id = @produto_id,
        @quantidade = 10,
        @preco_unitario = 1.00;
END TRY
BEGIN CATCH
    PRINT 'Erro esperado (encomenda não pendente): ' + ERROR_MESSAGE();
END CATCH;

GO


----------------------------------------
-- 12. Teste CRUD de Registro de Horas
----------------------------------------
PRINT '--- TESTE CRUD: REGISTRO HORAS ---';

-- 12.1. Registrar horas para funcionário
DECLARE @registro_horas_id INT;
EXEC sp_registrar_horas
    @funcionario_id = @funcionario_id,
    @data_registro = '2025-06-01',
    @horas_normais = 8.00,
    @horas_extra = 2.00;
SELECT @registro_horas_id = SCOPE_IDENTITY();
PRINT 'Novo registro_horas_id: ' + CAST(@registro_horas_id AS VARCHAR(10));

-- 12.2. Atualizar registro de horas existente
EXEC sp_atualizar_registro_horas
    @registro_horas_id = @registro_horas_id,
    @horas_normais = 7.50,
    @horas_extra = 1.50;
PRINT 'Registro de horas atualizado com sucesso.';

-- 12.3. Tentar atualizar registro inexistente
BEGIN TRY
    EXEC sp_atualizar_registro_horas
        @registro_horas_id = 9999,
        @horas_normais = 5.00;
END TRY
BEGIN CATCH
    PRINT 'Erro esperado: ' + ERROR_MESSAGE();
END CATCH;

GO


----------------------------------------
-- 13. Teste CRUD de Fatura Manual
----------------------------------------
PRINT '--- TESTE CRUD: FATURA MANUAL ---';

-- 13.1. Cadastrar fatura manual para pedido cancelado (exemplo)
DECLARE @fatura_manual_id INT;
EXEC sp_cadastrar_fatura_manual
    @pedido_id = @pedido_cancelar_id,
    @cliente_id = @cliente_id,
    @nome_cliente = 'Cliente Manual',
    @morada_cliente = 'Rua Manual, 1',
    @cidade_cliente = 'Évora',
    @codigo_postal = '7000-000',
    @contribuinte = '777888999',
    @subtotal_comida = 5.00,
    @subtotal_bebida = 2.00,
    @iva_comida = 0.65,
    @iva_bebida = 0.46,
    @total = 8.11;
SELECT @fatura_manual_id = SCOPE_IDENTITY();
PRINT 'Novo fatura_manual_id: ' + CAST(@fatura_manual_id AS VARCHAR(10));

-- 13.2. Tentar cadastrar fatura para pedido inexistente
BEGIN TRY
    EXEC sp_cadastrar_fatura_manual
        @pedido_id = 9999,
        @subtotal_comida = 1.00,
        @subtotal_bebida = 0.50,
        @iva_comida = 0.13,
        @iva_bebida = 0.12,
        @total = 1.75;
END TRY
BEGIN CATCH
    PRINT 'Erro esperado: ' + ERROR_MESSAGE();
END CATCH;

GO

-- =========================================================================
-- FIM DOS TESTES CRUD
-- =========================================================================
