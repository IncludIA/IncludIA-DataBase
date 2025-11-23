-- ==========================================================
-- GLOBAL SOLUTION 2025 - INCLUD.IA
-- FASE 1: DDL - CRIAÇÃO COMPLETA DAS TABELAS (Oracle SQL)
-- Autor: Luiz Eduardo Da Silva Pinto
-- Versão: 2.0 (Atualizada com Logo, Verificado e Entidades Faltantes)
-- ==========================================================


-- 1. TABELA DE EMPRESAS (Atualizada)
create table t_inc_empresa (
   id_empresa    varchar2(36) primary key,
   nome_oficial  varchar2(100) not null,
   nome_fantasia varchar2(100),
   cnpj          varchar2(18) unique not null,
   localizacao   varchar2(100),
   descricao     clob,
   foto_logo     varchar2(255),
   foto_capa_url varchar2(255),
    
    -- Flags
   is_verificado number(1) default 0 check ( is_verificado in ( 0,
                                                                1 ) ),
   is_ative      number(1) default 1 check ( is_ative in ( 0,
                                                      1 ) )
);

-- 2. TABELA DE RECRUTADORES
create table t_inc_recrutador (
   id_recrutador   varchar2(36) primary key,
   nome            varchar2(100) not null,
   email           varchar2(100) unique not null,
   senha_hash      varchar2(255) not null,
   foto_perfil_url varchar2(255),
   is_ative        number(1) default 1 check ( is_ative in ( 0,
                                                      1 ) ),
   is_online       number(1) default 0 check ( is_online in ( 0,
                                                        1 ) ),
   id_empresa      varchar2(36) not null,
   constraint fk_recrutador_empresa foreign key ( id_empresa )
      references t_inc_empresa ( id_empresa )
);

-- 3. TABELA DE CANDIDATOS
create table t_inc_candidato (
   id_candidato        varchar2(36) primary key,
   nome                varchar2(100) not null,
   cpf                 varchar2(14) unique not null,
   email               varchar2(100) unique not null,
   senha_hash          varchar2(255) not null,
   cep                 varchar2(10),
   logradouro          varchar2(150),
   numero              varchar2(20),
   bairro              varchar2(100),
   cidade              varchar2(100),
   estado              varchar2(50),
   raio_busca_km       number(5),
   resumo_perfil       clob,
   resumo_inclusivo_ia clob,
   foto_perfil_url     varchar2(255),
   is_ative            number(1) default 1 check ( is_ative in ( 0,
                                                      1 ) ),
   is_online           number(1) default 0 check ( is_online in ( 0,
                                                        1 ) )
);

-- 4. TABELA DE SKILLS
create table t_inc_skill (
   id_skill   varchar2(36) primary key,
   nome       varchar2(100) unique not null,
   tipo_skill varchar2(20) check ( tipo_skill in ( 'HARD_SKILL',
                                                   'SOFT_SKILL' ) )
);

-- 5. ASSOCIATIVA: CANDIDATO x SKILLS
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

-- 6. TABELA DE VAGAS
create table t_inc_vaga (
   id_vaga             varchar2(36) primary key,
   id_recrutador       varchar2(36) not null,
   id_empresa          varchar2(36) not null,
   titulo              varchar2(100) not null,
   descricao_original  clob not null,
   descricao_inclusiva clob,
   localizacao         varchar2(100),
   tipo_vaga           varchar2(50),
   modelo_trabalho     varchar2(20) check ( modelo_trabalho in ( 'PRESENCIAL',
                                                             'HIBRIDO',
                                                             'REMOTO' ) ),
   salario_min         number(10,2),
   salario_max         number(10,2),
   beneficios          clob,
   experiencia_req     clob,
   is_ativa            number(1) default 1 check ( is_ativa in ( 0,
                                                      1 ) ),
   created_at          timestamp default systimestamp,
   constraint fk_vaga_recrutador foreign key ( id_recrutador )
      references t_inc_recrutador ( id_recrutador ),
   constraint fk_vaga_empresa foreign key ( id_empresa )
      references t_inc_empresa ( id_empresa )
);

-- 7. ASSOCIATIVA: VAGA x SKILLS
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

-- 8. TABELA DE MATCHES
create table t_inc_match (
   id_match           varchar2(36) primary key,
   id_candidato       varchar2(36) not null,
   id_vaga            varchar2(36) not null,
   match_score        number(5,2),
   status             varchar2(30) check ( status in ( 'PENDENTE',
                                           'MATCHED',
                                           'REJEITADO_CANDIDATO',
                                           'REJEITADO_RECRUTADOR' ) ),
   liked_by_candidate number(1) default 0 check ( liked_by_candidate in ( 0,
                                                                          1 ) ),
   liked_by_recruiter number(1) default 0 check ( liked_by_recruiter in ( 0,
                                                                          1 ) ),
   constraint fk_match_candidato foreign key ( id_candidato )
      references t_inc_candidato ( id_candidato ),
   constraint fk_match_vaga foreign key ( id_vaga )
      references t_inc_vaga ( id_vaga ),
   constraint unq_match_pair unique ( id_candidato,
                                      id_vaga )
);

-- ==========================================================
-- ENTIDADES FALTANTES ADICIONADAS ABAIXO
-- ==========================================================

-- 9. TABELA DE EXPERIÊNCIA PROFISSIONAL
create table t_inc_experiencia (
   id_experiencia varchar2(36) primary key,
   titulo_cargo   varchar2(100) not null,
   tipo_emprego   varchar2(50) not null,
   data_inicio    date not null,
   data_fim       date,
   descricao      clob,
   id_candidato   varchar2(36) not null,
   id_empresa     varchar2(36),
   constraint fk_exp_candidato foreign key ( id_candidato )
      references t_inc_candidato ( id_candidato ),
   constraint fk_exp_empresa foreign key ( id_empresa )
      references t_inc_empresa ( id_empresa )
);

