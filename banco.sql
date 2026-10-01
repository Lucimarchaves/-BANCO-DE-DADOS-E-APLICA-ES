-- =====================================================================
--  banco.sql
--  Sistema de Controle de Oficina Mecânica Integrado à Revenda
--  Banco de Dados e Aplicações - UNIMAX
--
--  ATENÇÃO: este script APAGA e recria o banco "revenda" do zero.
--  Use para deixar o banco sempre no mesmo estado (bom para a apresentação).
-- =====================================================================

DROP DATABASE IF EXISTS revenda;
CREATE DATABASE revenda CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE revenda;

-- =====================================================================
-- PARTE 1 - TABELAS DA REVENDA (o que você já tinha)
-- =====================================================================

CREATE TABLE marca (
    id_marca INT AUTO_INCREMENT PRIMARY KEY,
    nome     VARCHAR(100) NOT NULL
);

CREATE TABLE modelo (
    id_modelo      INT AUTO_INCREMENT PRIMARY KEY,
    nome           VARCHAR(100) NOT NULL,
    ano_lancamento YEAR NOT NULL,
    id_marca       INT NOT NULL,
    FOREIGN KEY (id_marca) REFERENCES marca(id_marca)
);

CREATE TABLE veiculo (
    id_veiculo      INT AUTO_INCREMENT PRIMARY KEY,
    placa           VARCHAR(10) NOT NULL UNIQUE,
    chassi          VARCHAR(50) NOT NULL UNIQUE,
    ano_fabricacao  YEAR NOT NULL,
    ano_modelo      YEAR NOT NULL,
    cor             VARCHAR(50),
    quilometragem   INT,
    combustivel     VARCHAR(30),
    cambio          VARCHAR(30),
    numero_portas   INT,
    valor_aquisicao DECIMAL(10,2),
    valor_anunciado DECIMAL(10,2),
    situacao        VARCHAR(30),   -- 'Disponível', 'Vendido' ou 'Cliente' (carro de fora, só veio p/ oficina)
    id_modelo       INT NOT NULL,
    FOREIGN KEY (id_modelo) REFERENCES modelo(id_modelo)
);

CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome       VARCHAR(100) NOT NULL,
    cpf_cnpj   VARCHAR(20) NOT NULL,
    telefone   VARCHAR(20),
    email      VARCHAR(100),
    endereco   VARCHAR(200)
);

CREATE TABLE vendedor (
    id_vendedor   INT AUTO_INCREMENT PRIMARY KEY,
    nome          VARCHAR(100) NOT NULL,
    cpf           VARCHAR(20) NOT NULL,
    telefone      VARCHAR(20),
    email         VARCHAR(100),
    data_admissao DATE,
    situacao      VARCHAR(30)
);

CREATE TABLE venda (
    id_venda    INT AUTO_INCREMENT PRIMARY KEY,
    data_venda  DATE NOT NULL,
    valor_venda DECIMAL(10,2),
    desconto    DECIMAL(10,2),
    observacoes TEXT,
    id_veiculo  INT NOT NULL UNIQUE,   -- UNIQUE: um carro só pode ser vendido uma vez
    id_cliente  INT NOT NULL,
    id_vendedor INT NOT NULL,
    FOREIGN KEY (id_veiculo)  REFERENCES veiculo(id_veiculo),
    FOREIGN KEY (id_cliente)  REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_vendedor) REFERENCES vendedor(id_vendedor)
);

-- =====================================================================
-- PARTE 2 - TABELAS DA OFICINA (o que o PDF do trabalho pede)
-- =====================================================================

-- Mecânico: quem executa o serviço.
CREATE TABLE mecanico (
    id_mecanico   INT AUTO_INCREMENT PRIMARY KEY,
    nome          VARCHAR(100) NOT NULL,
    especialidade VARCHAR(100) NOT NULL,
    telefone      VARCHAR(20)
);

-- Serviço: o "cardápio" da oficina, com o preço de tabela.
CREATE TABLE servico (
    id_servico INT AUTO_INCREMENT PRIMARY KEY,
    descricao  VARCHAR(150) NOT NULL,
    valor      DECIMAL(10,2) NOT NULL
);

