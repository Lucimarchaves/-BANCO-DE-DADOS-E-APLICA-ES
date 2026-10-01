# Sistema de Revenda de Carros com Flask + MySQL

## 1. Objetivo do projeto

Criar uma aplicação web simples para uma **revenda de veículos**, usando:

- **Backend:** Python + Flask  
- **Banco de dados:** MySQL  
- **Modelo de dados:** revenda de carros (Marca, Modelo, Veículo, Cliente, Vendedor, Venda etc.)

---

## 2. Pré-requisitos

- Python instalado (3.10+ recomendado)
- MySQL instalado e rodando
- MySQL Workbench (opcional, mas recomendado)
- Editor de código (VS Code, PyCharm, etc.)

---

## 3. Criar o banco de dados no MySQL

1. Abra o MySQL Workbench.
2. Crie um novo script SQL.
3. Cole o script abaixo e execute:

```sql
CREATE DATABASE revenda;
USE revenda;

CREATE TABLE marca (
    id_marca INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE modelo (
    id_modelo INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    ano_lancamento YEAR NOT NULL,
    id_marca INT NOT NULL,
    FOREIGN KEY (id_marca) REFERENCES marca(id_marca)
);

CREATE TABLE veiculo (
    id_veiculo INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(10) NOT NULL,
    chassi VARCHAR(50) NOT NULL,
    ano_fabricacao YEAR NOT NULL,
    ano_modelo YEAR NOT NULL,
    cor VARCHAR(50),
    quilometragem INT,
    combustivel VARCHAR(30),
    cambio VARCHAR(30),
    numero_portas INT,
    valor_aquisicao DECIMAL(10,2),
    valor_anunciado DECIMAL(10,2),
    situacao VARCHAR(30),
    id_modelo INT NOT NULL,
    FOREIGN KEY (id_modelo) REFERENCES modelo(id_modelo)
);

CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf_cnpj VARCHAR(20) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100),
    endereco VARCHAR(200)
);

CREATE TABLE vendedor (
    id_vendedor INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(20) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100),
    data_admissao DATE,
    situacao VARCHAR(30)
);

CREATE TABLE venda (
    id_venda INT AUTO_INCREMENT PRIMARY KEY,
    data_venda DATE NOT NULL,
    valor_venda DECIMAL(10,2),
    desconto DECIMAL(10,2),
    observacoes TEXT,
    id_veiculo INT NOT NULL UNIQUE,
    id_cliente INT NOT NULL,
    id_vendedor INT NOT NULL,
    FOREIGN KEY (id_veiculo) REFERENCES veiculo(id_veiculo),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_vendedor) REFERENCES vendedor(id_vendedor)
);
```

---

## 4. Inserir dados de teste

Execute este script para ter dados iniciais:

```sql
USE revenda;

INSERT INTO marca (nome) VALUES
('Volkswagen'),
('Chevrolet'),
('Fiat'),
('Toyota');

INSERT INTO modelo (nome, ano_lancamento, id_marca) VALUES
('Gol', 2008, 1),
('Onix', 2013, 2),
('Uno', 2005, 3),
('Corolla', 2018, 4);

INSERT INTO veiculo (
    placa, chassi, ano_fabricacao, ano_modelo, cor, quilometragem,
    combustivel, cambio, numero_portas, valor_aquisicao, valor_anunciado,
    situacao, id_modelo
) VALUES
('ABC1A23', '9BWZZZ377VT004251', 2010, 2011, 'Prata', 120000, 'Gasolina', 'Manual', 4, 18000, 22000, 'Estoque', 1),
('DEF2B34', '9BWZZZ377VT004252', 2018, 2018, 'Branco', 45000, 'Flex', 'Automático', 4, 45000, 52000, 'Estoque', 2);

INSERT INTO cliente (nome, cpf_cnpj, telefone, email, endereco) VALUES
('João Silva', '123.456.789-00', '11999990000', 'joao@gmail.com', 'Rua A, 123'),
('Maria Oliveira', '987.654.321-00', '11988880000', 'maria@gmail.com', 'Rua B, 456');

INSERT INTO vendedor (nome, cpf, telefone, email, data_admissao, situacao) VALUES
('Carlos Mendes', '111.222.333-44', '11977770000', 'carlos@revenda.com', '2020-01-10', 'Ativo'),
('Fernanda Souza', '555.666.777-88', '11966660000', 'fernanda@revenda.com', '2021-03-15', 'Ativo');
```

