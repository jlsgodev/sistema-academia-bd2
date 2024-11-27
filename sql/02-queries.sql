-- Consulta 1: Aulas e seus Instrutores por Departamento
SELECT a.nome_aula, a.data_hora, e.nome as instrutor, d.nome as departamento
FROM AULA a
INNER JOIN EMPREGADO e ON a.id_instrutor = e.id_empregado  -- Junta a tabela AULA com EMPREGADO para obter o nome do instrutor
INNER JOIN DEPARTAMENTO d ON a.id_departamento = d.id_departamento  -- Junta a tabela AULA com DEPARTAMENTO para obter o nome do departamento
ORDER BY a.data_hora;  -- Ordena os resultados pela data e hora da aula

-- Consulta 2: Pagamentos de Alunos Ativos
SELECT pa.nome as aluno, pa.cpf, p.tipo_pagamento, p.valor, p.data_pagamento
FROM PLANO_ALUNO pa
LEFT JOIN PAGAMENTO p ON pa.id_plano = p.id_plano AND pa.id_aluno = p.id_aluno  -- Junta a tabela PLANO_ALUNO com PAGAMENTO para obter os pagamentos dos alunos
WHERE pa.status = 'ativo'  -- Filtra apenas os alunos com plano ativo
ORDER BY p.data_pagamento DESC;  -- Ordena os resultados pela data de pagamento em ordem decrescente

-- Consulta 3: Equipamentos por Departamento e Fornecedor
SELECT d.nome as departamento, 
       e.nome as equipamento, 
       f.cnpj as fornecedor_cnpj
FROM EQUIPAMENTO e
JOIN DEPARTAMENTO d ON e.id_departamento = d.id_departamento  -- Junta a tabela EQUIPAMENTO com DEPARTAMENTO para obter o nome do departamento
JOIN FORNECEDOR f ON e.id_fornecedor = f.id_fornecedor  -- Junta a tabela EQUIPAMENTO com FORNECEDOR para obter o CNPJ do fornecedor
ORDER BY d.nome;  -- Ordena os resultados pelo nome do departamento

-- Consulta 4: Total de Aulas por Instrutor
SELECT e.nome, e.cpf,
       (SELECT COUNT(*) 
        FROM MINISTRAM m 
        WHERE m.id_instrutor = e.id_empregado) as total_aulas  -- Subconsulta para contar o total de aulas ministradas por cada instrutor
FROM EMPREGADO e
WHERE e.cargo = 'Instrutor'  -- Filtra apenas os empregados com cargo de instrutor
ORDER BY total_aulas DESC;  -- Ordena os resultados pelo total de aulas em ordem decrescente

-- Consulta 5: Estatísticas por Departamento
SELECT d.nome as departamento,
       COUNT(DISTINCT a.id_aula) as total_aulas,  -- Conta o total de aulas distintas por departamento
       COUNT(DISTINCT f.id_aluno) as total_alunos,  -- Conta o total de alunos distintos por departamento
       AVG(a.capacidade_maxima) as media_capacidade  -- Calcula a média da capacidade máxima das aulas por departamento
FROM DEPARTAMENTO d
LEFT JOIN AULA a ON d.id_departamento = a.id_departamento  -- Junta a tabela DEPARTAMENTO com AULA para obter as aulas por departamento
LEFT JOIN FREQUENTAM f ON a.id_aula = f.id_aula  -- Junta a tabela AULA com FREQUENTAM para obter os alunos por aula
GROUP BY d.nome  -- Agrupa os resultados pelo nome do departamento
ORDER BY total_alunos DESC;  -- Ordena os resultados pelo total de alunos em ordem decrescente