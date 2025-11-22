-- ==========================================================
-- FASE 3: DML - CARGA DE DADOS E TESTE DE EXPORTAÇÃO
-- Autor: Luiz Eduardo Da Silva Pinto (Global Solution 2025)
-- ==========================================================


-- 1. LIMPEZA INICIAL (Para poder rodar o script várias vezes sem erro)
DELETE FROM T_INC_MATCH;
DELETE FROM T_INC_VAGA_SKILL;
DELETE FROM T_INC_VAGA;
DELETE FROM T_INC_CANDIDATO_SKILL;
DELETE FROM T_INC_RECRUTADOR;
DELETE FROM T_INC_EMPRESA;
DELETE FROM T_INC_SKILL;
DELETE FROM T_INC_CANDIDATO;
DELETE FROM T_INC_LOG_AUDITORIA;
COMMIT;

-- 2. INSERIR SKILLS (Competências para o Futuro do Trabalho)
INSERT INTO T_INC_SKILL (ID_SKILL, NOME, TIPO_SKILL) VALUES ('s01', 'Java Advanced', 'HARD_SKILL');
INSERT INTO T_INC_SKILL (ID_SKILL, NOME, TIPO_SKILL) VALUES ('s02', 'Oracle PL/SQL', 'HARD_SKILL');
INSERT INTO T_INC_SKILL (ID_SKILL, NOME, TIPO_SKILL) VALUES ('s03', 'Inteligência Emocional', 'SOFT_SKILL');
INSERT INTO T_INC_SKILL (ID_SKILL, NOME, TIPO_SKILL) VALUES ('s04', 'Liderança Inclusiva', 'SOFT_SKILL');
INSERT INTO T_INC_SKILL (ID_SKILL, NOME, TIPO_SKILL) VALUES ('s05', 'React Native', 'HARD_SKILL');
COMMIT;

-- 3. INSERIR EMPRESA (Contratante)
INSERT INTO T_INC_EMPRESA (ID_EMPRESA, NOME_OFICIAL, NOME_FANTASIA, CNPJ, LOCALIZACAO, DESCRICAO) 
VALUES ('e01', 'Tech Solutions S.A.', 'TechSol', '12.345.678/0001-99', 'São Paulo, SP', 'Empresa focada em inovação e diversidade.');
COMMIT;

-- 4. INSERIR CANDIDATOS (Usando nossa PROCEDURE da Fase 2 para testar)
BEGIN
    -- Candidato 1: Desenvolvedor Java
    PKG_INCLUDIA.PRC_INSERIR_CANDIDATO(
        'João da Silva', 
        '123.456.789-00', 
        'joao@email.com', 
        'senhaSegura123', 
        'Desenvolvedor Java apaixonado por acessibilidade e inclusão.'
    );

    -- Candidato 2: Tech Lead (Vai dar erro proposital de email para testar validação? Não, vamos fazer certo)
    PKG_INCLUDIA.PRC_INSERIR_CANDIDATO(
        'Maria Souza', 
        '987.654.321-11', 
        'maria.souza@tech.com', 
        'senhaForte456', 
        'Líder técnica com foco em gestão humanizada.'
    );
END;
/

-- 5. VINCULAR SKILLS AOS CANDIDATOS (Manual, pois precisamos dos IDs gerados)
-- Como usamos UUID aleatório na procedure, vamos pegar os IDs recém criados
DECLARE
    v_id_joao VARCHAR2(36);
    v_id_maria VARCHAR2(36);
BEGIN
    SELECT ID_CANDIDATO INTO v_id_joao FROM T_INC_CANDIDATO WHERE EMAIL = 'joao@email.com';
    SELECT ID_CANDIDATO INTO v_id_maria FROM T_INC_CANDIDATO WHERE EMAIL = 'maria.souza@tech.com';

    -- João sabe Java e React
    INSERT INTO T_INC_CANDIDATO_SKILL (ID_CANDIDATO, ID_SKILL) VALUES (v_id_joao, 's01');
    INSERT INTO T_INC_CANDIDATO_SKILL (ID_CANDIDATO, ID_SKILL) VALUES (v_id_joao, 's05');
    INSERT INTO T_INC_CANDIDATO_SKILL (ID_CANDIDATO, ID_SKILL) VALUES (v_id_joao, 's03'); -- Soft Skill

    -- Maria sabe PL/SQL e Liderança
    INSERT INTO T_INC_CANDIDATO_SKILL (ID_CANDIDATO, ID_SKILL) VALUES (v_id_maria, 's02');
    INSERT INTO T_INC_CANDIDATO_SKILL (ID_CANDIDATO, ID_SKILL) VALUES (v_id_maria, 's04');
    
    COMMIT;
END;
/

-- 6. TESTE DE EXPORTAÇÃO JSON (O Grande Final!)
-- Vamos chamar a função manual e ver o JSON gerado para o João
DECLARE
    v_json_output CLOB;
    v_id_target VARCHAR2(36);
BEGIN
    -- Pega o ID do João
    SELECT ID_CANDIDATO INTO v_id_target FROM T_INC_CANDIDATO WHERE EMAIL = 'joao@email.com';

    -- Chama a função "Hardcore"
    v_json_output := PKG_INCLUDIA.FUN_GERAR_JSON_CANDIDATO(v_id_target);

    -- Imprime o resultado (Abra a aba "Saída DBMS" / "Dbms Output" para ver)
    DBMS_OUTPUT.PUT_LINE('--- JSON GERADO MANUALMENTE PARA MONGODB ---');
    DBMS_OUTPUT.PUT_LINE(v_json_output);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
END;
/

-- 7. VERIFICAR LOG DE AUDITORIA (Prova que a Trigger funcionou)
SELECT * FROM T_INC_LOG_AUDITORIA ORDER BY DATA_HORA DESC;