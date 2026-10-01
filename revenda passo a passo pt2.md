1. Estrutura do Projeto

revenda_app/
  app.py
  requirements.txt
  templates/
    cadastrar_cliente.html
    cadastrar_vendedor.html
    cadastrar_veiculo.html

2. Rotas no Flask

2.1 Cadastro de Clientes

@app.route('/cadastrar_cliente', methods=['GET', 'POST'])
def cadastrar_cliente():
    conn = get_connection()
    cursor = conn.cursor()

    if request.method == 'POST':
        nome = request.form['nome']
        cpf_cnpj = request.form['cpf_cnpj']
        telefone = request.form['telefone']
        email = request.form['email']
        endereco = request.form['endereco']

        cursor.execute('''
            INSERT INTO cliente (nome, cpf_cnpj, telefone, email, endereco)
            VALUES (%s, %s, %s, %s, %s)
        ''', (nome, cpf_cnpj, telefone, email, endereco))

        conn.commit()
        cursor.close()
        conn.close()
        return redirect('/clientes')

    cursor.close()
    conn.close()
    return render_template('cadastrar_cliente.html')

2.2 Cadastro de Vendedores

@app.route('/cadastrar_vendedor', methods=['GET', 'POST'])
def cadastrar_vendedor():
    conn = get_connection()
    cursor = conn.cursor()

    if request.method == 'POST':
        nome = request.form['nome']
        cpf = request.form['cpf']
        telefone = request.form['telefone']
        email = request.form['email']
        data_admissao = request.form['data_admissao']
        situacao = request.form['situacao']

        cursor.execute('''
            INSERT INTO vendedor (nome, cpf, telefone, email, data_admissao, situacao)
            VALUES (%s, %s, %s, %s, %s, %s)
        ''', (nome, cpf, telefone, email, data_admissao, situacao))

        conn.commit()
        cursor.close()
        conn.close()
        return redirect('/vendedores')

    cursor.close()
    conn.close()
    return render_template('cadastrar_vendedor.html')

2.3 Cadastro de Veículos

@app.route('/cadastrar_veiculo', methods=['GET', 'POST'])
def cadastrar_veiculo():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute('SELECT id_modelo, nome FROM modelo')
    modelos = cursor.fetchall()

    if request.method == 'POST':
        placa = request.form['placa']
        chassi = request.form['chassi']
        ano_fabricacao = request.form['ano_fabricacao']
        ano_modelo = request.form['ano_modelo']
        cor = request.form['cor']
        quilometragem = request.form['quilometragem']
        combustivel = request.form['combustivel']
        cambio = request.form['cambio']
        numero_portas = request.form['numero_portas']
        valor_aquisicao = request.form['valor_aquisicao']
        valor_anunciado = request.form['valor_anunciado']
        id_modelo = request.form['id_modelo']

        cursor.execute('''
            INSERT INTO veiculo (
                placa, chassi, ano_fabricacao, ano_modelo, cor, quilometragem,
                combustivel, cambio, numero_portas, valor_aquisicao,
                valor_anunciado, situacao, id_modelo
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'Estoque', %s)
        ''', (placa, chassi, ano_fabricacao, ano_modelo, cor, quilometragem,
              combustivel, cambio, numero_portas, valor_aquisicao,
              valor_anunciado, id_modelo))

        conn.commit()
        cursor.close()
        conn.close()
        return redirect('/veiculos')

    cursor.close()
    conn.close()
    return render_template('cadastrar_veiculo.html', modelos=modelos)

3. Templates HTML

3.1 cadastrar_cliente.html

<h1>Cadastrar Cliente</h1>
<form method="post">
    <label>Nome:</label>
    <input type="text" name="nome" required><br>

    <label>CPF/CNPJ:</label>
    <input type="text" name="cpf_cnpj" required><br>

    <label>Telefone:</label>
    <input type="text" name="telefone"><br>

    <label>Email:</label>
    <input type="email" name="email"><br>

    <label>Endereço:</label>
    <input type="text" name="endereco"><br>

    <button type="submit">Salvar</button>
</form>

3.2 cadastrar_vendedor.html

<h1>Cadastrar Vendedor</h1>
<form method="post">
    <label>Nome:</label>
    <input type="text" name="nome" required><br>

    <label>CPF:</label>
    <input type="text" name="cpf" required><br>

    <label>Telefone:</label>
    <input type="text" name="telefone"><br>

    <label>Email:</label>
    <input type="email" name="email"><br>

    <label>Data de Admissão:</label>
    <input type="date" name="data_admissao"><br>

    <label>Situação:</label>
    <select name="situacao">
        <option value="Ativo">Ativo</option>
        <option value="Inativo">Inativo</option>
    </select><br>

    <button type="submit">Salvar</button>
</form>

3.3 cadastrar_veiculo.html

<h1>Cadastrar Veículo</h1>
<form method="post">
    <label>Placa:</label>
    <input type="text" name="placa" required><br>

    <label>Chassi:</label>
    <input type="text" name="chassi" required><br>

    <label>Ano Fabricação:</label>
    <input type="number" name="ano_fabricacao" required><br>

    <label>Ano Modelo:</label>
    <input type="number" name="ano_modelo" required><br>

    <label>Cor:</label>
    <input type="text" name="cor"><br>

    <label>Quilometragem:</label>
    <input type="number" name="quilometragem"><br>

    <label>Combustível:</label>
    <input type="text" name="combustivel"><br>

    <label>Câmbio:</label>
    <input type="text" name="cambio"><br>

    <label>Número de Portas:</label>
    <input type="number" name="numero_portas"><br>

    <label>Valor Aquisição:</label>
    <input type="number" step="0.01" name="valor_aquisicao"><br>

    <label>Valor Anunciado:</label>
    <input type="number" step="0.01" name="valor_anunciado"><br>

    <label>Modelo:</label>
    <select name="id_modelo">
        {% for m in modelos %}
        <option value="{{ m.id_modelo }}">{{ m.nome }}</option>
        {% endfor %}
    </select><br>

    <button type="submit">Salvar</button>
</form>


## Tela Principal – Menu Inicial  
*(arquivo: `templates/index.html`)*

```html
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Revenda de Veículos - Menu Principal</title>
    <style>
        body {
            font-family: Arial;
            background-color: #f5f5f5;
            padding: 40px;
        }
        h1 {
            text-align: center;
        }
        .menu {
            width: 400px;
            margin: auto;
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 0 10px #ccc;
        }
        .menu a {
            display: block;
            padding: 12px;
            margin: 8px 0;
            background: #007bff;
            color: white;
            text-decoration: none;
            text-align: center;
            border-radius: 6px;
        }
        .menu a:hover {
            background: #0056b3;
        }
    </style>
</head>
<body>

    <h1>Sistema de Revenda de Veículos</h1>

    <div class="menu">
        <a href="/veiculos">Veículos Disponíveis</a>
        <a href="/cadastrar_veiculo">Cadastrar Veículo</a>
        <a href="/clientes">Lista de Clientes</a>
        <a href="/cadastrar_cliente">Cadastrar Cliente</a>
        <a href="/vendedores">Lista de Vendedores</a>
        <a href="/cadastrar_vendedor">Cadastrar Vendedor</a>
        <a href="/vendas">Vendas Realizadas</a>
    </div>

</body>
</html>
```

---

## Rota Flask para a tela principal  
*(adicione no `app.py`)*

```python
@app.route("/")
def index():
    return render_template("index.html")
```

---


