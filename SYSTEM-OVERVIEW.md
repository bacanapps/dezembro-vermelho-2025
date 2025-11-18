# 🎗 Sistema Dezembro Vermelho 2025 - Visão Geral

## 📊 Resumo Executivo

Sistema completo e modular para gerenciar inscrições em 30 atividades do evento "Dezembro Vermelho 2025 - 40 anos da resposta brasileira à AIDS".

### Números

- **30 atividades** únicas
- **2 opções** de implementação
- **1 fonte** de dados centralizada
- **3.950 vagas** totais disponíveis
- **10 tipos** de eventos diferentes

---

## 🏗️ Arquitetura do Sistema

```
┌─────────────────────────────────────────────────────────────────┐
│                     SISTEMA DEZEMBRO VERMELHO                    │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│  FRONTEND     │    │  BACKEND      │    │  STORAGE      │
│               │    │               │    │               │
│ - index.html  │───▶│ n8n Workflow  │───▶│ Google Sheets │
│ - form.html   │    │               │    │               │
│               │    │ - Validation  │    │ - Activities  │
│               │    │ - Capacity    │    │ - Registr.    │
│               │    │ - QR Code     │    │               │
│               │    │ - Email       │    │               │
└───────────────┘    └───────────────┘    └───────────────┘
        │
        ▼
┌───────────────┐
│  DATA SOURCE  │
│               │
│activities.json│
│               │
│ 30 Activities │
└───────────────┘
```

---

## 🎯 Componentes Principais

### 1. Data Layer (Camada de Dados)

**activities.json**
- ✅ Única fonte de verdade
- ✅ 30 atividades configuradas
- ✅ Campos: ID, nome, data, horário, local, tipo, capacidade
- ✅ Formato JSON para fácil edição e parsing

### 2. Presentation Layer (Camada de Apresentação)

#### index.html - Página de Listagem
- 📋 Lista todas as 30 atividades
- 🔍 Filtros por tipo de evento
- 📊 Estatísticas em tempo real
- 📱 Design responsivo
- 🎨 Interface moderna com Dezembro Vermelho branding

#### form-template.html - Formulário Dinâmico (Opção A)
- 📝 Lê ID via URL parameter (?id=1)
- 🔄 Busca dados em activities.json dinamicamente
- ✅ Validação de campos
- 💳 Formatação automática de CPF
- 🔒 Checkbox LGPD

#### forms/form-*.html - Formulários Estáticos (Opção B)
- 📄 30 arquivos HTML individuais
- ⚡ Dados pré-compilados no HTML
- 🚀 Performance máxima (sem fetch necessário)
- 🔧 Gerados automaticamente por script

### 3. Build Layer (Camada de Build)

**generate-forms.js**
- 🔨 Gera 30 formulários estáticos
- 📦 Node.js script
- 🎨 Template engine embutido
- ⚙️ Configurável via constantes

### 4. Integration Layer (Camada de Integração)

**n8n Workflow**
- 🌐 Webhook endpoint: `/inscricao-dv-2025`
- ✅ Validação de dados
- 🔍 Lookup de atividade no Google Sheets
- 🚫 Verificação de capacidade
- 🚫 Verificação de duplicatas
- 🎫 Geração de ticket ID único (DV25-XXXXXXX)
- 📱 Geração de QR Code
- 💾 Salvamento no Google Sheets
- 📧 Email de confirmação automático
- 📋 Atualização de capacidade

### 5. Storage Layer (Camada de Armazenamento)

**Google Sheets**
- Tab "Atividades_DezembroVermelho": Lista de atividades
- Tab "Inscricoes_DezembroVermelho": Registros de inscrições
- 🔄 Sincronização em tempo real
- 📊 Relatórios e analytics
- 📥 Exportação fácil (CSV, Excel)

---

## 🔄 Fluxo de Dados Completo

### Scenario 1: Usuário Faz Inscrição

