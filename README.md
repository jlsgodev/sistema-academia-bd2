# Sistema de Gerenciamento de Academia  - BD II

Este repositório contém os arquivos e a documentação do Trabalho Final da disciplina **Banco de Dados II** no Instituto Federal Catarinense.

## Estrutura do Repositório

### Diretórios
- `sql/`: Scripts SQL organizados por funcionalidade.
- `docs/`: Documentação complementar, incluindo o modelo conceitual e o modelo lógico.

### Scripts SQL
1. **01-schema.sql**: Criação do esquema e tabelas.
2. **02-queries.sql**: Consultas principais.
3. **03-functions.sql**: Funções armazenadas.
4. **04-stored-procedures.sql**: Procedures.
5. **05-triggers.sql**: Gatilhos.
6. **06-views.sql**: Visualizações.
7. **07-users.sql**: Configuração de usuários e permissões.

### Documentação
- `docs/documentacao-trabalho-final-bd2.docx`: Documento detalhado do projeto.

---
## Banco de Dados

- **Banco de Dados**: PostgreSQL
- **Versão**: 16.4
- **Sistema Operacional**: Ubuntu 24.04
- **Ferramentas de Banco de Dados**: pgAdmin, psql

### Como Configurar o Banco de Dados
Caso precise configurar o PostgreSQL, siga os passos abaixo:

 **Instalar o PostgreSQL**:
   ```bash
   sudo apt update
   sudo apt install postgresql postgresql-contrib

