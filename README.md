# 🎗 Dezembro Vermelho 2025 - Sistema de Inscrições

Sistema modular e fácil de manter para gerenciar inscrições em 30 atividades do evento "Dezembro Vermelho 2025 - 40 anos da resposta brasileira à AIDS".

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Instalação e Uso](#instalação-e-uso)
- [Opções de Deploy](#opções-de-deploy)
- [Como Atualizar](#como-atualizar)
- [Configuração](#configuração)
- [Estrutura de Arquivos](#estrutura-de-arquivos)
- [Fluxo de Dados](#fluxo-de-dados)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Visão Geral

Este sistema fornece **duas opções de implementação**:

### **Opção A: Formulário Dinâmico** (Recomendado ✅)
- **1 arquivo** de formulário (`form-template.html`) que lê o ID da atividade via parâmetro URL (`?id=1`)
- **Mais fácil de manter**: atualizar 1 arquivo apenas
- Requer servidor web que suporte passagem de parâmetros na URL

### **Opção B: Formulários Estáticos** (Fallback)
- **30 arquivos HTML** individuais, cada um pré-configurado com o ID da atividade
- Máxima compatibilidade com qualquer servidor web
- Usa script gerador (`generate-forms.js`) para criar os 30 arquivos automaticamente

Ambas as opções compartilham:
- **1 arquivo de configuração** (`activities.json`) com todas as atividades
- **1 página de listagem** (`index.html`) que exibe todas as atividades
- Integração com workflow n8n para processar inscrições

---

## 🏗 Arquitetura

```
sistema-dezembro-vermelho/
├── activities.json          # 📊 Configuração central com as 30 atividades
├── index.html              # 📄 Página principal com listagem das atividades
├── form-template.html      # 📝 Formulário dinâmico (Opção A)
├── generate-forms.js       # 🔨 Gerador de formulários estáticos (Opção B)
└── forms/                  # 📁 Diretório com formulários estáticos gerados
    ├── form-1.html
    ├── form-2.html
    └── ... (30 arquivos)
```

### Fluxo de Funcionamento

```
┌─────────────────┐
│   index.html    │ ← Usuário vê lista de atividades
│  (Listagem)     │
└────────┬────────┘
         │ Clica em "Fazer Inscrição"
         ↓
┌─────────────────────────────────┐
│  form-template.html?id=1   OU   │
│  forms/form-1.html              │ ← Formulário específico da atividade
└────────┬────────────────────────┘
         │ Preenche e envia
         ↓
┌─────────────────┐
│  n8n Webhook    │ ← Processa inscrição
│  /inscricao-dv  │    - Valida dados
│  -2025          │    - Verifica capacidade
└────────┬────────┘    - Gera ticket e QR code
         │              - Envia email
         ↓
┌─────────────────┐
│ Google Sheets   │ ← Salva registro da inscrição
└─────────────────┘
```

---

## 🚀 Instalação e Uso

### Pré-requisitos

- Navegador web moderno
- Servidor web (Apache, Nginx, ou Python SimpleHTTPServer para testes locais)
- Node.js (apenas se usar Opção B - formulários estáticos)

### Opção A: Formulário Dinâmico (Recomendado)

1. **Configure os arquivos**:
   - `activities.json` - Já configurado com as 30 atividades
   - `form-template.html` - Formulário dinâmico
   - `index.html` - Página de listagem

2. **Ajuste a configuração** (se necessário):

   Edite `form-template.html` linha ~186:
   ```javascript
   const CONFIG = {
       webhookURL: "https://n8n.bebot.co/webhook/inscricao-dv-2025",
       activitiesDataURL: "./activities.json"
   };
   ```

   Edite `index.html` linha ~273:
   ```javascript
   const CONFIG = {
       activitiesDataURL: "./activities.json",
       formType: "dynamic",  // ← Certifique-se de que está "dynamic"
       dynamicFormPath: "./form-template.html"
   };
   ```

3. **Deploy**:
   - Faça upload de todos os arquivos para seu servidor web
   - Acesse `index.html` no navegador
   - Pronto! ✅

### Opção B: Formulários Estáticos

1. **Instale Node.js** (se ainda não tiver)

2. **Gere os formulários**:
   ```bash
   node generate-forms.js
   ```

   Isso criará 30 arquivos em `/forms/`:
   - `form-1.html`
   - `form-2.html`
   - ... até `form-30.html`

3. **Configure o index.html**:

   Edite `index.html` linha ~273:
   ```javascript
   const CONFIG = {
       activitiesDataURL: "./activities.json",
       formType: "static",  // ← Mude para "static"
       staticFormPath: "./forms/form-{id}.html"
   };
   ```

4. **Deploy**:
   - Faça upload de todos os arquivos (`index.html`, `activities.json`, e pasta `/forms/`)
   - Acesse `index.html` no navegador
   - Pronto! ✅

---

## 🌐 Opções de Deploy

### Teste Local

```bash
# Python 3
python -m http.server 8000

# Python 2
python -m SimpleHTTPServer 8000

# Node.js (npx http-server)
npx http-server -p 8000
```

Acesse: `http://localhost:8000`

### Produção

- **GitHub Pages**: Push para repositório e ative GitHub Pages
- **Netlify**: Arraste a pasta para netlify.com/drop
- **Vercel**: `vercel --prod`
- **Servidor próprio**: Upload via FTP/SFTP

---

## 🔧 Como Atualizar

### Atualizar Dados de uma Atividade

**Arquivo**: `activities.json`

```json
{
  "id": 1,
  "nome_atividade": "Novo nome da atividade",
  "data": "01/12/2025",
  "horario": "15:00-16:00",
  "local": "SESILAB",
  "capacidade": 100,
  "vagas_preenchidas": 0,
  "vagas_disponiveis": 100
}
```

1. Edite o arquivo `activities.json`
2. **Opção A (dinâmico)**: Apenas faça upload do `activities.json` atualizado
3. **Opção B (estático)**: Execute `node generate-forms.js` novamente e faça upload de tudo

### Adicionar uma Nova Atividade

1. Adicione um novo objeto ao array em `activities.json`:
   ```json
   {
     "id": 31,
     "data": "20/12/2025",
     "horario": "10:00-12:00",
     "nome_atividade": "Nova Atividade",
     "tipo": "Workshop",
     "local": "SESILAB",
     "capacidade": 50,
     "vagas_preenchidas": 0,
     "vagas_disponiveis": 50
   }
   ```

2. Se usar **Opção B**, regenere os formulários:
   ```bash
   node generate-forms.js
   ```

### Mudar Webhook URL

Edite a URL do webhook n8n:

**Opção A**: `form-template.html` linha ~186
```javascript
webhookURL: "https://SEU-DOMINIO/webhook/inscricao-dv-2025"
```

**Opção B**: `generate-forms.js` linha ~21
```javascript
webhookURL: 'https://SEU-DOMINIO/webhook/inscricao-dv-2025'
```

Depois regenere os forms:
```bash
node generate-forms.js
```

---

## ⚙️ Configuração

### activities.json

Estrutura de cada atividade:

| Campo                | Tipo   | Obrigatório | Descrição                           |
|----------------------|--------|-------------|-------------------------------------|
| `id`                 | number | ✅          | ID único da atividade               |
| `data`               | string | ✅          | Data no formato DD/MM/YYYY          |
| `horario`            | string | ✅          | Horário (ex: "15:00-16:00")         |
| `nome_atividade`     | string | ✅          | Nome completo da atividade          |
| `tipo`               | string | ✅          | Tipo (Palestra, Workshop, etc.)     |
| `local`              | string | ✅          | Local do evento                     |
| `capacidade`         | number | ✅          | Capacidade total                    |
| `vagas_preenchidas`  | number | ✅          | Vagas já preenchidas (inicial: 0)   |
| `vagas_disponiveis`  | number | ✅          | Vagas disponíveis                   |

### Campos do Formulário

Os formulários coletam:

- **nome_completo** (obrigatório)
- **email** (obrigatório)
- **cpf** (opcional) - formatado automaticamente como 000.000.000-00
- **atividade** (hidden field - ID da atividade)
- **Checkbox LGPD** (obrigatório)

### n8n Workflow

O workflow espera receber via POST:

```json
{
  "nome_completo": "João Silva",
  "email": "joao@email.com",
  "cpf": "12345678900",
  "atividade": "1"
}
```

**Endpoint**: `https://n8n.bebot.co/webhook/inscricao-dv-2025`

---

## 📂 Estrutura de Arquivos

```
sistema-dezembro-vermelho/
│
├── 📊 activities.json
│   └── Configuração central com todas as 30 atividades
│
├── 📄 index.html
│   └── Página de listagem com filtros por tipo de atividade
│
├── 📝 form-template.html (Opção A - Dinâmico)
│   ├── Lê ID da atividade via parâmetro URL (?id=1)
│   ├── Busca dados em activities.json
│   ├── Exibe informações da atividade
│   ├── Coleta dados do usuário
│   └── Envia para webhook n8n
│
├── 🔨 generate-forms.js (Opção B - Estático)
│   └── Script Node.js para gerar 30 arquivos HTML
│
├── 📁 forms/ (Gerado pela Opção B)
│   ├── form-1.html  ← Atividade #1 pré-configurada
│   ├── form-2.html  ← Atividade #2 pré-configurada
│   └── ... (30 arquivos)
│
└── 📖 README.md
    └── Esta documentação
```

---

## 🔄 Fluxo de Dados

### 1. Usuário Acessa index.html

```
index.html
  ↓ fetch()
activities.json
  ↓ renderiza
Lista de 30 atividades com botões "Fazer Inscrição"
```

### 2. Usuário Clica em "Fazer Inscrição"

**Opção A (Dinâmico)**:
```
form-template.html?id=1
  ↓ fetch()
activities.json
  ↓ encontra atividade ID=1
Exibe formulário com dados da atividade
```

**Opção B (Estático)**:
```
forms/form-1.html
  ↓ HTML já contém
Dados da atividade embutidos no código
```

### 3. Usuário Preenche e Envia Formulário

```
Formulário
  ↓ POST JSON
https://n8n.bebot.co/webhook/inscricao-dv-2025
  ↓ n8n processa
  ├─ Valida dados
  ├─ Busca atividade no Google Sheets
  ├─ Verifica capacidade
  ├─ Verifica duplicatas
  ├─ Gera ticket ID e QR code
  ├─ Salva em Google Sheets
  ├─ Envia email de confirmação
  └─ Retorna HTML de confirmação
```

### 4. Confirmação

```
n8n retorna HTML
  ↓ replace
document.body.innerHTML = htmlDeConfirmacao
```

---

## 🐛 Troubleshooting

### Problema: "Atividade não encontrada"

**Causa**: ID da atividade na URL não existe em `activities.json`

**Solução**:
- Verifique se o ID existe em `activities.json`
- Certifique-se de que o arquivo está acessível no servidor

### Problema: "Não foi possível carregar os dados das atividades"

**Causa**: Erro ao carregar `activities.json`

**Solução**:
- Verifique se `activities.json` está no mesmo diretório que o HTML
- Verifique se o JSON está válido (use jsonlint.com)
- Verifique permissões do arquivo no servidor
- Abra o Console do navegador (F12) para ver erros detalhados

### Problema: Formulário não envia

**Causa**: Webhook URL incorreta ou n8n offline

**Solução**:
- Verifique a URL do webhook na configuração
- Teste o endpoint n8n diretamente com Postman/Insomnia
- Verifique o Console do navegador (F12) para erros de CORS

### Problema: CPF não formata

**Causa**: JavaScript não está carregando

**Solução**:
- Verifique o Console do navegador (F12) para erros JavaScript
- Certifique-se de que o navegador suporta JavaScript moderno

### Problema: Após gerar formulários estáticos, mudanças não aparecem

**Causa**: Esqueceu de regenerar os formulários após editar `activities.json`

**Solução**:
```bash
node generate-forms.js
```

---

## 📝 Notas Importantes

### Segurança

- ✅ Validação de email no frontend e backend
- ✅ Sanitização de dados (CPF aceita apenas números)
- ✅ Verificação de capacidade e duplicatas no n8n
- ✅ LGPD: checkbox de consentimento obrigatório

### Performance

- 📦 Arquivos estáticos são super leves (~10-15KB cada)
- ⚡ Não requer banco de dados
- 🚀 Pode ser hospedado em CDN (Cloudflare, etc.)

### Manutenção

- ✏️ **Fácil atualização**: edite apenas `activities.json`
- 🔄 **Sincronização com Google Sheets**: considere criar script para sincronizar automaticamente
- 📊 **Monitoramento**: use Google Analytics para rastrear inscrições

### Melhorias Futuras

- [ ] Script para sincronizar `activities.json` com Google Sheets automaticamente
- [ ] Validação de CPF (dígitos verificadores)
- [ ] Integração com Google Calendar para adicionar evento ao calendário do usuário
- [ ] Modo de visualização de vagas em tempo real (WebSocket)
- [ ] Sistema de lista de espera para atividades lotadas
- [ ] Exportação de relatórios em CSV/PDF

---

## 🤝 Suporte

Para dúvidas ou problemas:

1. Verifique a seção [Troubleshooting](#troubleshooting)
2. Verifique o Console do navegador (F12) para erros
3. Verifique os logs do n8n workflow
4. Entre em contato com o administrador do sistema

---

## 📄 Licença

© 2025 Ministério da Saúde – Programa Dezembro Vermelho
40 anos da resposta brasileira à AIDS

---

**Desenvolvido com ❤️ para o Ministério da Saúde**
