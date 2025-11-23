-- ==========================================================
-- FASE 3: DML - CARGA DE DADOS (VERSÃO 2.0)
-- Autor: Luiz Eduardo Da Silva Pinto
-- ==========================================================

-- 1. LIMPEZA DE DADOS (Delete sem Drop, para testes rápidos)
delete from t_inc_mensagem;
delete from t_inc_chat;
delete from t_inc_match;
delete from t_inc_vaga_skill;
delete from t_inc_vaga;
delete from t_inc_candidato_skill;
delete from t_inc_recrutador;
delete from t_inc_empresa;
delete from t_inc_skill;
delete from t_inc_candidato;
commit;

-- 2. INSERIR SKILLS
insert into t_inc_skill (
   id_skill,
   nome,
   tipo_skill
) values ( 's01',
           'Java Advanced',
           'HARD_SKILL' );
insert into t_inc_skill (
   id_skill,
   nome,
   tipo_skill
) values ( 's02',
           'Oracle PL/SQL',
           'HARD_SKILL' );
insert into t_inc_skill (
   id_skill,
   nome,
   tipo_skill
) values ( 's03',
           'Inteligência Emocional',
           'SOFT_SKILL' );
insert into t_inc_skill (
   id_skill,
   nome,
   tipo_skill
) values ( 's04',
           'React Native',
           'HARD_SKILL' );
commit;

-- 3. INSERIR EMPRESA (CORRIGIDO: Sem campo cultura, com foto_logo)
insert into t_inc_empresa (
   id_empresa,
   nome_oficial,
   nome_fantasia,
   cnpj,
   localizacao,
   descricao,
   foto_logo,
   is_verificado
) values ( 'e01',
           'Tech Solutions S.A.',
           'TechSol',
           '12.345.678/0001-99',
           'São Paulo, SP',
           'Empresa focada em inovação.',
           'logo.png',
           1 );
commit;

-- 4. INSERIR CANDIDATOS (Via Procedure - Fase 2)
begin
   pkg_includia.prc_inserir_candidato(
      'João da Silva',
      '123.456.789-00',
      'joao@email.com',
      'senha123',
      'Dev Java apaixonado.'
   );
   pkg_includia.prc_inserir_candidato(
      'Maria Souza',
      '987.654.321-11',
      'maria@email.com',
      'senha456',
      'Líder técnica.'
   );
end;
/

-- 5. VINCULAR SKILLS (Manual)
declare
   v_id_joao varchar2(36);
begin
   select id_candidato
     into v_id_joao
     from t_inc_candidato
    where email = 'joao@email.com';
   insert into t_inc_candidato_skill (
      id_candidato,
      id_skill
   ) values ( v_id_joao,
              's01' );
   insert into t_inc_candidato_skill (
      id_candidato,
      id_skill
   ) values ( v_id_joao,
              's04' );
   commit;
end;
/

-- 6. TESTE DE GERAÇÃO JSON
declare
   v_json      clob;
   v_id_target varchar2(36);
begin
   select id_candidato
     into v_id_target
     from t_inc_candidato
    where email = 'joao@email.com';
   v_json := pkg_includia.fun_gerar_json_candidato(v_id_target);
   dbms_output.put_line('--- JSON ---');
   dbms_output.put_line(v_json);
end;
/