-- Ordem de Serviço (OS): o atendimento.
-- Cada OS tem UM cliente, UM veículo e UM mecânico responsável (relações 1:N).
CREATE TABLE ordem_servico (
    id_os         INT AUTO_INCREMENT PRIMARY KEY,
    data_abertura DATE NOT NULL,
    observacoes   TEXT,
    status        VARCHAR(20) NOT NULL DEFAULT 'Aberta',  -- 'Aberta', 'Em andamento', 'Concluída'
    id_cliente    INT NOT NULL,
    id_veiculo    INT NOT NULL,
    id_mecanico   INT NOT NULL,
    FOREIGN KEY (id_cliente)  REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_veiculo)  REFERENCES veiculo(id_veiculo),
    FOREIGN KEY (id_mecanico) REFERENCES mecanico(id_mecanico)
);

-- Tabela associativa OS x Serviço (relação N:N).
-- Uma OS pode ter vários serviços, e um serviço aparece em várias OS.
-- valor_cobrado guarda o preço NO DIA do atendimento: se o preço da tabela
-- "servico" mudar amanhã, as OS antigas continuam com o valor correto.
CREATE TABLE os_servico (
    id_os         INT NOT NULL,
    id_servico    INT NOT NULL,
    valor_cobrado DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_os, id_servico),     -- chave composta: o mesmo serviço não repete na mesma OS
    FOREIGN KEY (id_os)      REFERENCES ordem_servico(id_os),
    FOREIGN KEY (id_servico) REFERENCES servico(id_servico)
);

-- =====================================================================
-- PARTE 3 - DADOS DE TESTE
-- A ordem dos INSERTs importa: primeiro as tabelas "pai" (sem FK),
-- depois as "filhas". Senão o MySQL recusa (integridade referencial).
-- Os IDs são AUTO_INCREMENT e começam em 1, na ordem em que aparecem.
-- =====================================================================

INSERT INTO marca (nome) VALUES
('Volkswagen'),   -- 1
('Chevrolet'),    -- 2
('Fiat'),         -- 3
('Toyota'),       -- 4
('Hyundai'),      -- 5
('Honda');        -- 6

INSERT INTO modelo (nome, ano_lancamento, id_marca) VALUES
('Gol',     2008, 1),  -- 1
('Onix',    2013, 2),  -- 2
('Uno',     2005, 3),  -- 3
('Corolla', 2018, 4),  -- 4
('HB20',    2012, 5),  -- 5
('Strada',  2020, 3),  -- 6
('Civic',   2017, 6),  -- 7
('Hilux',   2016, 4);  -- 8

INSERT INTO veiculo (
    placa, chassi, ano_fabricacao, ano_modelo, cor, quilometragem,
    combustivel, cambio, numero_portas, valor_aquisicao, valor_anunciado,
    situacao, id_modelo
) VALUES
-- carros da revenda
('ABC1A23', '9BWZZZ377VT004251', 2010, 2011, 'Prata',    120000, 'Gasolina', 'Manual',     4, 18000.00,  22000.00, 'Disponível', 1),  -- 1
('DEF2B34', '9BGKS48U0JG100002', 2018, 2018, 'Branco',    45000, 'Flex',     'Automático', 4, 45000.00,  52000.00, 'Disponível', 2),  -- 2
('GHI3C45', '9BRBLWHE0K0100003', 2019, 2020, 'Preto',     38000, 'Flex',     'Automático', 4, 98000.00, 112000.00, 'Vendido', 4),  -- 3
('JKL4D56', '9BD15802AF6100004', 2015, 2015, 'Vermelho',  89000, 'Flex',     'Manual',     4, 21000.00,  26500.00, 'Vendido', 3),  -- 4
('MNO5E67', '9BHBG51CAKP100005', 2019, 2019, 'Cinza',     52000, 'Flex',     'Manual',     4, 47000.00,  55900.00, 'Vendido', 5),  -- 5
('PQR6F78', '9BD57818ML1100006', 2021, 2021, 'Branco',    30000, 'Flex',     'Manual',     2, 72000.00,  84900.00, 'Disponível', 6),  -- 6
-- carros de clientes que vieram só para a oficina
('STU7G89', '93HFC2650HZ100007', 2017, 2018, 'Azul',      76000, 'Flex',     'Automático', 4, NULL, NULL, 'Cliente', 7),         -- 7
('VWX8H90', '9BWAB45U8DT100008', 2013, 2013, 'Prata',    142000, 'Flex',     'Manual',     4, NULL, NULL, 'Cliente', 1),         -- 8
('YZA9I01', '9BGKT48L0FG100009', 2016, 2016, 'Preto',     98000, 'Flex',     'Manual',     4, NULL, NULL, 'Cliente', 2),         -- 9
('BCD0J12', '8AJFA22G4G0100010', 2016, 2017, 'Branco',   165000, 'Diesel',   'Automático', 4, NULL, NULL, 'Cliente', 8);         -- 10

