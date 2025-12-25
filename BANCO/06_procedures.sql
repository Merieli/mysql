SET GLOBAL log_bin_trust_function_creators = 1;

USE `sucos_vendas`;
DROP FUNCTION IF EXISTS `f_numero_aleatorio`;

DELIMITER $$
CREATE FUNCTION `f_numero_aleatorio` (min INTEGER, max INTEGER)
RETURNS INTEGER
READS SQL DATA
BEGIN
    DECLARE vRetorno INTEGER;
    SELECT FLOOR((RAND() * (max - min + 1)) + min) INTO vRetorno;
    RETURN vRetorno;
END$$

DELIMITER ;

USE `sucos_vendas`;
DROP FUNCTION IF EXISTS `f_cliente_aleatorio`;

DELIMITER $$
CREATE FUNCTION `f_cliente_aleatorio`() RETURNS varchar(11) CHARSET utf8mb4
BEGIN
    DECLARE vRetorno VARCHAR(11);
    DECLARE num_max_tabela INT;
    DECLARE num_aleatorio INT;
    SELECT COUNT(*) INTO num_max_tabela FROM tabela_de_clientes;
    SET num_aleatorio = f_numero_aleatorio(1, num_max_tabela);
    SET num_aleatorio = num_aleatorio - 1;
    SELECT CPF INTO vRetorno FROM tabela_de_clientes
    LIMIT num_aleatorio, 1;
RETURN vRetorno;
END$$

DELIMITER ;

DROP FUNCTION IF EXISTS `f_produto_aleatorio`;

DELIMITER $$
CREATE FUNCTION `f_produto_aleatorio`() RETURNS varchar(10) CHARSET utf8mb4
BEGIN
    DECLARE vRetorno VARCHAR(10);
    DECLARE num_max_tabela INT;
    DECLARE num_aleatorio INT;
    SELECT COUNT(*) INTO num_max_tabela FROM tabela_de_produtos;
    SET num_aleatorio = f_numero_aleatorio(1, num_max_tabela);
    SET num_aleatorio = num_aleatorio - 1;
    SELECT CODIGO_DO_PRODUTO INTO vRetorno FROM tabela_de_produtos
    LIMIT num_aleatorio, 1;
RETURN vRetorno;
END$$

DELIMITER ;

DROP FUNCTION IF EXISTS `f_vendedor_aleatorio`;

DELIMITER $$
CREATE FUNCTION `f_vendedor_aleatorio`() RETURNS varchar(5) CHARSET utf8mb4
BEGIN
    DECLARE vRetorno VARCHAR(5);
    DECLARE num_max_tabela INT;
    DECLARE num_aleatorio INT;
    SELECT COUNT(*) INTO num_max_tabela FROM tabela_de_vendedores;
    SET num_aleatorio = f_numero_aleatorio(1, num_max_tabela);
    SET num_aleatorio = num_aleatorio - 1;
    SELECT MATRICULA INTO vRetorno FROM tabela_de_vendedores
    LIMIT num_aleatorio, 1;
RETURN vRetorno;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS `p_inserir_venda`;

DELIMITER $$

CREATE PROCEDURE `p_inserir_venda`(vData DATE, max_itens INT, 
max_quantidade INT)
BEGIN
DECLARE vCliente VARCHAR(11);
DECLARE vProduto VARCHAR(10);
DECLARE vVendedor VARCHAR(5);
DECLARE vQuantidade INT;
DECLARE vPreco FLOAT;
DECLARE vItens INT;
DECLARE vNumeroNota INT;
DECLARE vContador INT DEFAULT 1;
DECLARE vNumItensNota INT;
SELECT MAX(numero) + 1 INTO vNumeroNota from notas_fiscais;
SET vCliente = f_cliente_aleatorio();
SET vVendedor = f_vendedor_aleatorio();
INSERT INTO notas_fiscais (CPF, MATRICULA, DATA_VENDA, NUMERO, IMPOSTO)
VALUES (vCliente, vVendedor, vData, vNumeroNota, 0.18);
SET vItens = f_numero_aleatorio(1, max_itens);
WHILE vContador <= vItens
DO
   SET vProduto = f_produto_aleatorio();
   SELECT COUNT(*) INTO vNumItensNota FROM itens_notas_fiscais
   WHERE NUMERO = vNumeroNota AND CODIGO_DO_PRODUTO = vProduto;
   IF vNumItensNota = 0 THEN
      SET vQuantidade = f_numero_aleatorio(10, max_quantidade);
      SELECT PRECO_DE_LISTA INTO vPreco FROM tabela_de_produtos 
      WHERE CODIGO_DO_PRODUTO = vProduto;
      INSERT INTO itens_notas_fiscais (NUMERO, CODIGO_DO_PRODUTO, 
      QUANTIDADE, PRECO) VALUES (vNumeroNota, vProduto, vQuantidade, vPreco);
   END IF;
   SET vContador = vContador + 1;
END WHILE;
END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS `p_simular_vendas_periodo`;

DELIMITER $$

CREATE PROCEDURE `p_simular_vendas_periodo`(
    vDataInicial DATE,
    vDataFinal DATE,
    min_itens INT,
    max_itens INT,
    max_quantidade INT,
    max_vendas_dia INT
)
BEGIN
    DECLARE vData DATE;
    DECLARE vItens INT;
    DECLARE i INT;

    SET vData = vDataInicial;
    WHILE vData <= vDataFinal DO
        SET vItens = f_numero_aleatorio(min_itens, max_itens); -- Obtém o número aleatório de itens a serem inseridos

        SET i = 1;
        WHILE i <= vItens AND i <= max_vendas_dia DO -- Segundo loop até o menor entre vItens e max_vendas_dia
            CALL p_inserir_venda(vData, max_itens, max_quantidade); -- Chama a procedure de inserção de venda
            SET i = i + 1;
        END WHILE;

        SET vData = DATE_ADD(vData, INTERVAL 1 DAY); -- Avança para o próximo dia
    END WHILE;
END$$

DELIMITER ;









