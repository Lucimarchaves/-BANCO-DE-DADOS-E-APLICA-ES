from flask import Flask, render_template, request, redirect, url_for, flash
from db import get_connection

app = Flask(__name__)
app.secret_key = "segredo-da-revenda"





@app.route("/")
def index():
    return render_template("index.html")

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
        AND v.situacao = 'Disponível'
    """
    cursor.execute(query)
    veiculos = cursor.fetchall()

    cursor.close()
    conn.close()
    return render_template("veiculos.html", veiculos=veiculos)

@app.route("/cadastrar_veiculo", methods=["GET", "POST"])
def cadastrar_veiculo():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    if request.method == "POST":
        placa = request.form.get("placa")
        chassi = request.form.get("chassi")
        id_modelo = request.form.get("id_modelo")
        ano_fabricacao = request.form.get("ano_fabricacao")
        ano_modelo = request.form.get("ano_modelo")
        cor = request.form.get("cor") or None
        quilometragem = request.form.get("quilometragem") or None
        combustivel = request.form.get("combustivel") or None
        cambio = request.form.get("cambio") or None
        numero_portas = request.form.get("numero_portas") or None
        valor_aquisicao = request.form.get("valor_aquisicao") or None
        valor_anunciado = request.form.get("valor_anunciado") or None
        situacao = request.form.get("situacao") or "Disponível"

        cursor.execute("SELECT 1 FROM veiculo WHERE chassi = %s", (chassi,))
        if cursor.fetchone():
            flash("Já existe um veículo cadastrado com esse chassi.", "danger")
        else:
            cursor.execute("""
                INSERT INTO veiculo (
                    placa, chassi, ano_fabricacao, ano_modelo, cor, quilometragem,
                    combustivel, cambio, numero_portas, valor_aquisicao,
                    valor_anunciado, situacao, id_modelo
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (placa, chassi, ano_fabricacao, ano_modelo, cor, quilometragem,
                  combustivel, cambio, numero_portas, valor_aquisicao,
                  valor_anunciado, situacao, id_modelo))

            conn.commit()
            flash("Veículo cadastrado com sucesso!", "success")
            cursor.close()
            conn.close()
            return redirect(url_for("listar_veiculos"))

    cursor.execute("""
        SELECT mo.id_modelo, mo.nome, m.nome AS marca
        FROM modelo mo
        JOIN marca m ON m.id_marca = mo.id_marca
        ORDER BY m.nome, mo.nome
    """)
    modelos = cursor.fetchall()

    cursor.close()
    conn.close()
    return render_template("cadastrar_veiculo.html", modelos=modelos)

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


@app.route("/clientes")
def listar_clientes():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id_cliente, nome, cpf_cnpj, telefone, email, endereco
        FROM cliente
        ORDER BY nome
    """)
    clientes = cursor.fetchall()

    cursor.close()
    conn.close()
    return render_template("clientes.html", clientes=clientes)

@app.route("/vendedores")
def listar_vendedores():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT id_vendedor, nome, cpf, telefone, email, data_admissao, situacao
        FROM vendedor
        ORDER BY nome
    """)
    vendedores = cursor.fetchall()

    cursor.close()
    conn.close()
    return render_template("vendedores.html", vendedores=vendedores)

@app.route("/ordens_servico")
def listar_ordens_servico():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            os.id_os                                      AS os,
            c.nome                                        AS cliente,
            CONCAT(ma.nome, ' ', mo.nome, ' - ', v.placa) AS veiculo,
            me.nome                                       AS mecanico,
            DATE_FORMAT(os.data_abertura, '%d/%m/%Y')     AS data
        FROM ordem_servico os
        INNER JOIN cliente  c  ON c.id_cliente   = os.id_cliente
        INNER JOIN veiculo  v  ON v.id_veiculo   = os.id_veiculo
        INNER JOIN modelo   mo ON mo.id_modelo   = v.id_modelo
        INNER JOIN marca    ma ON ma.id_marca    = mo.id_marca
        INNER JOIN mecanico me ON me.id_mecanico = os.id_mecanico
        ORDER BY os.data_abertura DESC
    """)
    ordens = cursor.fetchall()

    cursor.close()
    conn.close()
    return render_template("ordens_servico.html", ordens=ordens)

@app.route("/relatorio")
def relatorio_mecanicos():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            me.nome                             AS mecanico,
            me.especialidade,
            COUNT(oss.id_servico)               AS total_servicos,
            COUNT(DISTINCT os.id_os)            AS total_os,
            COALESCE(SUM(oss.valor_cobrado), 0) AS faturamento
        FROM mecanico me
        LEFT JOIN ordem_servico os  ON os.id_mecanico = me.id_mecanico
        LEFT JOIN os_servico    oss ON oss.id_os      = os.id_os
        GROUP BY me.id_mecanico, me.nome, me.especialidade
        ORDER BY total_servicos DESC, faturamento DESC
    """)
    relatorio = cursor.fetchall()

    cursor.close()
    conn.close()
    return render_template("relatorio.html", relatorio=relatorio)


if __name__ == "__main__":
    app.run(debug=True)