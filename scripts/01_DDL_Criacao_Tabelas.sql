-- ==========================================================
-- FASE 1: DDL - CRIAÇÃO DAS TABELAS (INCLUD.IA)
-- Autor: Luiz Eduardo Da Silva Pinto (Global Solution 2025)
-- Descrição: Criação da estrutura relacional normalizada (3FN)
-- ==========================================================

-- 1. TABELA DE EMPRESAS
create table t_inc_empresa (
   id_empresa    varchar2(36) primary key, -- UUID gerado pelo Backend
   nome_oficial  varchar2(100) not null,
   nome_fantasia varchar2(100),
   cnpj          varchar2(18) unique not null,
   localizacao   varchar2(100),
   descricao     clob,
   cultura       clob,
   foto_logo     varchar2(255),
   foto_capa_url varchar2(255),
    
    -- Flags de Controle (0 = False, 1 = True)
   is_verificado number(1) default 0 check ( is_verificado in ( 0,
                                                                1 ) ),
   is_ative      number(1) default 1 check ( is_ative in ( 0,
                                                      1 ) )
);

-- 2. TABELA DE RECRUTADORES (Depende de Empresa)
create table t_inc_recrutador (
   id_recrutador   varchar2(36) primary key,
   nome            varchar2(100) not null,
   email           varchar2(100) unique not null,
   senha_hash      varchar2(255) not null,
   foto_perfil_url varchar2(255),
    
    -- Status
   is_ative        number(1) default 1 check ( is_ative in ( 0,
                                                      1 ) ),
   is_online       number(1) default 0 check ( is_online in ( 0,
                                                        1 ) ),
    
    -- Chave Estrangeira
   id_empresa      varchar2(36) not null,
   constraint fk_recrutador_empresa foreign key ( id_empresa )
      references t_inc_empresa ( id_empresa )
);

-- 3. TABELA DE CANDIDATOS (Talentos)
create table t_inc_candidato (
   id_candidato        varchar2(36) primary key,
   nome                varchar2(100) not null,
   cpf                 varchar2(14) unique not null,
   email               varchar2(100) unique not null,
   senha_hash          varchar2(255) not null,
    
    -- Endereço
   cep                 varchar2(10),
   logradouro          varchar2(150),
   numero              varchar2(20),
   bairro              varchar2(100),
   cidade              varchar2(100),
   estado              varchar2(50),
   raio_busca_km       number(5),
    
    -- Perfil Profissional e IA
   resumo_perfil       clob,
   resumo_inclusivo_ia clob, -- Gerado pela IA para anonimização
   foto_perfil_url     varchar2(255),
    
    -- Status
   is_ative            number(1) default 1 check ( is_ative in ( 0,
                                                      1 ) ),
   is_online           number(1) default 0 check ( is_online in ( 0,
                                                        1 ) )
);

-- 4. TABELA DE SKILLS (Competências Hard e Soft)
create table t_inc_skill (
   id_skill   varchar2(36) primary key,
   nome       varchar2(100) unique not null,
   tipo_skill varchar2(20) check ( tipo_skill in ( 'HARD_SKILL',
                                                   'SOFT_SKILL' ) )
);

-- 5. TABELA ASSOCIATIVA: CANDIDATO x SKILLS
create table t_inc_candidato_skill (
   id_candidato varchar2(36) not null,
   id_skill     varchar2(36) not null,
   primary key ( id_candidato,
                 id_skill ),
   constraint fk_cs_candidato foreign key ( id_candidato )
      references t_inc_candidato ( id_candidato ),
   constraint fk_cs_skill foreign key ( id_skill )
      references t_inc_skill ( id_skill )
);

-- 6. TABELA DE VAGAS (Jobs - Depende de Recrutador e Empresa)
create table t_inc_vaga (
   id_vaga             varchar2(36) primary key,
   id_recrutador       varchar2(36) not null,
   id_empresa          varchar2(36) not null,
   titulo              varchar2(100) not null,
   descricao_original  clob not null,
   descricao_inclusiva clob, -- Texto reescrito pela IA
    
    -- Detalhes da Vaga
   localizacao         varchar2(100),
   tipo_vaga           varchar2(50), -- Ex: TEMPO_INTEGRAL, ESTAGIO
   modelo_trabalho     varchar2(20) check ( modelo_trabalho in ( 'PRESENCIAL',
                                                             'HIBRIDO',
                                                             'REMOTO' ) ),
   salario_min         number(10,2),
   salario_max         number(10,2),
   beneficios          clob,
   experiencia_req     clob,
    
    -- Controle
   is_ativa            number(1) default 1 check ( is_ativa in ( 0,
                                                      1 ) ),
   created_at          timestamp default systimestamp,
    
    -- Chaves Estrangeiras
   constraint fk_vaga_recrutador foreign key ( id_recrutador )
      references t_inc_recrutador ( id_recrutador ),
   constraint fk_vaga_empresa foreign key ( id_empresa )
      references t_inc_empresa ( id_empresa )
);

-- 7. TABELA ASSOCIATIVA: VAGA x SKILLS (Requisitos da Vaga)
create table t_inc_vaga_skill (
   id_vaga  varchar2(36) not null,
   id_skill varchar2(36) not null,
   primary key ( id_vaga,
                 id_skill ),
   constraint fk_vs_vaga foreign key ( id_vaga )
      references t_inc_vaga ( id_vaga ),
   constraint fk_vs_skill foreign key ( id_skill )
      references t_inc_skill ( id_skill )
);

-- 8. TABELA DE MATCHES (Interação Candidato <-> Vaga)
create table t_inc_match (
   id_match           varchar2(36) primary key,
   id_candidato       varchar2(36) not null,
   id_vaga            varchar2(36) not null,
   match_score        number(5,2), -- Ex: 85.50%
   status             varchar2(30) check ( status in ( 'PENDENTE',
                                           'MATCHED',
                                           'REJEITADO_CANDIDATO',
                                           'REJEITADO_RECRUTADOR' ) ),
    
    -- Controle de Likes
   liked_by_candidate number(1) default 0 check ( liked_by_candidate in ( 0,
                                                                          1 ) ),
   liked_by_recruiter number(1) default 0 check ( liked_by_recruiter in ( 0,
                                                                          1 ) ),
    
    -- Chaves Estrangeiras
   constraint fk_match_candidato foreign key ( id_candidato )
      references t_inc_candidato ( id_candidato ),
   constraint fk_match_vaga foreign key ( id_vaga )
      references t_inc_vaga ( id_vaga ),
        
    -- Regra de Negócio: Um candidato só pode dar match uma vez na mesma vaga
   constraint unq_match_pair unique ( id_candidato,
                                      id_vaga )
);

-- 9. TABELA DE AUDITORIA (Log de Segurança)
create table t_inc_log_auditoria (
   id_log        number generated by default as identity primary key,
   nome_tabela   varchar2(50),
   operacao      varchar2(20), -- INSERT, UPDATE, DELETE
   usuario_db    varchar2(50),
   data_hora     timestamp default systimestamp,
   dados_antigos clob
);