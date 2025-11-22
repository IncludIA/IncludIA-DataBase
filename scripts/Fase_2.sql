-- ==========================================================
-- FASE 2: PL/SQL AVANÇADO - LÓGICA E INTEGRAÇÃO
-- Autor: Luiz Eduardo Da Silva Pinto (Global Solution 2025)
-- ==========================================================

-- 1. SEQUENCE PARA AUDITORIA (Garantia de ID único para os logs)
CREATE SEQUENCE SEQ_LOG_AUDITORIA START WITH 1 INCREMENT BY 1;

-- 2. PACKAGE SPECIFICATION (O "Menu" do pacote)
CREATE OR REPLACE PACKAGE PKG_INCLUDIA AS
    -- Procedure para inserir candidato com segurança e validação
    PROCEDURE PRC_INSERIR_CANDIDATO(
        p_nome IN VARCHAR2,
        p_cpf IN VARCHAR2,
        p_email IN VARCHAR2,
        p_senha IN VARCHAR2,
        p_resumo IN CLOB
    );

    -- Procedure para registrar Match (Like/Dislike)
    PROCEDURE PRC_REGISTRAR_MATCH(
        p_id_candidato IN VARCHAR2,
        p_id_vaga IN VARCHAR2,
        p_is_candidato_like IN NUMBER
    );

    -- Função 1: Validação de Email com REGEXP (Requisito da GS)
    FUNCTION FUN_VALIDAR_EMAIL(p_email IN VARCHAR2) RETURN VARCHAR2;

    -- Função 2: Gerar JSON Manualmente (Requisito "Hardcore" - Sem JSON_OBJECT)
    FUNCTION FUN_GERAR_JSON_CANDIDATO(p_id_candidato IN VARCHAR2) RETURN CLOB;
END PKG_INCLUDIA;
/