```
1. ACESSO À LISTAGEM
   Usuário → index.html
   index.html → fetch() → activities.json
   activities.json → retorna 30 atividades
   index.html → renderiza lista com filtros

2. SELEÇÃO DE ATIVIDADE
   Usuário clica "Fazer Inscrição" para Atividade #5

   [OPÇÃO A - Dinâmico]
   → Abre form-template.html?id=5
   → form-template.html fetch() → activities.json
   → Encontra atividade ID=5
   → Exibe formulário com dados da atividade

   [OPÇÃO B - Estático]
   → Abre forms/form-5.html
   → HTML já contém todos os dados embutidos
   → Exibe formulário

3. PREENCHIMENTO
   Usuário preenche:
   - Nome completo
   - Email
   - CPF (opcional, formatado automaticamente)
   - Aceita LGPD

4. SUBMISSÃO
   Form → POST JSON → n8n webhook

   JSON enviado:
   {
     "nome_completo": "João Silva",
     "email": "joao@email.com",
     "cpf": "12345678900",
     "atividade": "5"
   }

5. PROCESSAMENTO (n8n)

   a) Validar Dados
      ✅ Campos obrigatórios presentes?
      ✅ Email válido?
      ❌ Se não → Retorna erro 400

   b) Buscar Atividade
      → Lookup no Google Sheets tab "Atividades"
      → Filtra por ID = 5
      ❌ Se não encontrada → Retorna erro 404

   c) Verificar Capacidade
      → vagas_preenchidas >= capacidade?
      ❌ Se sim → Retorna "Capacidade esgotada"

   d) Verificar Duplicata
      → Busca no Google Sheets tab "Inscricoes"
      → Mesmo email + mesma atividade?
      ❌ Se sim → Retorna "Já inscrito"

   e) Gerar Ticket
      → ticket_id = "DV25-" + random(7 chars)
      → qr_payload = "https://scanner.bebot.co/scanner?id={ticket_id}"

   f) Gerar QR Code
      → API: https://api.qrserver.com/v1/create-qr-code/
      → Retorna imagem PNG 300x300

   g) Salvar Inscrição
      → Append no Google Sheets tab "Inscricoes"
      → Campos: timestamp, ticket_id, nome, email, cpf,
                atividade_id, atividade_nome, status, qr_code_url

   h) Atualizar Capacidade
      → Update no Google Sheets tab "Atividades"
      → vagas_preenchidas + 1
      → vagas_disponiveis - 1

   i) Enviar Email
      → Via Gmail API
      → Para: email do usuário
      → Assunto: "Confirmação de Inscrição – {atividade}"
      → Conteúdo: HTML com QR code, detalhes, instruções

   j) Retornar Confirmação
      → HTML de sucesso com ticket_id
      → Exibido no navegador do usuário

6. CONFIRMAÇÃO
   Usuário vê página de sucesso
   Usuário recebe email com:
   - QR Code
   - Ticket ID
   - Detalhes da atividade
   - Instruções para o dia do evento
```

---

## 📁 Estrutura de Arquivos Detalhada

```
dezembro-vermelho-2025/
│
├── 📊 CONFIGURAÇÃO
│   └── activities.json              (3.5 KB)
│       - 30 objetos JSON
│       - Todos os dados das atividades
│       - Única fonte de verdade
│
├── 📄 PÁGINAS HTML
│   ├── index.html                   (15 KB)
│   │   - Listagem de atividades
│   │   - Filtros por tipo
│   │   - Estatísticas
│   │   - Links para formulários
│   │
│   └── form-template.html           (12 KB)
│       - Formulário dinâmico
│       - Lê ID da URL (?id=X)
│       - Busca dados em activities.json
│       - Validação e envio
│
├── 🔨 BUILD TOOLS
│   ├── generate-forms.js            (8 KB)
│   │   - Gerador de formulários estáticos
│   │   - Template engine embutido
│   │   - Cria 30 arquivos HTML
│   │
│   └── package.json                 (0.5 KB)
│       - Metadados do projeto
│       - Scripts npm
│       - Dependências
│
├── 📁 FORMULÁRIOS GERADOS (Opção B)
│   └── forms/
│       ├── form-1.html              (11 KB)
│       ├── form-2.html              (11 KB)
│       ├── ...
│       └── form-30.html             (11 KB)
│
│       Total: ~330 KB (30 files)
│
└── 📖 DOCUMENTAÇÃO
    ├── README.md                    (15 KB)
    │   - Documentação completa
    │   - Instalação e uso
    │   - Troubleshooting
    │
    ├── QUICK-START.md               (4 KB)
    │   - Guia rápido de início
    │   - 3 minutos para deploy
    │
    └── SYSTEM-OVERVIEW.md           (Este arquivo)
        - Visão geral do sistema
        - Arquitetura e fluxos
```

**Tamanho Total**: ~380 KB (com forms gerados) ou ~50 KB (sem forms)

---

## 🔐 Segurança e Validação

### Frontend (HTML/JavaScript)

| Validação | Onde | Como |
|-----------|------|------|
| **Email válido** | Form HTML | `type="email"` + regex no JS |
| **Campos obrigatórios** | Form HTML | `required` attribute |
| **CPF formato** | JavaScript | Regex + formatação automática |
| **LGPD** | Checkbox | `required` - usuário deve aceitar |
| **Activity ID** | JavaScript | Verifica existência em activities.json |
| **Capacidade** | JavaScript | Exibe aviso se vagas = 0 |

