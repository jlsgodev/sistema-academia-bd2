-- Definição de Domínios
-- Usamos domínios para garantir consistência e reutilização de tipos em várias tabelas.

CREATE DOMAIN dom_varchar_100 AS VARCHAR(100);  -- Nome de tamanho fixo para campos textuais
CREATE DOMAIN dom_varchar_200 AS VARCHAR(200);  -- Usado para endereços mais longos
CREATE DOMAIN dom_varchar_20 AS VARCHAR(20);    -- Para armazenar números de telefone
CREATE DOMAIN dom_varchar_11 AS VARCHAR(11);    -- Para armazenar CPF
CREATE DOMAIN dom_varchar_14 AS VARCHAR(14);    -- Para armazenar CNPJ
CREATE DOMAIN dom_varchar_50 AS VARCHAR(50);    -- Para tipo de pagamento e outros textos curtos
CREATE DOMAIN dom_numeric_2_2 AS NUMERIC(20, 2); -- Para valores monetários com 2 casas decimais
CREATE DOMAIN dom_date AS DATE;                 -- Para armazenar datas simples
CREATE DOMAIN dom_timestamp AS TIMESTAMP;       -- Para data e hora
CREATE DOMAIN dom_status AS VARCHAR(20) CHECK (VALUE IN ('ativo', 'inativo')); -- Controle de status

-- Tabela DEPARTAMENTO
-- Tabelas de referência a entidades simples e com dados não duplicados.

CREATE TABLE DEPARTAMENTO (
    id_departamento SERIAL PRIMARY KEY,  -- SERIAL para auto incremento
    nome dom_varchar_100 NOT NULL  -- Garantimos que o nome do departamento é obrigatório
);

-- Tabela CAPACITACAO
CREATE TABLE CAPACITACAO (
    id_capacitacao SERIAL PRIMARY KEY,  -- Auto incremento para ID
    cursos dom_varchar_100 NOT NULL  -- Campo obrigatório para o nome do curso
);

-- Tabela FORNECEDOR
-- Armazenamento de fornecedores, onde garantimos que o CNPJ seja único e não nulo.

CREATE TABLE FORNECEDOR (
    id_fornecedor SERIAL PRIMARY KEY,  -- SERIAL para auto incremento
    cnpj dom_varchar_14 UNIQUE NOT NULL,  -- CNPJ único, não pode ser nulo
    endereco dom_varchar_200 NOT NULL  -- Endereço obrigatório
);

-- Tabela EMPREGADO
-- Tabela com detalhes de funcionários, incluindo referências a outros empregados como administradores, zeladores e instrutores.

CREATE TABLE EMPREGADO (
    id_empregado SERIAL PRIMARY KEY,  -- Auto incremento
    nome dom_varchar_100 NOT NULL,  -- Nome obrigatório
    endereco dom_varchar_200,  -- Endereço opcional
    telefone dom_varchar_20,  -- Telefone opcional
    cargo dom_varchar_100,  -- Cargo do empregado
    data_nascimento dom_date,  -- Data de nascimento
    cpf dom_varchar_11 UNIQUE NOT NULL,  -- CPF único e obrigatório
    data_contratacao dom_date,  -- Data de contratação
    salario dom_numeric_2_2,  -- Salário com 2 casas decimais
    id_administrador INTEGER,  -- Referência ao administrador (auto referência)
    id_zelador INTEGER,  -- Referência ao zelador (auto referência)
    id_instrutor INTEGER,  -- Referência ao instrutor (auto referência)
    id_departamento INTEGER REFERENCES DEPARTAMENTO(id_departamento) ON DELETE SET NULL,  -- Relacionamento com DEPARTAMENTO
    id_capacitacao INTEGER REFERENCES CAPACITACAO(id_capacitacao) ON DELETE SET NULL,  -- Relacionamento com CAPACITACAO
    -- Regras de integridade referencial para garantir a consistência dos dados
    CONSTRAINT fk_administrador FOREIGN KEY (id_administrador) REFERENCES EMPREGADO(id_empregado) ON DELETE SET NULL,
    CONSTRAINT fk_zelador FOREIGN KEY (id_zelador) REFERENCES EMPREGADO(id_empregado) ON DELETE SET NULL,
    CONSTRAINT fk_instrutor FOREIGN KEY (id_instrutor) REFERENCES EMPREGADO(id_empregado) ON DELETE SET NULL
);

-- Tabela EQUIPAMENTO
-- Equipamentos são associados a departamentos e fornecedores.

CREATE TABLE EQUIPAMENTO (
    id_equipamento SERIAL PRIMARY KEY,  -- Auto incremento para ID
    nome dom_varchar_100 NOT NULL,  -- Nome do equipamento
    id_departamento INTEGER REFERENCES DEPARTAMENTO(id_departamento) ON DELETE CASCADE,  -- Relacionamento com DEPARTAMENTO
    id_fornecedor INTEGER REFERENCES FORNECEDOR(id_fornecedor) ON DELETE SET NULL  -- Relacionamento com FORNECEDOR
);

