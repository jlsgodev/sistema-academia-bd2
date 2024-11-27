-- Criar tabela de log simplificada
-- Esta tabela armazena as alterações de valores dos planos dos alunos
CREATE TABLE log_alteracao_valores (
    id_log SERIAL PRIMARY KEY,  -- Identificador único do log
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Data e hora da alteração
    id_plano INTEGER,  -- ID do plano alterado
    id_aluno INTEGER,  -- ID do aluno cujo plano foi alterado
    valor_anterior dom_numeric_2_2,  -- Valor anterior do plano
    valor_novo dom_numeric_2_2,  -- Novo valor do plano
    usuario_alteracao VARCHAR(50)  -- Usuário que realizou a alteração
);

-- Nova função para a trigger
-- Esta função insere um registro na tabela de log quando o valor de um plano é alterado
CREATE OR REPLACE FUNCTION tf_registrar_alteracao_valor()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.preco IS DISTINCT FROM NEW.preco THEN  -- Verifica se o valor do plano foi alterado
        INSERT INTO log_alteracao_valores (
            id_plano,
            id_aluno,
            valor_anterior,
            valor_novo,
            usuario_alteracao
        )
        VALUES (
            OLD.id_plano,  -- ID do plano antes da alteração
            OLD.id_aluno,  -- ID do aluno antes da alteração
            OLD.preco,  -- Valor anterior do plano
            NEW.preco,  -- Novo valor do plano
            current_user  -- Usuário que realizou a alteração
        );
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

-- Nova trigger
-- Esta trigger chama a função tf_registrar_alteracao_valor após uma atualização na tabela PLANO_ALUNO
CREATE TRIGGER tg_registrar_alteracao_valor
AFTER UPDATE ON PLANO_ALUNO
FOR EACH ROW
EXECUTE FUNCTION tf_registrar_alteracao_valor();

-- Verificar preço atual do plano
-- Consulta para verificar o preço atual do plano de um aluno específico
SELECT id_plano, id_aluno, preco, status 
FROM PLANO_ALUNO 
WHERE id_plano = 1 AND id_aluno = 1;

-- Verificar se a tabela de log está vazia
-- Consulta para verificar se a tabela de log está vazia
SELECT * FROM log_alteracao_valores;

-- Atualizar o preço de um plano existente
-- Atualiza o preço de um plano específico para testar a trigger
UPDATE PLANO_ALUNO 
SET preco = 150.00 
WHERE id_plano = 1 AND id_aluno = 1;

-- Verificar se a alteração foi registrada no log
-- Consulta para verificar se a alteração foi registrada na tabela de log
SELECT * FROM log_alteracao_valores 
ORDER BY data_alteracao DESC;