### Backend (n8n)

| Validação | Node | Ação se Falhar |
|-----------|------|----------------|
| **Campos obrigatórios** | Validar Dados | Retorna erro 400 |
| **Email formato** | Validar Dados | Retorna erro 400 |
| **Atividade existe** | Buscar Atividade | Retorna erro 404 |
| **Capacidade disponível** | Verificar Capacidade | Retorna "Esgotado" |
| **Sem duplicata** | Verificar Duplicata | Retorna "Já inscrito" |

### LGPD Compliance

✅ **Consentimento explícito**: Checkbox obrigatório
✅ **Finalidade clara**: Texto explicativo no formulário
✅ **Dados mínimos**: Apenas nome, email, CPF opcional
✅ **Direito de acesso**: Dados armazenados em Google Sheets acessível
✅ **Portabilidade**: Fácil exportação em CSV/Excel

---

## 🎨 Design e UX

### Cores (Dezembro Vermelho Branding)

- **Vermelho principal**: `#c41e3a`
- **Vermelho escuro**: `#a61a32`
- **Branco**: `#ffffff`
- **Cinza claro**: `#f5f5f5`
- **Cinza médio**: `#666666`
- **Azul info**: `#1565c0`
- **Vermelho erro**: `#c62828`

### Typography

- **Fonte principal**: Arial, "Segoe UI", sans-serif
- **Títulos**: Bold, 1.5-2.5em
- **Corpo**: Regular, 14-16px
- **Meta info**: 13-14px

### Responsividade

- **Desktop**: Grid 3 colunas (min 350px)
- **Tablet**: Grid 2 colunas
- **Mobile**: Grid 1 coluna
- **Breakpoint**: 768px

### Acessibilidade

- ✅ Contraste adequado (WCAG AA)
- ✅ Labels associados a inputs
- ✅ Mensagens de erro claras
- ✅ Foco visível em elementos interativos
- ✅ Semântica HTML correta

---

## 📈 Métricas e Analytics

### Dados Coletados (Google Sheets)

**Tab "Inscricoes"**:
- Timestamp
- Ticket ID
- Nome completo
- Email
- CPF
- Atividade ID
- Atividade nome
- Status
- QR Code URL

**Tab "Atividades"**:
- Vagas preenchidas (atualizado em tempo real)
- Vagas disponíveis (atualizado em tempo real)

### Relatórios Possíveis

- 📊 Inscrições por atividade
- 📊 Inscrições por dia
- 📊 Inscrições por tipo de evento
- 📊 Taxa de ocupação
- 📊 Atividades mais populares
- 📊 Horários de pico de inscrições

---

## 🚀 Performance

### Otimizações Implementadas

| Otimização | Benefício |
|------------|-----------|
| **Arquivos estáticos** | Sem processamento server-side |
| **JSON local** | Cache do navegador, sem DB queries |
| **CSS inline** | Menos requests HTTP |
| **JavaScript vanilla** | Sem frameworks pesados |
| **Imagens externas** | QR code via API externa |
| **Lazy loading** | Atividades carregadas sob demanda |

### Benchmarks

- **Tempo de carregamento**: ~1-2 segundos
- **Tamanho total**: ~50 KB (sem imagens)
- **Requests HTTP**: 2-3 (HTML + JSON)
- **Compatibilidade**: IE11+, todos os navegadores modernos

---

## 🔄 Manutenção

### Tarefas Comuns

| Tarefa | Frequência | Complexidade | Tempo |
|--------|------------|--------------|-------|
| Adicionar atividade | Raro | Fácil | 5 min |
| Atualizar dados | Ocasional | Fácil | 2 min |
| Mudar webhook URL | Raro | Médio | 10 min |
| Gerar forms (Opção B) | Sempre que mudar JSON | Fácil | 1 min |
| Deploy | Sempre que mudar | Fácil | 5 min |

### Checklist de Manutenção Mensal

- [ ] Revisar capacidades das atividades
- [ ] Verificar logs do n8n para erros
- [ ] Fazer backup do Google Sheets
- [ ] Testar formulários em diferentes navegadores
- [ ] Verificar emails de confirmação sendo enviados
- [ ] Revisar estatísticas de inscrições

---

## 🎯 Casos de Uso

### 1. Organizador Adiciona Nova Atividade

```
1. Edita activities.json
2. Adiciona novo objeto com ID 31
3. [Opção A] Upload activities.json → PRONTO
   [Opção B] Executa node generate-forms.js → Upload tudo
4. Nova atividade aparece no index.html automaticamente
```

### 2. Participante se Inscreve

