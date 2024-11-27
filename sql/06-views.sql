-- View 1: Visão geral das aulas com detalhes
-- Esta view fornece informações completas sobre as aulas,
-- incluindo instrutor responsável e departamento
CREATE OR REPLACE VIEW vw_detalhes_aulas AS
SELECT 
    a.nome_aula,  -- Nome da aula
    a.data_hora,  -- Data e hora da aula
    a.duracao,  -- Duração da aula
    a.capacidade_maxima,  -- Capacidade máxima de alunos na aula
    e.nome as instrutor,  -- Nome do instrutor responsável
    d.nome as departamento,  -- Nome do departamento
    (SELECT COUNT(*) 
     FROM FREQUENTAM f 
     WHERE f.id_aula = a.id_aula) as alunos_matriculados  -- Número de alunos matriculados na aula
FROM AULA a
JOIN EMPREGADO e ON a.id_instrutor = e.id_empregado  -- Junta a tabela AULA com EMPREGADO para obter o nome do instrutor
JOIN DEPARTAMENTO d ON a.id_departamento = d.id_departamento;  -- Junta a tabela AULA com DEPARTAMENTO para obter o nome do departamento

-- View 2: Relatório financeiro de alunos
-- Esta view apresenta um resumo financeiro dos alunos,
-- incluindo planos e pagamentos realizados
CREATE OR REPLACE VIEW vw_financeiro_alunos AS
SELECT 
    pa.nome as aluno,  -- Nome do aluno
    pa.cpf,  -- CPF do aluno
    pa.descricao as plano,  -- Descrição do plano do aluno
    pa.preco as valor_plano,  -- Valor do plano do aluno
    pa.status,  -- Status do plano do aluno
    COUNT(p.id_pagamento) as total_pagamentos,  -- Total de pagamentos realizados pelo aluno
    SUM(p.valor) as total_pago  -- Valor total pago pelo aluno
FROM PLANO_ALUNO pa
LEFT JOIN PAGAMENTO p ON pa.id_plano = p.id_plano 
    AND pa.id_aluno = p.id_aluno  -- Junta a tabela PLANO_ALUNO com PAGAMENTO para obter os pagamentos dos alunos
GROUP BY pa.nome, pa.cpf, pa.descricao, pa.preco, pa.status;  -- Agrupa os resultados pelos dados do aluno

-- View 3: Status dos equipamentos por departamento
-- Esta view mostra a distribuição de equipamentos
-- entre os departamentos e seus fornecedores
CREATE OR REPLACE VIEW vw_equipamentos_departamento AS
SELECT 
    d.nome as departamento,  -- Nome do departamento
    e.nome as equipamento,  -- Nome do equipamento
    f.cnpj as fornecedor,  -- CNPJ do fornecedor do equipamento
    COUNT(e.id_equipamento) OVER (PARTITION BY d.id_departamento) as total_equipamentos  -- Total de equipamentos por departamento
FROM DEPARTAMENTO d
LEFT JOIN EQUIPAMENTO e ON d.id_departamento = e.id_departamento  -- Junta a tabela DEPARTAMENTO com EQUIPAMENTO para obter os equipamentos por departamento
LEFT JOIN FORNECEDOR f ON e.id_fornecedor = f.id_fornecedor;  -- Junta a tabela EQUIPAMENTO com FORNECEDOR para obter o CNPJ do fornecedor

-- Consultar detalhes das aulas
SELECT * FROM vw_detalhes_aulas;  -- Consulta a view vw_detalhes_aulas para obter detalhes das aulas

-- Consultar relatório financeiro
SELECT * FROM vw_financeiro_alunos;  -- Consulta a view vw_financeiro_alunos para obter o relatório financeiro dos alunos

-- Consultar equipamentos por departamento
SELECT * FROM vw_equipamentos_departamento;  -- Consulta a view vw_equipamentos_departamento para obter o status dos equipamentos por departamento