-- Tabela AULA
-- Detalhes sobre as aulas, incluindo horário, instrutores e capacidade.

CREATE TABLE AULA (
    id_aula SERIAL PRIMARY KEY,  -- Auto incremento para ID da aula
    nome_aula dom_varchar_100 NOT NULL,  -- Nome obrigatório para a aula
    data_hora dom_timestamp NOT NULL,  -- Data e hora obrigatória da aula
    duracao INTEGER CHECK (duracao > 0),  -- Duracao maior que 0
    id_instrutor INTEGER REFERENCES EMPREGADO(id_empregado) ON DELETE SET NULL,  -- Relacionamento com o instrutor
    capacidade_maxima INTEGER CHECK (capacidade_maxima > 0),  -- Capacidade maior que 0
    descricao_atividades TEXT,  -- Descrição das atividades realizadas
    id_departamento INTEGER REFERENCES DEPARTAMENTO(id_departamento) ON DELETE CASCADE  -- Relacionamento com DEPARTAMENTO
);

-- Tabela PLANO_ALUNO
-- Relacionamento de planos com alunos, com informações detalhadas do aluno.

CREATE TABLE PLANO_ALUNO (
    id_plano SERIAL NOT NULL,  -- Auto incremento para ID do plano
    id_aluno SERIAL NOT NULL,  -- ID do aluno
    descricao dom_varchar_200,  -- Descrição do plano
    duracao INTEGER CHECK (duracao > 0),  -- Duracao maior que 0
    preco dom_numeric_2_2 CHECK (preco >= 0),  -- Preço não pode ser negativo
    id_administrador INTEGER REFERENCES EMPREGADO(id_empregado) ON DELETE SET NULL,  -- Referência ao administrador responsável
    nome dom_varchar_100 NOT NULL,  -- Nome do aluno
    endereco dom_varchar_200 NOT NULL,  -- Endereço do aluno
    telefone dom_varchar_20,  -- Telefone do aluno
    cpf dom_varchar_11 UNIQUE NOT NULL,  -- CPF único do aluno
    data_insercao dom_date DEFAULT CURRENT_DATE,  -- Data de inserção, padrão para a data atual
    status dom_status NOT NULL,  -- Status do plano
    PRIMARY KEY (id_plano, id_aluno)  -- Chave primária composta
);

-- Tabela PAGAMENTO
-- Relacionamento entre planos e pagamentos realizados pelos alunos.

CREATE TABLE PAGAMENTO (
    id_pagamento SERIAL PRIMARY KEY,  -- Auto incremento para ID do pagamento
    tipo_pagamento dom_varchar_50 NOT NULL,  -- Tipo de pagamento (cartão, boleto, etc)
    data_pagamento dom_date NOT NULL DEFAULT CURRENT_DATE,  -- Data do pagamento
    valor dom_numeric_2_2 CHECK (valor >= 0),  -- Preço não pode ser negativo
    id_plano INTEGER NOT NULL,  -- Referência ao plano do aluno
    id_aluno INTEGER NOT NULL,  -- Referência ao aluno
    FOREIGN KEY (id_plano, id_aluno) REFERENCES PLANO_ALUNO(id_plano, id_aluno) ON DELETE CASCADE  -- Chave estrangeira composta
);

-- Tabela Ministram (Associação N:M entre EMPREGADO e AULA)
-- Registro de aulas ministradas pelos instrutores.

CREATE TABLE Ministram (
    id_instrutor INTEGER NOT NULL,  -- ID do instrutor
    id_aula INTEGER NOT NULL,  -- ID da aula
    PRIMARY KEY (id_instrutor, id_aula),  -- Chave primária composta
    FOREIGN KEY (id_instrutor) REFERENCES EMPREGADO(id_empregado) ON DELETE CASCADE,  -- Relacionamento com EMPREGADO
    FOREIGN KEY (id_aula) REFERENCES AULA(id_aula) ON DELETE CASCADE  -- Relacionamento com AULA
);

-- Tabela Frequentam (Associação N:M entre PLANO_ALUNO e AULA)
-- Registro de quais alunos frequentam quais aulas.

CREATE TABLE Frequentam (
    id_plano INTEGER NOT NULL,  -- ID do plano do aluno
    id_aluno INTEGER NOT NULL,  -- ID do aluno
    id_aula INTEGER NOT NULL,  -- ID da aula
    PRIMARY KEY (id_plano, id_aluno, id_aula),  -- Chave primária composta
    FOREIGN KEY (id_plano, id_aluno) REFERENCES PLANO_ALUNO(id_plano, id_aluno) ON DELETE CASCADE,  -- Relacionamento com PLANO_ALUNO
    FOREIGN KEY (id_aula) REFERENCES AULA(id_aula) ON DELETE CASCADE  -- Relacionamento com AULA
);

-- Índices para melhorar o desempenho nas consultas frequentes

CREATE INDEX idx_empregado_cpf ON EMPREGADO(cpf);  -- Index para melhorar buscas por CPF de empregado
CREATE INDEX idx_plano_aluno_cpf ON PLANO_ALUNO(cpf);  -- Index