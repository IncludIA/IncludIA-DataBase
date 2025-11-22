/**
 * ==========================================================
 * FASE 4: NOSQL - IMPORTAÇÃO E CONSULTAS MONGODB
 * Autor: Equipe Includ.IA
 * Descrição: Script para importar o JSON gerado pelo Oracle
 * ==========================================================
 */

// 1. Selecionar o banco de dados
use('includia_db');

// 2. Limpar coleção para testes limpos
db.candidatos.drop();

// 3. DADOS VINDOS DO ORACLE (Copiados do seu Log)
var jsonJoao = {
    "id": "4434c766afcb0149e063030012ac12bb",
    "nome": "João da Silva",
    "email": "joao@email.com",
    "resumo": "Desenvolvedor Java apaixonado por acessibilidade e inclusão.",
    "skills": ["Java Advanced", "Inteligência Emocional", "React Native"],
    "origem": "Oracle Database",
    "data_integracao": new Date()
};

var jsonMaria = {
    "id": "4434c766afcc0149e063030012ac12bb",
    "nome": "Maria Souza",
    "email": "maria.souza@tech.com",
    "resumo": "Líder técnica com foco em gestão humanizada.",
    "skills": ["Oracle PL/SQL", "Liderança Inclusiva"],
    "origem": "Oracle Database",
    "data_integracao": new Date()
};

// 4. INSERIR NO MONGODB (Persistência)
db.candidatos.insertMany([jsonJoao, jsonMaria]);

print("--- DADOS IMPORTADOS COM SUCESSO ---");

// 5. CONSULTAS PARA AVALIAÇÃO (Queries)

// A) Buscar quem tem skill 'Java Advanced'
print("\n>>> Candidatos com Java Advanced:");
var devs = db.candidatos.find({ "skills": "Java Advanced" }, { _id: 0, nome: 1 }).toArray();
printjson(devs);

// B) Buscar por ID do Oracle
print("\n>>> Buscar João pelo ID do Oracle:");
var user = db.candidatos.findOne({ "id": "4434c766afcb0149e063030012ac12bb" });
printjson(user);