```
1. Acessa index.html
2. Filtra por tipo "Palestra"
3. Seleciona atividade de interesse
4. Clica "Fazer Inscrição"
5. Preenche formulário
6. Submete
7. Recebe confirmação na tela
8. Recebe email com QR code
9. Salva email para apresentar no dia
```

### 3. Organizador Verifica Inscrições

```
1. Abre Google Sheets
2. Vai para tab "Inscricoes_DezembroVermelho"
3. Vê todas as inscrições com:
   - Quem se inscreveu
   - Para qual atividade
   - Quando
   - Ticket ID
4. Pode exportar para Excel para análise
```

### 4. No Dia do Evento

```
1. Participante chega ao local
2. Apresenta QR code (do email ou impresso)
3. Organizador escaneia QR code
4. Sistema valida ticket ID
5. Participante é liberado para entrar
```

---

## 🛠️ Extensões Futuras

### Ideias para v2.0

- [ ] **Sync automático com Google Sheets**: Script que atualiza activities.json automaticamente
- [ ] **Painel de admin**: Interface web para gerenciar atividades sem editar JSON
- [ ] **Lista de espera**: Quando atividade lota, permitir inscrição na lista de espera
- [ ] **Cancelamento de inscrição**: Link no email para cancelar
- [ ] **Check-in digital**: App mobile para escanear QR codes
- [ ] **Certificados**: Geração automática de certificado de participação
- [ ] **Integração com calendário**: Botão "Adicionar ao Google Calendar"
- [ ] **Notificações SMS**: Além de email, enviar SMS de confirmação
- [ ] **Analytics dashboard**: Painel com métricas em tempo real
- [ ] **Multi-idioma**: Suporte para português, inglês, espanhol

---

## 📞 Suporte Técnico

### Troubleshooting Rápido

| Problema | Solução Rápida |
|----------|----------------|
| Atividade não carrega | Verificar activities.json no mesmo diretório |
| Formulário não envia | Verificar webhook URL e n8n online |
| Email não chega | Verificar spam, logs do n8n, Gmail API |
| CPF não formata | Verificar console do navegador (F12) |
| Mudanças não aparecem | Limpar cache (Ctrl+Shift+R) |
| Forms Option B outdated | Executar node generate-forms.js |

### Logs e Debug

**Frontend**:
```javascript
// Abrir Console do navegador (F12)
// Ver mensagens de log:
console.log("📤 Dados enviados:", data);
console.log("📥 Resposta:", response.status);
```

**Backend (n8n)**:
- Ver executions no dashboard do n8n
- Verificar cada step do workflow
- Ver output de cada node

---

## 📚 Recursos Adicionais

### Documentação Relacionada

- [README.md](README.md) - Documentação completa
- [QUICK-START.md](QUICK-START.md) - Guia rápido de início
- [n8n Documentation](https://docs.n8n.io/)
- [Google Sheets API](https://developers.google.com/sheets/api)

### Links Úteis

- **n8n Workflow**: `https://n8n.bebot.co/workflow/gNKhpQ6RmN8vMA3J`
- **Google Sheets**: `https://docs.google.com/spreadsheets/d/1XYJ4S_shpoQ5o7Psth-h4p-XZI48Kypy6a21k2ayYJ8`
- **Webhook URL**: `https://n8n.bebot.co/webhook/inscricao-dv-2025`

---

## ✅ Checklist de Deployment

### Antes de Ir ao Ar

- [ ] Testar todos os 30 formulários
- [ ] Verificar webhook URL está correto
- [ ] Testar envio de email
- [ ] Verificar Google Sheets está acessível
- [ ] Testar em diferentes navegadores (Chrome, Firefox, Safari, Edge)
- [ ] Testar em mobile (iOS, Android)
- [ ] Verificar responsividade em diferentes tamanhos de tela
- [ ] Revisar textos e tradução
- [ ] Verificar links externos (QR API, etc.)
- [ ] Fazer backup de todos os arquivos
- [ ] Configurar monitoring/alertas
- [ ] Preparar FAQ para participantes
- [ ] Treinar equipe de suporte

### Pós-Deployment

- [ ] Monitorar inscrições nas primeiras horas
- [ ] Verificar emails estão sendo enviados
- [ ] Verificar capacidades sendo atualizadas
- [ ] Coletar feedback de usuários
- [ ] Documentar issues encontrados
- [ ] Fazer ajustes conforme necessário

---

**Sistema desenvolvido para Ministério da Saúde**
**Dezembro Vermelho 2025 - 40 anos da resposta brasileira à AIDS**

🎗️ **Versão**: 1.0.0
📅 **Data**: Novembro 2025
👨‍💻 **Desenvolvido com**: HTML, CSS, JavaScript, Node.js, n8n