-- 10. TABELA DE FORMAÇÃO ACADÊMICA
create table t_inc_formacao (
   id_formacao      varchar2(36) primary key,
   nome_instituicao varchar2(100) not null,
   grau             number(2) not null, -- Enum Ordinal (0,1,2...)
   area_estudo      varchar2(100),
   data_inicio      date not null,
   data_fim         date,
   descricao        clob,
   id_candidato     varchar2(36) not null,
   constraint fk_form_candidato foreign key ( id_candidato )
      references t_inc_candidato ( id_candidato )
);

-- 11. TABELA DE VOLUNTARIADO
create table t_inc_voluntariado (
   id_voluntariado varchar2(36) primary key,
   organizacao     varchar2(100) not null,
   funcao          varchar2(100) not null,
   descricao       clob,
   data_inicio     date not null,
   data_fim        date,
   id_candidato    varchar2(36) not null,
   constraint fk_vol_candidato foreign key ( id_candidato )
      references t_inc_candidato ( id_candidato )
);

-- 12. TABELA DE IDIOMAS (Catálogo)
create table t_inc_idioma (
   id_idioma varchar2(36) primary key,
   nome      number(2) unique not null -- Enum Ordinal do Java
);

-- 13. TABELA ASSOCIATIVA: CANDIDATO x IDIOMA
create table t_inc_candidato_idioma (
   id                 varchar2(36) primary key,
   id_candidato       varchar2(36) not null,
   id_idioma          varchar2(36) not null,
   nivel_proficiencia varchar2(20) not null, -- Enum String (BASICO, FLUENTE...)
   constraint fk_ci_candidato foreign key ( id_candidato )
      references t_inc_candidato ( id_candidato ),
   constraint fk_ci_idioma foreign key ( id_idioma )
      references t_inc_idioma ( id_idioma ),
   constraint unq_cand_idioma unique ( id_candidato,
                                       id_idioma )
);

-- 14. VAGAS SALVAS (Candidato salvou Vaga)
create table t_inc_vaga_salva (
   id           varchar2(36) primary key,
   id_candidato varchar2(36) not null,
   id_vaga      varchar2(36) not null,
   saved_at     timestamp default systimestamp not null,
   constraint fk_vs_candidato_salva foreign key ( id_candidato )
      references t_inc_candidato ( id_candidato ),
   constraint fk_vs_vaga_salva foreign key ( id_vaga )
      references t_inc_vaga ( id_vaga ),
   constraint unq_vaga_salva unique ( id_candidato,
                                      id_vaga )
);

-- 15. CANDIDATOS SALVOS (Recrutador salvou Candidato)
create table t_inc_candidato_salvo (
   id            varchar2(36) primary key,
   id_recrutador varchar2(36) not null,
   id_candidato  varchar2(36) not null,
   saved_at      timestamp default systimestamp not null,
   constraint fk_cs_recrutador foreign key ( id_recrutador )
      references t_inc_recrutador ( id_recrutador ),
   constraint fk_cs_candidato_salvo foreign key ( id_candidato )
      references t_inc_candidato ( id_candidato ),
   constraint unq_cand_salvo unique ( id_recrutador,
                                      id_candidato )
);

-- 16. VISUALIZAÇÕES DE PERFIL (Analytics)
create table t_inc_visualizacao (
   id            varchar2(36) primary key,
   id_recrutador varchar2(36) not null,
   id_candidato  varchar2(36) not null,
   viewed_at     timestamp default systimestamp not null,
   constraint fk_vis_recrutador foreign key ( id_recrutador )
      references t_inc_recrutador ( id_recrutador ),
   constraint fk_vis_candidato foreign key ( id_candidato )
      references t_inc_candidato ( id_candidato )
);

-- 17. NOTIFICAÇÕES
create table t_inc_notificacao (
   id            varchar2(36) primary key,
   id_recrutador varchar2(36),
   id_candidato  varchar2(36),
   tipo          varchar2(50) not null,
   mensagem      clob not null,
   is_read       number(1) default 0 check ( is_read in ( 0,
                                                    1 ) ),
   created_at    timestamp default systimestamp not null,
   constraint fk_not_recrutador foreign key ( id_recrutador )
      references t_inc_recrutador ( id_recrutador ),
   constraint fk_not_candidato foreign key ( id_candidato )
      references t_inc_candidato ( id_candidato )
);

-- 18. CHAT
create table t_inc_chat (
   id_chat    varchar2(36) primary key,
   id_match   varchar2(36) unique not null,
   created_at timestamp default systimestamp not null,
   is_ative   number(1) default 1 check ( is_ative in ( 0,
                                                      1 ) ),
   constraint fk_chat_match foreign key ( id_match )
      references t_inc_match ( id_match )
);

-- 19. MENSAGENS DO CHAT
create table t_inc_mensagem (
   id_mensagem varchar2(36) primary key,
   id_chat     varchar2(36) not null,
   conteudo    clob not null,
   timestamp   timestamp default systimestamp not null,
   sender_id   varchar2(36) not null,
   receiver_id varchar2(36) not null,
   is_read     number(1) default 0 check ( is_read in ( 0,
                                                    1 ) ),
   constraint fk_msg_chat foreign key ( id_chat )
      references t_inc_chat ( id_chat )
);