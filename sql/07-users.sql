-- Criar usuário administrador com todas as permissões
CREATE ROLE admin_academia WITH
    LOGIN  -- Permite login
    PASSWORD 'adminIFC'  -- Define a senha do usuário
    CREATEDB  -- Permite criar bancos de dados
    CREATEROLE;  -- Permite criar novos roles

-- Conceder todas as permissões nas tabelas
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_academia;  -- Concede todas as permissões em todas as tabelas
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin_academia;  -- Concede todas as permissões em todas as sequências

-- Conceder permissão de execução em todas as funções
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO admin_academia;  -- Concede permissão de execução em todas as funções

-- Criar usuário instrutor com permissões limitadas
CREATE ROLE instrutor_academia WITH
    LOGIN  -- Permite login
    PASSWORD 'instrutorIFC'  -- Define a senha do usuário
    NOINHERIT;  -- Não herda permissões de outros roles

-- Permissões específicas para instrutores
GRANT SELECT ON TABLE EMPREGADO TO instrutor_academia;  -- Permite selecionar dados da tabela EMPREGADO
GRANT SELECT, INSERT ON TABLE FREQUENTAM TO instrutor_academia;  -- Permite selecionar e inserir dados na tabela FREQUENTAM
GRANT SELECT ON TABLE PLANO_ALUNO TO instrutor_academia;  -- Permite selecionar dados da tabela PLANO_ALUNO
GRANT SELECT, UPDATE ON TABLE AULA TO instrutor_academia;  -- Permite selecionar e atualizar dados na tabela AULA
GRANT SELECT ON TABLE DEPARTAMENTO TO instrutor_academia;  -- Permite selecionar dados da tabela DEPARTAMENTO
GRANT SELECT ON TABLE EQUIPAMENTO TO instrutor_academia;  -- Permite selecionar dados da tabela EQUIPAMENTO

-- Revogar acesso a informações sensíveis do instrutor
REVOKE SELECT (cpf, salario, data_contratacao) ON TABLE EMPREGADO FROM instrutor_academia;  -- Revoga permissão de selecionar campos sensíveis da tabela EMPREGADO
REVOKE SELECT, INSERT, DELETE ON TABLE EMPREGADO FROM instrutor_academia;  -- Revoga permissão de selecionar, inserir e deletar dados na tabela EMPREGADO
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM instrutor_academia;  -- Revoga todas as permissões em todas as tabelas