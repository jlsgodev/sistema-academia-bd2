-- Function 1: Calcular total faturado por período
-- Parâmetros de entrada:
--   data_inicio: data inicial do período
--   data_fim: data final do período
-- Retorno: valor total faturado no período
CREATE OR REPLACE FUNCTION fn_calcular_faturamento(
    data_inicio DATE,  -- Data inicial do período
    data_fim DATE  -- Data final do período
) 
RETURNS NUMERIC(20,2)  -- Retorna o valor total faturado no período
LANGUAGE plpgsql
AS $$
DECLARE
    total_faturado NUMERIC(20,2);  -- Variável para armazenar o total faturado
BEGIN
    -- Calcula o total faturado no período especificado
    SELECT COALESCE(SUM(valor), 0)
    INTO total_faturado
    FROM PAGAMENTO
    WHERE data_pagamento BETWEEN data_inicio AND data_fim;
    
    RETURN total_faturado;  -- Retorna o total faturado
END;
$$
;

-- Function 2: Verificar disponibilidade de vaga em aula
-- Parâmetros de entrada:
--   p_id_aula: ID da aula a ser verificada
-- Retorno: boolean (true se há vagas, false se não há)
CREATE OR REPLACE FUNCTION fn_verificar_disponibilidade_aula(
    p_id_aula INTEGER  -- ID da aula a ser verificada
) 
RETURNS BOOLEAN  -- Retorna true se há vagas disponíveis, false caso contrário
LANGUAGE plpgsql
AS $$
DECLARE
    v_capacidade INTEGER;  -- Variável para armazenar a capacidade máxima da aula
    v_ocupacao INTEGER;  -- Variável para armazenar o número atual de alunos na aula
BEGIN
    -- Busca capacidade máxima da aula
    SELECT capacidade_maxima
    INTO v_capacidade
    FROM AULA
    WHERE id_aula = p_id_aula;
    
    -- Conta alunos matriculados
    SELECT COUNT(*)
    INTO v_ocupacao
    FROM FREQUENTAM
    WHERE id_aula = p_id_aula;
    
    -- Retorna true se há vagas disponíveis
    RETURN v_ocupacao < v_capacidade;
END;
$$
;

-- Function 3: Calcular idade do aluno
-- Parâmetros de entrada:
--   p_cpf: CPF do aluno
-- Retorno: idade em anos
CREATE OR REPLACE FUNCTION fn_calcular_idade_aluno(
    p_cpf VARCHAR(11)  -- CPF do aluno
) 
RETURNS INTEGER  -- Retorna a idade em anos
LANGUAGE plpgsql
AS $$
DECLARE
    v_data_nascimento DATE;  -- Variável para armazenar a data de nascimento do aluno
BEGIN
    -- Busca a data de nascimento do aluno na tabela EMPREGADO
    SELECT data_nascimento
    INTO v_data_nascimento
    FROM EMPREGADO
    WHERE cpf = p_cpf;
    
    -- Calcula e retorna a idade do aluno em anos
    RETURN EXTRACT(YEAR FROM age(current_date, v_data_nascimento));
END;
$$
;

-- Teste Function 1: Calcular faturamento
SELECT fn_calcular_faturamento('2024-01-01', '2024-12-31') as faturamento_anual;  -- Calcula o faturamento anual para o ano de 2024

-- Teste Function 2: Verificar disponibilidade
SELECT fn_verificar_disponibilidade_aula(1) as tem_vaga_disponivel;  -- Verifica se há vagas disponíveis para a aula com ID 1

-- Teste Function 3: Calcular idade
SELECT fn_calcular_idade_aluno('12345678901') as idade_aluno;  -- Calcula a idade do aluno com o CPF '12345678901'