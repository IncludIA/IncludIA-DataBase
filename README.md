# 🚀 Includ.IA - Database Module

> **Global Solution 2025 - O Futuro do Trabalho**
>
> *Recrutamento Inclusivo impulsionado por Dados e Inteligência Artificial.*

![Oracle](https://img.shields.io/badge/Oracle-F80000?style=for-the-badge&logo=oracle&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white)
![PL/SQL](https://img.shields.io/badge/PL%2FSQL-Advanced-black?style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

---

## 📖 Sobre o Projeto

O módulo **Database** do **Includ.IA** é a espinha dorsal da nossa plataforma de recrutamento sem viés. Ele foi projetado com uma arquitetura híbrida e robusta para garantir integridade relacional, segurança de dados e flexibilidade para integração com IA.

### 🎯 Destaques Técnicos
* **Modelagem 3FN:** Estrutura relacional otimizada no Oracle Database 21c.
* **PL/SQL Avançado:** Lógica de negócios encapsulada em Packages, com validações via REGEXP.
* **Integração Manual JSON:** Função exclusiva para converter dados relacionais em JSON sem dependência de funções nativas, pronta para exportação.
* **Auditoria Ativa:** Triggers que monitoram alterações sensíveis em tempo real.
* **Persistência Poliglota:** Sincronização de dados entre Oracle (SQL) e MongoDB (NoSQL).
* **Infraestrutura como Código:** Ambiente containerizado com Docker Compose.

---

## 🏗️ Arquitetura de Dados

A solução utiliza dois motores de banco de dados trabalhando em conjunto:

1.  **Oracle Database (Source of Truth):** Armazena dados estruturados, relacionamentos entre candidatos, vagas e empresas, e gerencia a lógica transacional.
2.  **MongoDB (Read/Analytics):** Recebe os dados consolidados em formato JSON para consultas de alta performance e alimentação dos modelos de IA Generativa.

### 📐 Diagrama Relacional (Modelo Físico)
*(Certifique-se de que a imagem esteja na pasta `image` com este nome ou ajuste o link abaixo)*

![Modelo Físico](image/Captura%20de%20tela%202025-11-22%20150840.png)

---

## ⚡ Funcionalidades do Banco (PL/SQL)

Todas as regras de negócio estão centralizadas no pacote `PKG_INCLUDIA`.

| Objeto | Tipo | Descrição |
| :--- | :--- | :--- |
| `PRC_INSERIR_CANDIDATO` | Procedure | Realiza o cadastro seguro, validando duplicidade e formato de e-mail. |
| `PRC_REGISTRAR_MATCH` | Procedure | Gerencia o "Swipe", calculando se houve Match mútuo entre Recrutador e Candidato. |
| `FUN_VALIDAR_EMAIL` | Function | Validação robusta utilizando Expressões Regulares (`REGEXP_LIKE`). |
| `FUN_GERAR_JSON` | Function | **Destaque:** Constrói um objeto JSON manualmente (concatenação de strings) a partir de dados relacionais complexos. |
| `TRG_AUDIT_CANDIDATO` | Trigger | Registra automaticamente qualquer `INSERT`, `UPDATE` ou `DELETE` na tabela de auditoria. |

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
* [Docker Desktop](https://www.docker.com/products/docker-desktop) instalado.
* Cliente SQL (Oracle SQL Developer, VS Code Oracle Extension ou DBeaver).
* Cliente MongoDB (MongoDB Compass ou VS Code Mongo Extension).

### 1. Subindo a Infraestrutura
Utilizamos Docker Compose para orquestrar o Oracle XE e o MongoDB. Na raiz do projeto, execute:

```bash
docker-compose up -d
````

*Aguarde até que o log do Oracle exiba: `DATABASE IS READY TO USE!`.*

### 2\. Conectando ao Banco de Dados

Configure seu cliente Oracle com as credenciais abaixo:

  * **Hostname:** `localhost`
  * **Port:** `1521`
  * **User:** `SYSTEM`
  * **Password:** `oracle`
  * **SID / Service Name:** `XE`

### 3\. Executando os Scripts (Ordem Obrigatória)

Os scripts estão numerados na pasta `/scripts` para facilitar a execução sequencial:

1.  **`01_DDL_Criacao_Tabelas.sql`**: Cria as tabelas (`T_INC_...`), constraints e relacionamentos.
2.  **`02_PLSQL_Regras_Negocio.sql`**: Compila o Package, Procedures, Functions e Triggers.
3.  **`03_DML_Carga_Dados_Exportacao.sql`**:
      * Popula o banco com dados de teste (Skills, Empresas).
      * Testa a inserção de candidatos via Procedure.
      * **Executa a função de geração de JSON** e exibe o resultado no console (DBMS Output).

### 4\. Integração NoSQL (Fase Final)

Após gerar o JSON no passo anterior, execute o script no **MongoDB**:

  * Arquivo: **`scripts/04_NoSQL_Importacao.js`**
  * Conexão Mongo: `mongodb://admin:secret@localhost:27017`

Este script importará os documentos gerados e executará consultas de validação.

-----

## 📂 Estrutura de Pastas

```text
IncludIA-DataBase/
├── docker-compose.yml          # Definição dos containers (Oracle + Mongo)
├── README.md                   # Documentação do projeto
├── image/                      # Evidências e diagramas
│   └── ...                     # Imagens do Data Modeler
└── scripts/                    # Código Fonte SQL/JS
    ├── 01_DDL_Criacao_Tabelas.sql
    ├── 02_PLSQL_Regras_Negocio.sql
    ├── 03_DML_Carga_Dados_Exportacao.sql
    └── 04_NoSQL_Importacao.js
```

-----

## 👨‍💻 Autor

Projeto desenvolvido para a Global Solution 2025 - FIAP.

  * **Luiz Eduardo Da Silva Pinto** - [RM555213]
