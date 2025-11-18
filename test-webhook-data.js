// This shows what n8n actually receives

// When you POST JSON with Content-Type: application/json
// N8N wraps it in a body object!

const test1 = {
  body: {
    nome_completo: "Colin",
    email: "colin@test.com",
    atividade: "30"
  }
};

const test2 = {
  nome_completo: "Colin",
  email: "colin@test.com", 
  atividade: "30"
};

console.log("Test 1 (with body):", test1.body.nome_completo); // Works
console.log("Test 2 (direct):", test2.nome_completo); // Works

// The fix: Try both!
const data1 = test1.body || test1;
const data2 = test2.body || test2;

console.log("Fixed 1:", data1.nome_completo);
console.log("Fixed 2:", data2.nome_completo);
