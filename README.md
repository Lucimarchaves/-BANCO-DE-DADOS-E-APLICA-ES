# Sistema de Revenda e Oficina Mecânica

Sistema web desenvolvido em Python com Flask para gerenciar uma revenda de veículos e o controle de oficina mecânica. O projeto integra cadastro de clientes, vendedores, veículos, vendas, ordens de serviço e relatório gerencial de mecânicos.

## 🧩 Objetivo

Este projeto foi criado para simular uma aplicação empresarial de revenda automotiva com foco em:

- cadastro de veículos para venda;
- relacionamento com clientes e vendedores;
- registro de vendas;
- abertura e acompanhamento de ordens de serviço;
- controle de serviços realizados e faturamento por mecânico;
- relatórios gerenciais básicos para análise da operação.

## 🚗 Funcionalidades

### Revenda
- Cadastro de veículos
- Listagem de veículos disponíveis para venda
- Registro de vendas
- Cadastro de clientes
- Cadastro de vendedores
- Visualização de vendas realizadas

### Oficina mecânica
- Cadastro de ordens de serviço
- Associação com cliente, veículo e mecânico responsável
- Registro de observações da OS
- Relatório de serviços por mecânico
- Cálculo de faturamento por profissional

### Relatórios
- Mecânicos com maior número de serviços realizados
- Quantidade de ordens por mecânico
- Faturamento total por especialidade

---

## 🛠️ Tecnologias utilizadas

- Python 3
- Flask
- MySQL
- mysql-connector-python
- HTML + Jinja2 templates
- CSS para padronização visual

---

## 📁 Estrutura do projeto

```text
-BANCO-DE-DADOS-E-APLICA-ES/
├── app.py                  # Aplicação principal Flask
├── db.py                   # Configuração de conexão com o banco
├── banco.sql               # Script de criação do banco e dados iniciais
├── requirements.txt        # Dependências do projeto
├── static/
│   └── style.css           # CSS global para os templates
├── templates/
│   ├── index.html
│   ├── clientes.html
│   ├── veiculos.html
│   ├── vender.html
│   ├── vendas.html
│   ├── vendedores.html
│   ├── cadastrar_cliente.html
│   ├── cadastrar_vendedor.html
│   ├── cadastrar_veiculo.html
│   ├── cadastrar_os.html
│   ├── ordens_servico.html
│   └── relatorio.html
├── Diagramaer.png          # Diagrama do sistema
├── revenda passo a  passo.md
├── revenda passo a passo pt2.md
└── README.md
```

---

## 🗄️ Banco de dados

O projeto utiliza um banco MySQL chamado `revenda`.

### Arquivo principal do banco
- `banco.sql`

Esse script:
- elimina e recria o banco;
- cria todas as tabelas da revenda e da oficina;
- insere dados iniciais de teste;
- inclui exemplos de consultas do relatório gerencial.

### Configuração da conexão
No arquivo `db.py`, a conexão está configurada assim:

```python
import mysql.connector

db_config = {
    "host": "localhost",
    "user": "root",
    "password": "1234",
    "database": "revenda"
}
```

Se o seu MySQL usa outra senha ou usuário, ajuste esses valores antes de executar a aplicação.

---

## ✅ Requisitos

- Python 3.10 ou superior
- MySQL Server instalado e em execução
- MySQL Workbench opcional, mas recomendado

### Dependências do projeto

```bash
pip install -r requirements.txt
```

Conteúdo de `requirements.txt`:

```txt
flask
mysql-connector-python
```

---

## ▶️ Como executar o projeto

### 1. Preparar o banco
Abra o MySQL e execute o script:

```bash
mysql -u root -p < banco.sql
```

Ou importe o arquivo `banco.sql` no MySQL Workbench.

### 2. Instalar dependências

```bash
pip install -r requirements.txt
```

### 3. Rodar a aplicação

```bash
python app.py
```

A aplicação será iniciada em modo de desenvolvimento, geralmente em:

```text
http://127.0.0.1:5000/
```

---

## 🌐 Rotas principais

- `/` — menu principal
- `/veiculos` — listagem de veículos disponíveis
- `/cadastrar_veiculo` — cadastro de veículos
- `/vender/<id_veiculo>` — registro de venda
- `/vendas` — histórico de vendas
- `/clientes` — listagem de clientes
- `/cadastrar_cliente` — cadastro de clientes
- `/vendedores` — listagem de vendedores
- `/cadastrar_vendedor` — cadastro de vendedores
- `/ordens_servico` — listagem de ordens de serviço
- `/cadastrar_os` — cadastro de ordem de serviço
- `/relatorio` — relatório de mecanicos e faturamento

---

## 📊 Modelo de negócio

O sistema trabalha com as seguintes entidades principais:

- `marca`
- `modelo`
- `veiculo`
- `cliente`
- `vendedor`
- `venda`
- `mecanico`
- `servico`
- `ordem_servico`
- `os_servico`

Essas entidades permitem mapear o fluxo completo de uma revenda automotiva integrando também uma estrutura de oficina mecânica.

---

## 🧪 Dados de exemplo

O script `banco.sql` já inclui registros de:

- marcas e modelos de veículos;
- clientes;
- vendedores;
- veículos disponíveis e vendidos;
- mecânicos;
- serviços;
- ordens de serviço e itens de cada OS.

Isso facilita a apresentação e os testes do sistema sem necessidade de inserir dados manualmente.

---

##  Observações

- O projeto pode ser usado como base para apresentação acadêmica ou demonstração de desenvolvimento web com Flask e banco relacional.
- A interface foi organizada em templates separados, com CSS centralizado em `static/style.css`.
- Em caso de erro de conexão, verifique:
  - MySQL em execução;
  - usuário e senha corretos em `db.py`;
  - banco `revenda` existente e criado pelo script;
  - permissões do usuário `root` no ambiente local.

---