-- 3. PACKAGE BODY (A implementação do código)
CREATE OR REPLACE PACKAGE BODY PKG_INCLUDIA AS

    -- ==========================================================
    -- FUNÇÃO 1: VALIDAÇÃO COM REGEXP
    -- Verifica se o email tem formato válido (ex: texto@texto.com)
    -- ==========================================================
    FUNCTION FUN_VALIDAR_EMAIL(p_email IN VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        -- Expressão regular para validar formato de email
        IF REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$') THEN
            RETURN 'VALIDO';
        ELSE
            RETURN 'INVALIDO';
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'ERRO_VALIDACAO';
    END FUN_VALIDAR_EMAIL;

    -- ==========================================================
    -- FUNÇÃO 2: JSON MANUAL (CONCATENAÇÃO DE STRINGS)
    -- Gera JSON na "unha" para cumprir o requisito de não usar funções nativas
    -- ==========================================================
    FUNCTION FUN_GERAR_JSON_CANDIDATO(p_id_candidato IN VARCHAR2) RETURN CLOB IS
        v_json CLOB;
        v_cand T_INC_CANDIDATO%ROWTYPE;
        v_count NUMBER := 0;
    BEGIN
        -- Busca os dados do candidato
        SELECT * INTO v_cand FROM T_INC_CANDIDATO WHERE ID_CANDIDATO = p_id_candidato;

        -- Inicia a construção do JSON manualmente
        v_json := '{';
        v_json := v_json || '"id": "' || v_cand.ID_CANDIDATO || '",';
        v_json := v_json || '"nome": "' || v_cand.NOME || '",';
        v_json := v_json || '"email": "' || v_cand.EMAIL || '",';
        v_json := v_json || '"resumo": "' || DBMS_LOB.SUBSTR(v_cand.RESUMO_PERFIL, 1000, 1) || '",';
        
        -- Abre array de skills
        v_json := v_json || '"skills": [';
        
        -- Loop para adicionar as skills do candidato
        FOR r IN (
            SELECT S.NOME 
            FROM T_INC_SKILL S 
            JOIN T_INC_CANDIDATO_SKILL CS ON S.ID_SKILL = CS.ID_SKILL 
            WHERE CS.ID_CANDIDATO = p_id_candidato
        ) LOOP
            IF v_count > 0 THEN 
                v_json := v_json || ','; 
            END IF;
            v_json := v_json || '"' || r.NOME || '"';
            v_count := v_count + 1;
        END LOOP;
        
        -- Fecha array e objeto
        v_json := v_json || ']';
        v_json := v_json || '}';
        
        RETURN v_json;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '{"erro": "Candidato não encontrado"}';
        WHEN OTHERS THEN
            RETURN '{"erro": "Falha ao gerar JSON: ' || SQLERRM || '"}';
    END FUN_GERAR_JSON_CANDIDATO;

    -- ==========================================================
    -- PROCEDURE: INSERIR CANDIDATO
    -- ==========================================================
    PROCEDURE PRC_INSERIR_CANDIDATO(
        p_nome IN VARCHAR2,
        p_cpf IN VARCHAR2,
        p_email IN VARCHAR2,
        p_senha IN VARCHAR2,
        p_resumo IN CLOB
    ) IS
        v_uuid VARCHAR2(36);
    BEGIN
        -- 1. Valida o Email usando a função interna
        IF FUN_VALIDAR_EMAIL(p_email) = 'INVALIDO' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Erro: Formato de e-mail inválido.');
        END IF;

        -- 2. Gera um UUID (simulado com SYS_GUID)
        v_uuid := LOWER(RAWTOHEX(SYS_GUID())); 
        
        -- 3. Insere na tabela
        INSERT INTO T_INC_CANDIDATO (ID_CANDIDATO, NOME, CPF, EMAIL, SENHA_HASH, RESUMO_PERFIL)
        VALUES (v_uuid, p_nome, p_cpf, p_email, p_senha, p_resumo);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Candidato inserido com sucesso! ID: ' || v_uuid);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20002, 'Erro: CPF ou Email já cadastrado.');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20003, 'Erro ao inserir candidato: ' || SQLERRM);
    END PRC_INSERIR_CANDIDATO;

    -- ==========================================================
    -- PROCEDURE: REGISTRAR MATCH
    -- ==========================================================
    PROCEDURE PRC_REGISTRAR_MATCH(
        p_id_candidato IN VARCHAR2,
        p_id_vaga IN VARCHAR2,
        p_is_candidato_like IN NUMBER
    ) IS
        v_uuid VARCHAR2(36);
        v_liked_recruiter NUMBER;
    BEGIN
        -- Tenta atualizar se já existir um registo (ex: recrutador já deu like antes)
        UPDATE T_INC_MATCH 
        SET LIKED_BY_CANDIDATE = p_is_candidato_like,
            STATUS = CASE 
                        WHEN LIKED_BY_RECRUITER = 1 AND p_is_candidato_like = 1 THEN 'MATCHED' 
                        WHEN p_is_candidato_like = 0 THEN 'REJEITADO_CANDIDATO'
                        ELSE 'PENDENTE' 
                     END
        WHERE ID_CANDIDATO = p_id_candidato AND ID_VAGA = p_id_vaga;

        -- Se não atualizou nenhuma linha, cria um novo registo
        IF SQL%ROWCOUNT = 0 THEN
            v_uuid := LOWER(RAWTOHEX(SYS_GUID()));
            INSERT INTO T_INC_MATCH (ID_MATCH, ID_CANDIDATO, ID_VAGA, LIKED_BY_CANDIDATE, STATUS)
            VALUES (v_uuid, p_id_candidato, p_id_vaga, p_is_candidato_like, 'PENDENTE');
        END IF;
        
        COMMIT;
    END PRC_REGISTRAR_MATCH;

END PKG_INCLUDIA;
/

-- 4. TRIGGER DE AUDITORIA (Monitora alterações na tabela de Candidatos)
CREATE OR REPLACE TRIGGER TRG_AUDIT_CANDIDATO
AFTER INSERT OR UPDATE OR DELETE ON T_INC_CANDIDATO
FOR EACH ROW
DECLARE
    v_operacao VARCHAR2(20);
    v_dados CLOB;
BEGIN
    IF INSERTING THEN 
        v_operacao := 'INSERT';
        v_dados := 'Novo Candidato: ' || :NEW.NOME;
    ELSIF UPDATING THEN 
        v_operacao := 'UPDATE';
        v_dados := 'Alterado de: ' || :OLD.NOME || ' para ' || :NEW.NOME;
    ELSIF DELETING THEN 
        v_operacao := 'DELETE';
        v_dados := 'Removido: ' || :OLD.NOME;
    END IF;

    INSERT INTO T_INC_LOG_AUDITORIA (ID_LOG, NOME_TABELA, OPERACAO, USUARIO_DB, DADOS_ANTIGOS)
    VALUES (SEQ_LOG_AUDITORIA.NEXTVAL, 'T_INC_CANDIDATO', v_operacao, USER, v_dados);
END;
/