---

## 5. Criar o projeto Flask

### 5.1. Estrutura de pastas

Crie uma pasta para o projeto:

```text
revenda_app/
  app.py
  requirements.txt
  templates/
    veiculos.html
    vender.html
    vendas.html
```

### 5.2. Arquivo `requirements.txt`

```txt
flask
mysql-connector-python
```

Instalar dependências:

```bash
pip install -r requirements.txt
```

---

## 6. Código principal – `app.py`

```python
from flask import Flask, render_template, request, redirect, url_for, flash
import mysql.connector

app = Flask(__name__)
app.secret_key = "segredo-da-revenda"

db_config = {
    "host": "localhost",
    "user": "root",
    "password": "SUA_SENHA_AQUI",
    "database": "revenda"
}

def get_connection():
    return mysql.connector.connect(**db_config)

@app.route("/")
@app.route("/veiculos")
def listar_veiculos():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    query = """
        SELECT v.id_veiculo, v.placa, v.cor, v.valor_anunciado,
               m.nome AS marca, mo.nome AS modelo
        FROM veiculo v
        JOIN modelo mo ON mo.id_modelo = v.id_modelo
        JOIN marca m ON m.id_marca = mo.id_marca
        LEFT JOIN venda ve ON ve.id_veiculo = v.id_veiculo
        WHERE ve.id_venda IS NULL
    """
    cursor.execute(query)
    veiculos = cursor.fetchall()

    cursor.close()
    conn.close()
    return render_template("veiculos.html", veiculos=veiculos)

@app.route("/vender/<int:id_veiculo>", methods=["GET", "POST"])
def vender_veiculo(id_veiculo):
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT v.id_veiculo, v.placa, v.valor_anunciado
        FROM veiculo v
        WHERE v.id_veiculo = %s
    """, (id_veiculo,))
    veiculo = cursor.fetchone()

    if not veiculo:
        cursor.close()
        conn.close()
        flash("Veículo não encontrado.", "danger")
        return redirect(url_for("listar_veiculos"))

    if request.method == "POST":
        id_cliente = request.form.get("id_cliente")
        id_vendedor = request.form.get("id_vendedor")
        valor_venda = request.form.get("valor_venda")
        desconto = request.form.get("desconto") or 0
        observacoes = request.form.get("observacoes") or ""

        cursor.execute("SELECT 1 FROM venda WHERE id_veiculo = %s", (id_veiculo,))
        if cursor.fetchone():
            flash("Veículo já foi vendido.", "danger")
        else:
            cursor.execute("""
                INSERT INTO venda (
                    data_venda, valor_venda, desconto, observacoes,
                    id_veiculo, id_cliente, id_vendedor
                ) VALUES (CURDATE(), %s, %s, %s, %s, %s, %s)
            """, (valor_venda, desconto, observacoes, id_veiculo, id_cliente, id_vendedor))

            cursor.execute("""
                UPDATE veiculo
                SET situacao = 'Vendido'
                WHERE id_veiculo = %s
            """, (id_veiculo,))

            conn.commit()
            flash("Venda registrada com sucesso!", "success")
            cursor.close()
            conn.close()
            return redirect(url_for("listar_veiculos"))

    cursor.execute("SELECT id_cliente, nome FROM cliente")
    clientes = cursor.fetchall()

    cursor.execute("SELECT id_vendedor, nome FROM vendedor")
    vendedores = cursor.fetchall()

    cursor.close()
    conn.close()
    return render_template("vender.html",
                           veiculo=veiculo,
                           clientes=clientes,
                           vendedores=vendedores)

@app.route("/vendas")
def listar_vendas():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT ve.id_venda, ve.data_venda, ve.valor_venda, ve.desconto,
               v.placa, c.nome AS cliente, vd.nome AS vendedor
        FROM venda ve
        JOIN veiculo v ON v.id_veiculo = ve.id_veiculo
        JOIN cliente c ON c.id_cliente = ve.id_cliente
        JOIN vendedor vd ON vd.id_vendedor = ve.id_vendedor
        ORDER BY ve.data_venda DESC
    """)
    vendas = cursor.fetchall()

    cursor.close()
    conn.close()
    return render_template("vendas.html", vendas=vendas)

if __name__ == "__main__":
    app.run(debug=True)
```

