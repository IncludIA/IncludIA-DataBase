# 🚀 Includ.IA - Database Module

> **Global Solution 2025 - O Futuro do Trabalho**
>
> *Plataforma de Recrutamento Inclusivo impulsionada por Dados e Inteligência Artificial.*

<div align="center">

![Oracle](https://img.shields.io/badge/Oracle-F80000?style=for-the-badge&logo=oracle&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white)
![PL/SQL](https://img.shields.io/badge/PL%2FSQL-Advanced-black?style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)

[☁️ Acessar Documentação PDF](docs/Relatorio_Tecnico_IncludIA.pdf) • [🔧 Scripts SQL](scripts/) • [🐳 Docker Compose](docker-compose.yml)

</div>

---

## 📖 Sobre o Projeto

O módulo **Database** do **Includ.IA** é a espinha dorsal da nossa plataforma de recrutamento sem viés. Ele foi projetado com uma arquitetura híbrida e robusta para garantir integridade relacional, segurança de dados e flexibilidade para integração com IA Generativa.

### 🎯 Destaques Técnicos
* **Modelagem 3FN:** Estrutura relacional otimizada no Oracle Database 21c.
* **Lógica PL/SQL Avançada:** Packages, Procedures e Functions para regras de negócio complexas.
* **Exportação JSON Manual:** Algoritmo proprietário para converter dados relacionais em documentos JSON sem dependência de funções nativas.
* **Auditoria em Tempo Real:** Triggers que monitoram e registram alterações sensíveis.
* **Persistência Híbrida:** Sincronização de dados transacionais (Oracle) para analíticos (MongoDB).

---

## 📐 Arquitetura e Modelagem

A documentação completa da modelagem de dados está disponível para download no link abaixo.

📄 **[Download do Relatório Técnico (PDF)](docs/Relatorio_Tecnico_IncludIA.pdf)**

### 1. Modelo Lógico (Abstração)
Representação das entidades de negócio e seus relacionamentos (Notação Pé de Galinha / IE).

![Modelo Lógico](image/modelo_logico.png)

### 2. Modelo Físico (Implementação)
Estrutura detalhada com tipos de dados Oracle, chaves estrangeiras e constraints.

![Modelo Físico](image/modelo_fisico.png)

---

## ⚡ Funcionalidades do Banco (PL/SQL)

Todas as regras de negócio estão centralizadas no pacote `PKG_INCLUDIA`.

| Objeto | Tipo | Descrição |
| :--- | :--- | :--- |
| `PRC_INSERIR_CANDIDATO` | Procedure | Realiza o cadastro seguro, validando duplicidade e formato de e-mail via REGEXP. |
| `PRC_REGISTRAR_MATCH` | Procedure | Gerencia o "Swipe", calculando automaticamente o Match mútuo entre Recrutador e Candidato. |
| `FUN_GERAR_JSON` | Function | **Destaque:** Constrói um objeto JSON manualmente (concatenação de strings) para integração com NoSQL/IA. |
| `TRG_AUDIT_CANDIDATO` | Trigger | Registra automaticamente logs de `INSERT`, `UPDATE` ou `DELETE` para conformidade e segurança. |

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
* [Docker Desktop](https://www.docker.com/products/docker-desktop) instalado.
* Cliente SQL (Oracle SQL Developer ou VS Code Oracle Extension).
* Cliente NoSQL (MongoDB Compass ou VS Code Mongo Extension).

### 1. Subindo a Infraestrutura
Utilize o Docker Compose para orquestrar os containers do Oracle XE e MongoDB.

```bash
docker-compose up -d
````

> ⏳ **Aguarde:** A primeira inicialização do Oracle pode levar alguns minutos. Verifique os logs com `docker logs -f includia-oracle` até ver a mensagem `DATABASE IS READY TO USE!`.

### 2\. Credenciais de Acesso

| Serviço | Host | Porta | Usuário | Senha | Database/SID |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Oracle** | `localhost` | `1521` | `SYSTEM` | `oracle` | `XE` |
| **MongoDB** | `localhost` | `27017` | `admin` | `secret` | `includia_db` |

### 3\. Executando os Scripts (Sequência Automática)

Os scripts na pasta `/scripts` são mapeados para execução automática na criação do container, mas podem ser rodados manualmente na seguinte ordem:

1.  **`01_DDL_Criacao_Tabelas.sql`**: Criação das tabelas (`T_INC_...`) e constraints.
2.  **`02_PLSQL_Regras_Negocio.sql`**: Compilação do Package e Triggers.
3.  **`03_DML_Carga_Dados_Exportacao.sql`**: Popula o banco com dados fictícios e testa a geração de JSON.
4.  **`04_NoSQL_Importacao.js`**: Script para importar o JSON gerado no Oracle para o MongoDB.

-----

## 📂 Estrutura do Repositório

```text
IncludIA-DataBase/
├── docs/                       # Documentação Técnica (PDF)
├── docker-compose.yml          # Orquestração de containers
├── image/                      # Diagramas Lógico e Físico
├── scripts/                    # Código Fonte SQL e JS
│   ├── 01_DDL_Criacao_Tabelas.sql
│   ├── 02_PLSQL_Regras_Negocio.sql
│   ├── 03_DML_Carga_Dados_Exportacao.sql
│   └── 04_NoSQL_Importacao.js
└── README.md                   # Este arquivo
```

-----

## 👨‍💻 Autor

Projeto desenvolvido para a **Global Solution 2025 - FIAP**.

  * **Luiz Eduardo Da Silva Pinto** - [RM555213]

-----

*"Tecnologia com propósito para um futuro do trabalho mais justo."*

