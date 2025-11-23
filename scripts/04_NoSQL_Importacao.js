/**
 * ==========================================================
 * FASE 4: IMPORTAÇÃO PARA MONGODB (DOCUMENTOS COMPLEXOS)
 * Autor: Luiz Eduardo Da Silva Pinto
 * ==========================================================
 */

// 1. Setup
use('includia_db');
db.candidatos.drop();

// 2. SIMULAÇÃO DOS DADOS VINDOS DO ORACLE (Copiados do Output da Fase 3)
// Note que agora temos o campo "experiencias" que não existia antes!
var jsonJoao = {
    "id": "uuid-do-joao-aqui",
    "nome": "João da Silva",
    "email": "joao@email.com",
    "resumo": "Desenvolvedor Java apaixonado por acessibilidade.",
    "skills": [
        "Java Advanced",
        "React Native"
    ],
    "experiencias": [
        { "cargo": "Dev Junior", "tipo": "TEMPO_INTEGRAL" },
        { "cargo": "Estagiário", "tipo": "ESTAGIO" }
    ],
    "origem": "Oracle Database",
    "sincronizado_em": new Date()
};

var jsonMaria = {
    "id": "uuid-da-maria-aqui",
    "nome": "Maria Souza",
    "email": "maria@email.com",
    "resumo": "Líder técnica e especialista em dados.",
    "skills": [
        "Oracle PL/SQL",
        "Liderança Inclusiva"
    ],
    "experiencias": [
        { "cargo": "Tech Lead", "tipo": "TEMPO_INTEGRAL" }
    ],
    "origem": "Oracle Database",
    "sincronizado_em": new Date()
};

// 3. PERSISTÊNCIA
db.candidatos.insertMany([jsonJoao, jsonMaria]);
print("--- DADOS IMPORTADOS COM SUCESSO (ESTRUTURA COMPLEXA) ---");

// 4. CONSULTAS DE VALIDAÇÃO

// A) Quem tem Experiência como 'Tech Lead'?
print("\n>>> Busca por Cargo (Nested Document):");
var leads = db.candidatos.find(
    { "experiencias.cargo": "Tech Lead" },
    { _id: 0, nome: 1, "experiencias.cargo": 1 }
).toArray();
printjson(leads);

// B) Quem tem skill 'Java Advanced'?
print("\n>>> Busca por Skill:");
var devs = db.candidatos.find({ "skills": "Java Advanced" }).toArray();
printjson(devs);