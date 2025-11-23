-- ==========================================================
-- FASE 2: PL/SQL AVANÇADO - REGAS DE NEGÓCIO (VERSÃO 2.0)
-- Autor: Luiz Eduardo Da Silva Pinto
-- Descrição: Packages, Validações e Geração de JSON Complexo
-- ==========================================================


-- 2. PACKAGE HEADER
create or replace package pkg_includia as
    -- Procedure de Cadastro Seguro
   procedure prc_inserir_candidato (
      p_nome   in varchar2,
      p_cpf    in varchar2,
      p_email  in varchar2,
      p_senha  in varchar2,
      p_resumo in clob
   );

    -- Procedure de Match
   procedure prc_registrar_match (
      p_id_candidato      in varchar2,
      p_id_vaga           in varchar2,
      p_is_candidato_like in number
   );

    -- Função de Validação (Regex)
   function fun_validar_email (
      p_email in varchar2
   ) return varchar2;

    -- Função de Exportação JSON (AGORA MAIS COMPLEXA!)
   function fun_gerar_json_candidato (
      p_id_candidato in varchar2
   ) return clob;
end pkg_includia;
/

-- 3. PACKAGE BODY
create or replace package body pkg_includia as

    -- Validação de Email
   function fun_validar_email (
      p_email in varchar2
   ) return varchar2 is
   begin
      if regexp_like(
         p_email,
         '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$'
      ) then
         return 'VALIDO';
      else
         return 'INVALIDO';
      end if;
   exception
      when others then
         return 'ERRO_VALIDACAO';
   end fun_validar_email;

    -- Geração de JSON Manual (O "Hardcore" da GS)
    -- Agora busca Skills, Experiências e Formações!
   function fun_gerar_json_candidato (
      p_id_candidato in varchar2
   ) return clob is
      v_json  clob;
      v_cand  t_inc_candidato%rowtype;
      v_count number;
   begin
        -- 1. Dados Pessoais
      select *
        into v_cand
        from t_inc_candidato
       where id_candidato = p_id_candidato;

      v_json := '{';
      v_json := v_json
                || '"id": "'
                || v_cand.id_candidato
                || '",';
      v_json := v_json
                || '"nome": "'
                || v_cand.nome
                || '",';
      v_json := v_json
                || '"email": "'
                || v_cand.email
                || '",';
      v_json := v_json
                || '"resumo": "'
                || dbms_lob.substr(
         v_cand.resumo_perfil,
         200,
         1
      )
                || '",';
        
        -- 2. Array de SKILLS
      v_json := v_json || '"skills": [';
      v_count := 0;
      for r in (
         select s.nome
           from t_inc_skill s
           join t_inc_candidato_skill cs
         on s.id_skill = cs.id_skill
          where cs.id_candidato = p_id_candidato
      ) loop
         if v_count > 0 then
            v_json := v_json || ',';
         end if;
         v_json := v_json
                   || '"'
                   || r.nome
                   || '"';
         v_count := v_count + 1;
      end loop;
      v_json := v_json || '],';

        -- 3. Array de EXPERIÊNCIAS (Novo!)
      v_json := v_json || '"experiencias": [';
      v_count := 0;
      for r in (
         select titulo_cargo,
                tipo_emprego
           from t_inc_experiencia
          where id_candidato = p_id_candidato
      ) loop
         if v_count > 0 then
            v_json := v_json || ',';
         end if;
         v_json := v_json
                   || '{"cargo": "'
                   || r.titulo_cargo
                   || '", "tipo": "'
                   || r.tipo_emprego
                   || '"}';
         v_count := v_count + 1;
      end loop;
      v_json := v_json || ']';
      v_json := v_json || '}';
      return v_json;
   exception
      when no_data_found then
         return '{"erro": "Candidato não encontrado"}';
      when others then
         return '{"erro": "Falha na geração do JSON"}';
   end fun_gerar_json_candidato;

    -- Inserir Candidato
   procedure prc_inserir_candidato (
      p_nome   in varchar2,
      p_cpf    in varchar2,
      p_email  in varchar2,
      p_senha  in varchar2,
      p_resumo in clob
   ) is
      v_uuid varchar2(36);
   begin
      if fun_validar_email(p_email) = 'INVALIDO' then
         raise_application_error(
            -20001,
            'Email inválido.'
         );
      end if;
      v_uuid := lower(rawtohex(sys_guid()));
      insert into t_inc_candidato (
         id_candidato,
         nome,
         cpf,
         email,
         senha_hash,
         resumo_perfil
      ) values ( v_uuid,
                 p_nome,
                 p_cpf,
                 p_email,
                 p_senha,
                 p_resumo );
      commit;
   exception
      when dup_val_on_index then
         raise_application_error(
            -20002,
            'CPF/Email já existe.'
         );
   end prc_inserir_candidato;

    -- Registrar Match
   procedure prc_registrar_match (
      p_id_candidato      in varchar2,
      p_id_vaga           in varchar2,
      p_is_candidato_like in number
   ) is
      v_uuid varchar2(36);
   begin
      update t_inc_match
         set liked_by_candidate = p_is_candidato_like,
             status =
                case
                   when liked_by_recruiter = 1
                      and p_is_candidato_like = 1 then
                      'MATCHED'
                   else
                      'PENDENTE'
                end
       where id_candidato = p_id_candidato
         and id_vaga = p_id_vaga;

      if sql%rowcount = 0 then
         v_uuid := lower(rawtohex(sys_guid()));
         insert into t_inc_match (
            id_match,
            id_candidato,
            id_vaga,
            liked_by_candidate,
            status
         ) values ( v_uuid,
                    p_id_candidato,
                    p_id_vaga,
                    p_is_candidato_like,
                    'PENDENTE' );
      end if;
      commit;
   end prc_registrar_match;

end pkg_includia;
/

-- 4. TRIGGER DE AUDITORIA
create or replace trigger trg_audit_candidato after
   insert or update or delete on t_inc_candidato
   for each row
declare
   v_op varchar2(20);
begin
   if inserting then
      v_op := 'INSERT';
   elsif updating then
      v_op := 'UPDATE';
   elsif deleting then
      v_op := 'DELETE';
   end if;

   insert into t_inc_log_auditoria (
      nome_tabela,
      operacao,
      usuario_db,
      dados_antigos
   ) values ( 'T_INC_CANDIDATO',
              v_op,
              user,
              'Nome: ' || :old.nome );
end;
/