-- Dados fictícios (CPFs e e-mails inventados)
INSERT INTO cliente (nome, cpf_cnpj, telefone, email, endereco) VALUES
('João Silva',       '123.456.789-00', '11999990000', 'joao@exemplo.com',     'Rua A, 123 - Indaiatuba'),   -- 1
('Maria Oliveira',   '987.654.321-00', '11988880000', 'maria@exemplo.com',    'Rua B, 456 - Indaiatuba'),   -- 2
('Pedro Almeida',    '321.654.987-11', '19997771111', 'pedro@exemplo.com',    'Av. C, 789 - Campinas'),     -- 3
('Juliana Costa',    '456.789.123-22', '19996662222', 'juliana@exemplo.com',  'Rua D, 10 - Salto'),         -- 4
('Rafael Santos',    '654.321.987-33', '19995553333', 'rafael@exemplo.com',   'Rua E, 55 - Itu'),           -- 5
('Beatriz Ferreira', '789.123.456-44', '19994444444', 'beatriz@exemplo.com',  'Rua F, 300 - Indaiatuba'),   -- 6
('Transportes Lima', '12.345.678/0001-90', '1933334444', 'contato@tlima.com', 'Rod. SP-75, km 40'),         -- 7
('Lucas Pereira',    '147.258.369-55', '19993335555', 'lucas@exemplo.com',    'Rua G, 77 - Indaiatuba');    -- 8

INSERT INTO vendedor (nome, cpf, telefone, email, data_admissao, situacao) VALUES
('Carlos Mendes',  '111.222.333-44', '11977770000', 'carlos@revenda.com',   '2020-01-10', 'Ativo'),  -- 1
('Fernanda Souza', '555.666.777-88', '11966660000', 'fernanda@revenda.com', '2021-03-15', 'Ativo'),  -- 2
('Marcos Ribeiro', '999.888.777-66', '11955550000', 'marcos@revenda.com',   '2019-06-01', 'Inativo'); -- 3

-- Vendas: os veículos 3, 4 e 5 (situacao = 'Vendido')
INSERT INTO venda (data_venda, valor_venda, desconto, observacoes, id_veiculo, id_cliente, id_vendedor) VALUES
('2026-03-12', 110000.00, 2000.00, 'Pagamento à vista',          3, 3, 1),
('2026-04-20',  26000.00,  500.00, 'Entrada + 12x no cartão',    4, 4, 2),
('2026-05-08',  55000.00,  900.00, 'Financiado pelo banco',      5, 5, 1);

INSERT INTO mecanico (nome, especialidade, telefone) VALUES
('Roberto Lima',      'Motor',                '19991110001'),  -- 1
('Ana Paula Rocha',   'Suspensão e freios',   '19991110002'),  -- 2
('Diego Martins',     'Elétrica',             '19991110003'),  -- 3
('Sérgio Nunes',      'Funilaria e pintura',  '19991110004'),  -- 4
('Paulo Henrique',    'Injeção eletrônica',   '19991110005');  -- 5 (recém-contratado, ainda sem OS)

INSERT INTO servico (descricao, valor) VALUES
('Troca de óleo e filtro',           180.00),  -- 1
('Alinhamento e balanceamento',      150.00),  -- 2
('Troca de pastilhas de freio',      320.00),  -- 3
('Revisão completa',                 650.00),  -- 4
('Diagnóstico elétrico (scanner)',   120.00),  -- 5
('Troca de bateria',                 480.00),  -- 6
('Troca de correia dentada',         750.00),  -- 7
('Higienização do ar-condicionado',  200.00),  -- 8
('Polimento e cristalização',        350.00);  -- 9