---

## 7. Templates HTML

### 7.1. `templates/veiculos.html`

```html
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Veículos disponíveis</title>
</head>
<body>
    <h1>Veículos disponíveis para venda</h1>
    <table border="1">
        <tr>
            <th>Placa</th>
            <th>Marca</th>
            <th>Modelo</th>
            <th>Cor</th>
            <th>Valor anunciado</th>
            <th>Ações</th>
        </tr>
        {% for v in veiculos %}
        <tr>
            <td>{{ v.placa }}</td>
            <td>{{ v.marca }}</td>
            <td>{{ v.modelo }}</td>
            <td>{{ v.cor }}</td>
            <td>R$ {{ v.valor_anunciado }}</td>
            <td>
                <a href="{{ url_for('vender_veiculo', id_veiculo=v.id_veiculo) }}">
                    Vender
                </a>
            </td>
        </tr>
        {% endfor %}
    </table>
    <a href="{{ url_for('listar_vendas') }}">Ver vendas</a>
</body>
</html>
```

### 7.2. `templates/vender.html`

```html
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Vender veículo</title>
</head>
<body>
    <h1>Vender veículo {{ veiculo.placa }}</h1>

    <form method="post">
        <label>Cliente:</label>
        <select name="id_cliente" required>
            {% for c in clientes %}
            <option value="{{ c.id_cliente }}">{{ c.nome }}</option>
            {% endfor %}
        </select><br>

        <label>Vendedor:</label>
        <select name="id_vendedor" required>
            {% for v in vendedores %}
            <option value="{{ v.id_vendedor }}">{{ v.nome }}</option>
            {% endfor %}
        </select><br>

        <label>Valor venda:</label>
        <input type="number" step="0.01" name="valor_venda"
               value="{{ veiculo.valor_anunciado }}" required><br>

        <label>Desconto:</label>
        <input type="number" step="0.01" name="desconto" value="0"><br>

        <label>Observações:</label><br>
        <textarea name="observacoes"></textarea><br>

        <button type="submit">Confirmar venda</button>
    </form>

    <a href="{{ url_for('listar_veiculos') }}">Voltar</a>
</body>
</html>
```

### 7.3. `templates/vendas.html`

```html
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Vendas</title>
</head>
<body>
    <h1>Vendas realizadas</h1>
    <table border="1">
        <tr>
            <th>Data</th>
            <th>Placa</th>
            <th>Cliente</th>
            <th>Vendedor</th>
            <th>Valor</th>
            <th>Desconto</th>
        </tr>
        {% for v in vendas %}
        <tr>
            <td>{{ v.data_venda }}</td>
            <td>{{ v.placa }}</td>
            <td>{{ v.cliente }}</td>
            <td>{{ v.vendedor }}</td>
            <td>R$ {{ v.valor_venda }}</td>
            <td>R$ {{ v.desconto }}</td>
        </tr>
        {% endfor %}
    </table>

    <a href="{{ url_for('listar_veiculos') }}">Voltar para veículos</a>
</body>
</html>
```

---

## 8. Executar a aplicação

No terminal, dentro da pasta do projeto:

```bash
python app.py
```

Abra no navegador:

```text
http://127.0.0.1:5000
```

---
