-- Stored Procedure 1: Cadastro de Novo Aluno
-- Esta SP realiza todo o processo de matrícula de um novo aluno na academia
CREATE OR REPLACE PROCEDURE sp_cadastrar_aluno(
    p_nome VARCHAR(100),         -- Nome completo do aluno
    p_cpf VARCHAR(11),          -- CPF do aluno (apenas números)
    p_endereco VARCHAR(200),    -- Endereço completo
    p_telefone VARCHAR(20),     -- Telefone com DDD
    p_tipo_plano VARCHAR(200),  -- Descrição do plano escolhido
    p_duracao INTEGER,         -- Duração em dias do plano
    p_preco NUMERIC(20,2),     -- Valor do plano
    p_id_admin INTEGER         -- ID do administrador responsável
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_plano INTEGER;        -- Variável para armazenar o ID do plano gerado
    v_id_aluno INTEGER;        -- Variável para armazenar o ID do aluno gerado
BEGIN
    -- Insere os dados do aluno e do plano
    INSERT INTO PLANO_ALUNO(
        nome, cpf, endereco, telefone,
        descricao, duracao, preco,
        id_administrador, status
    )
    VALUES (
        p_nome, p_cpf, p_endereco, p_telefone,
        p_tipo_plano, p_duracao, p_preco,
        p_id_admin, 'ativo'
    )
    RETURNING id_plano, id_aluno INTO v_id_plano, v_id_aluno;  -- Retorna os IDs gerados
    
    -- Registra o pagamento inicial da matrícula
    INSERT INTO PAGAMENTO(
        tipo_pagamento, valor, id_plano, id_aluno
    )
    VALUES (
        'Matrícula', p_preco, v_id_plano, v_id_aluno
    );
    
    COMMIT;                    -- Confirma a transação
END;
$$;

-- Stored Procedure 2 : Registro de Frequência em Aulas
CREATE OR REPLACE PROCEDURE sp_registrar_frequencia(
    p_cpf_aluno VARCHAR(11),   -- CPF do aluno que participará da aula
    p_id_aula INTEGER         -- ID da aula que será frequentada
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_plano INTEGER;        -- Armazena o ID do plano do aluno
    v_id_aluno INTEGER;        -- Armazena o ID do aluno
    v_capacidade INTEGER;      -- Armazena a capacidade máxima da aula
    v_ocupacao INTEGER;        -- Armazena o número atual de alunos na aula
BEGIN
    -- Busca os dados do aluno
    SELECT id_plano, id_aluno 
    INTO v_id_plano, v_id_aluno
    FROM PLANO_ALUNO 
    WHERE cpf = p_cpf_aluno AND status = 'ativo';
    
    -- Verifica a capacidade da aula
    SELECT capacidade_maxima, 
           (SELECT COUNT(*) FROM FREQUENTAM WHERE id_aula = p_id_aula)
    INTO v_capacidade, v_ocupacao
    FROM AULA 
    WHERE id_aula = p_id_aula;
    
    -- Verifica se há vagas disponíveis
    IF v_ocupacao >= v_capacidade THEN
        RAISE EXCEPTION 'Aula está com capacidade máxima atingida';
    END IF;
    
    -- Registra a frequência do aluno
    INSERT INTO FREQUENTAM(id_plano, id_aluno, id_aula)
    VALUES (v_id_plano, v_id_aluno, p_id_aula);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN   -- Tratamento de erro quando aluno não é encontrado
        RAISE EXCEPTION 'Aluno não encontrado ou plano inativo';
END;
$$;


-- Stored Procedure 3: Relatório de Frequência por Aluno
CREATE OR REPLACE PROCEDURE sp_relatorio_frequencia_aluno(
    p_cpf_aluno VARCHAR(11)    -- CPF do aluno para buscar frequência
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_nome_aluno VARCHAR(100);  -- Armazena nome do aluno
    v_total_aulas INTEGER;      -- Contador de aulas frequentadas
BEGIN
    -- Busca nome do aluno
    SELECT nome INTO v_nome_aluno
    FROM PLANO_ALUNO 
    WHERE cpf = p_cpf_aluno AND status = 'ativo';
    
    -- Conta total de aulas frequentadas
    SELECT COUNT(*) INTO v_total_aulas
    FROM FREQUENTAM f
    JOIN PLANO_ALUNO pa ON f.id_plano = pa.id_plano 
    WHERE pa.cpf = p_cpf_aluno;
    
    -- Exibe o relatório
    RAISE NOTICE 'Relatório de Frequência';
    RAISE NOTICE 'Aluno: %', v_nome_aluno;
    RAISE NOTICE 'Total de aulas frequentadas: %', v_total_aulas;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE EXCEPTION 'Aluno não encontrado ou inativo';
END;
$$
;



-- Teste da SP1: Cadastrar novo aluno
CALL sp_cadastrar_aluno(
    'João Silva',  -- Nome do aluno
    '12345678901',  -- CPF do aluno
    'Rua Exemplo, 123',  -- Endereço do aluno
    '48999999999',  -- Telefone do aluno
    'Plano Mensal',  -- Tipo de plano escolhido
    30,  -- Duração do plano em dias
    99.90,  -- Preço do plano
    1  -- ID do administrador responsável
);

-- Teste da SP2 
CALL sp_registrar_frequencia('12345678901', 1);  -- CPF do aluno e ID da aula


-- Teste da SP3
CALL sp_relatorio_frequencia_aluno('12345678901');  -- CPF do aluno para gerar relatório