-- Ordens de serviço (id_cliente, id_veiculo, id_mecanico)
INSERT INTO ordem_servico (data_abertura, observacoes, status, id_cliente, id_veiculo, id_mecanico) VALUES
('2026-07-01', 'Barulho no motor ao dar partida',                 'Concluída',    1,  7, 1),  -- 1
('2026-07-03', 'Freio rangendo ao parar',                          'Concluída',    2,  8, 2),  -- 2
('2026-07-08', 'Revisão de 10.000 km (carro comprado na revenda)', 'Concluída',    3,  3, 1),  -- 3
('2026-07-15', 'Luz da bateria acesa no painel',                   'Concluída',    6,  9, 3),  -- 4
('2026-07-22', 'Volante puxando para a direita',                   'Concluída',    1,  7, 2),  -- 5
('2026-08-02', 'Troca de óleo atrasada',                           'Concluída',    4,  4, 1),  -- 6
('2026-08-10', 'Revisão antes de viagem longa',                    'Concluída',    7, 10, 1),  -- 7
('2026-08-18', 'Risco na porta traseira',                          'Concluída',    5,  5, 4),  -- 8
('2026-08-25', 'Ar-condicionado com cheiro ruim',                  'Concluída',    2,  8, 3),  -- 9
('2026-09-05', 'Correia fazendo barulho',                          'Em andamento', 1,  7, 1),  -- 10
('2026-09-12', 'Pastilha de freio gasta',                          'Aberta',       6,  9, 2),  -- 11
('2026-09-20', 'Alarme disparando sozinho',                        'Aberta',       3,  3, 3);  -- 12

-- Serviços executados em cada OS (id_os, id_servico, valor_cobrado)
INSERT INTO os_servico (id_os, id_servico, valor_cobrado) VALUES
(1, 5, 120.00), (1, 1, 180.00),
(2, 3, 320.00),
(3, 4, 650.00),
(4, 5, 120.00), (4, 6, 480.00),
(5, 2, 150.00),
(6, 1, 180.00),
(7, 4, 650.00), (7, 2, 150.00),
(8, 9, 350.00),
(9, 8, 200.00),
(10, 7, 750.00),
(11, 3, 320.00),
(12, 5, 120.00);

-- =====================================================================
-- PARTE 4 - CONSULTAS DO TRABALHO (rode para conferir)
-- =====================================================================

-- 3.3 Consulta com INNER JOIN: lista de ordens de serviço
SELECT
    os.id_os                         AS os,
    c.nome                           AS cliente,
    CONCAT(ma.nome, ' ', mo.nome, ' - ', v.placa) AS veiculo,
    me.nome                          AS mecanico,
    DATE_FORMAT(os.data_abertura, '%d/%m/%Y') AS data
FROM ordem_servico os
INNER JOIN cliente  c  ON c.id_cliente   = os.id_cliente
INNER JOIN veiculo  v  ON v.id_veiculo   = os.id_veiculo
INNER JOIN modelo   mo ON mo.id_modelo   = v.id_modelo
INNER JOIN marca    ma ON ma.id_marca    = mo.id_marca
INNER JOIN mecanico me ON me.id_mecanico = os.id_mecanico
ORDER BY os.data_abertura DESC;

-- 3.4 Relatório gerencial (Opção A): mecânicos que mais realizaram serviços
SELECT
    me.nome                          AS mecanico,
    me.especialidade,
    COUNT(oss.id_servico)            AS total_servicos,
    COUNT(DISTINCT os.id_os)         AS total_os,
    COALESCE(SUM(oss.valor_cobrado), 0) AS faturamento
FROM mecanico me
LEFT JOIN ordem_servico os  ON os.id_mecanico = me.id_mecanico
LEFT JOIN os_servico    oss ON oss.id_os      = os.id_os
GROUP BY me.id_mecanico, me.nome, me.especialidade
ORDER BY total_servicos DESC, faturamento DESC;
