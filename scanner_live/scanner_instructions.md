# 📱 Scanner de Check-in - Instruções de Uso

## 🎯 Visão Geral

O Scanner de Check-in permite que a equipe autorizada registre a presença dos participantes nas atividades do Dezembro Vermelho 2025 através da leitura de QR codes nos ingressos digitais.

---

## 🔗 Acesso ao Scanner

### URL Principal:
```
https://bacanapps.github.io/dezembro-vermelho-2025/scanner_live/scanner.html
```

### URL com Autenticação:
```
https://bacanapps.github.io/dezembro-vermelho-2025/scanner_live/scanner.html?auth=6969&staffName=SEU_NOME
```

**Parâmetros:**
- `auth` - PIN de autorização (6969 ou outro código autorizado)
- `staffName` - Nome do responsável pelo check-in (será registrado no Google Sheets)

**Exemplo:**
```
https://bacanapps.github.io/dezembro-vermelho-2025/scanner_live/scanner.html?auth=6969&staffName=Colin%20Pantin
```

---

## 📋 Como Usar o Scanner

### Passo 1: Abrir o Scanner
1. Acesse a URL com seus parâmetros de autenticação
2. Permita o acesso à câmera quando solicitado pelo navegador
3. **IMPORTANTE:** Clique em qualquer lugar da página para desbloquear os sons (obrigatório em dispositivos móveis)

### Passo 2: Escanear QR Code
1. Aponte a câmera para o QR code do ingresso do participante
2. O scanner detectará automaticamente o código
3. Aguarde a resposta do sistema

### Passo 3: Confirmar Check-in

#### ✅ Check-in Bem-sucedido (Novo)
Você verá um modal verde com:
- ✅ Ícone de sucesso
- **Nome completo** do participante
- **Email**
- **CPF**
- **Atividade** inscrita
- **Ticket ID**
- **Status** da inscrição
- **Data/hora** do check-in
- **Verificado por** (seu nome)
- 🔊 Som de sucesso será tocado

#### ⚠️ Check-in Duplicado
Você verá um modal amarelo com:
- ⚠️ Ícone de aviso
- **Nome completo** do participante
- **Email**
- **CPF**
- **Atividade**
- **Ticket ID**
- **Check-in realizado em** (data/hora do check-in anterior)
- **Verificado por** (nome de quem fez o check-in anterior)
- 🔊 Som de erro será tocado

#### ❌ Ingresso Não Encontrado
Mensagem: "⚠️ Ingresso não encontrado"
- Verifique se o código está correto
- Confirme se o participante está inscrito no sistema

#### 🚫 Acesso Não Autorizado
Mensagem: "🚫 Acesso não autorizado"
- Verifique se o PIN de autenticação está correto
- Entre em contato com o administrador do sistema

### Passo 4: Continuar Escaneando
- Após cada check-in, o scanner **automaticamente retorna** para escanear o próximo código
- **Não é necessário** recarregar a página entre escaneamentos
- Basta fechar o modal e escanear o próximo QR code

---

## 🔧 Entrada Manual de Códigos

Se a câmera não estiver funcionando ou o QR code estiver danificado:

1. Role até a seção **"Inserir manualmente"**
2. Digite o código do ingresso (exemplo: `DV25-ABC1234`)
3. Clique em **"Enviar"**
4. O sistema processará como se fosse um QR code escaneado

---

## 📊 Dados Registrados

Cada check-in registra automaticamente no Google Sheets:

| Campo | Descrição | Exemplo |
|-------|-----------|---------|
| **checkin_timestamp** | Data e hora do check-in | 18/11/2025, 15:34:27 |
| **checked_by** | Nome do responsável | Colin Pantin |
| **ticket_id** | Código do ingresso | DV25-TX6NX6H |
| **nome_completo** | Nome do participante | Colin Pantin |
| **email** | Email do participante | colin@cpantin.com |
| **cpf** | CPF do participante | 123.456.789-00 |
| **atividade_nome** | Nome da atividade | Visita do Comitê Executivo do Unaids |
| **status** | Status da inscrição | CONFIRMADA |

---

## 🎵 Sons de Feedback

### 🔊 Desbloqueio de Áudio (OBRIGATÓRIO)
- **Primeira ação:** Clique em qualquer lugar da página após abrir
- **Motivo:** Navegadores móveis bloqueiam sons até a primeira interação do usuário
- **Confirmação:** Console mostrará "Audio unlocked"

### 🔔 Sons Durante Uso
- **Sucesso (novo check-in):** Som agradável de confirmação (`assets/success.mp3`)
- **Erro (duplicado/não encontrado):** Som de alerta (`assets/error.mp3`)

---

## 🔒 Segurança e Autenticação

### PINs Autorizados:
- `6969` - PIN padrão para equipe de check-in
- `redribbon2025` - PIN alternativo
- Emails autorizados podem ser configurados no workflow N8N

### Proteção de Dados:
- Todos os check-ins são registrados com identificação do responsável
- Histórico completo mantido no Google Sheets
- Verificação de duplicatas para evitar múltiplos check-ins

---

## 🚨 Solução de Problemas

### Câmera não funciona
**Problema:** Mensagem "Nenhuma câmera encontrada"
**Solução:**
- Verifique permissões do navegador
- Use navegador Chrome ou Safari
- Utilize entrada manual como alternativa

### Sons não tocam
**Problema:** Sem feedback sonoro
**Solução:**
1. Clique na página (desbloquear áudio)
2. Verifique volume do dispositivo
3. Teste com fones de ouvido
4. Verifique console (F12) para erros

### Modal não aparece
**Problema:** Apenas mensagem de texto, sem modal
**Solução:**
- Aguarde 1-2 segundos após escanear
- Verifique se o workflow N8N v2.5 está ativo
- Confirme que o webhook está configurado corretamente

### Mensagem "Workflow antigo ativo"
**Problema:** Scanner mostra aviso sobre workflow antigo
**Solução:**
1. Acesse N8N: https://n8n.bebot.co
2. Desative todos workflows antigos de Check-in
3. Ative apenas "Check-in Dezembro Vermelho 2025 v2.5"
4. Verifique que o Webhook está configurado para "Using 'Respond to Webhook' Node"

### Check-in registrado mas modal não aparece
**Problema:** Google Sheets atualizado mas scanner não mostra confirmação
**Solução:**
- Verifique configuração do Webhook node no N8N
- Parâmetro "Respond" deve estar em "Using 'Respond to Webhook' Node"
- NÃO deve estar em "Immediately"

---

## 📱 Dispositivos Compatíveis

### ✅ Compatível:
- **Desktop:** Chrome, Firefox, Safari, Edge
- **Android:** Chrome, Firefox
- **iOS:** Safari (versão 11+)
- **Tablets:** iPad, Android tablets

### ⚠️ Limitações:
- Navegadores antigos podem não suportar acesso à câmera
- Alguns navegadores podem bloquear câmera em conexões HTTP (requer HTTPS)

---

## 🔄 Fluxo do Sistema

```
1. Participante recebe ingresso por email
   ↓
2. Email contém QR code único (ticket_id: DV25-XXXXXX)
   ↓
3. No dia do evento, participante apresenta QR code
   ↓
4. Equipe escaneia com Scanner de Check-in
   ↓
5. Sistema verifica:
   - Código válido?
   - Já fez check-in?
   ↓
6. Se novo: Registra check-in + Mostra modal verde
7. Se duplicado: Mostra modal amarelo com histórico
   ↓
8. Dados salvos no Google Sheets
   ↓
9. Scanner pronto para próximo código
```

---

## 📞 Suporte Técnico

### Verificar Status do Sistema:
1. **Abrir Console do Navegador:** Pressione F12 (ou Cmd+Option+I no Mac)
2. **Ir para aba "Console"**
3. **Escanear QR code**
4. **Procurar por:**
   - "Full response object" - mostra resposta completa do servidor
   - "Audio unlocked" - confirma que áudio está funcionando
   - Mensagens vermelhas de erro

### Informações para Reportar Problemas:
- URL completa do scanner
- Nome do usuário (staffName)
- Ticket ID que causou o problema
- Screenshot do console (F12)
- Descrição do comportamento esperado vs. atual

### Contato:
- **GitHub Issues:** https://github.com/bacanapps/dezembro-vermelho-2025/issues
- **Desenvolvedor:** Claude Code (via repositório GitHub)

---

## 📂 Arquivos do Sistema

### Frontend (GitHub Pages):
```
scanner_live/
├── scanner.html          # Aplicação principal do scanner
├── login.html           # Página de login (se aplicável)
├── assets/
│   ├── style.css       # Estilos visuais
│   ├── logo.png        # Logo Dezembro Vermelho
│   ├── success.mp3     # Som de sucesso
│   ├── error.mp3       # Som de erro
│   └── favicon.png     # Ícone do navegador
└── scanner_instructions.md  # Este arquivo
```

### Backend (N8N):
```
n8n backups/
├── Check-in Dezembro Vermelho 2025 v2.5-JSON.json  # Workflow ativo
├── DEPLOY-v2.5-FINAL-SOLUTION.md                   # Guia de deployment
└── Check-in Dezembro Vermelho 2025 - BACKUP.json   # Backup original
```

### Integração:
- **Google Sheets:** Atividades Dezembro Vermelho 2025
- **Sheet:** Inscricoes_DezembroVermelho
- **Webhook URL:** https://n8n.bebot.co/webhook/checkin-dv-2025

---

## ✅ Checklist Pré-Evento

Antes de cada evento, verifique:

- [ ] Scanner funciona em dispositivo de teste
- [ ] Áudio desbloqueado e funcionando
- [ ] Câmera detectando QR codes corretamente
- [ ] Workflow N8N v2.5 está ativo
- [ ] Google Sheets acessível
- [ ] URL com staffName correto configurada
- [ ] Backup de bateria/carregador disponível
- [ ] Conexão à internet estável
- [ ] Entrada manual testada (fallback)

---

## 🎉 Dicas para Uso Eficiente

1. **Iluminação:** Garanta boa iluminação sobre os QR codes
2. **Distância:** Mantenha 15-30cm entre câmera e QR code
3. **Estabilidade:** Segure firmemente ou use suporte para o dispositivo
4. **Filas:** Organize participantes em fila única
5. **Duplicatas:** Se modal amarelo aparecer, explique educadamente ao participante
6. **Backup:** Sempre tenha entrada manual como alternativa
7. **Bateria:** Mantenha dispositivo carregado (scanner usa câmera constantemente)
8. **Logs:** Monitore console em caso de problemas técnicos

---

## 📊 Relatórios Pós-Evento

Após o evento, você pode acessar:

1. **Google Sheets:** Dados completos de todos os check-ins
2. **Filtros disponíveis:**
   - Por atividade
   - Por horário de check-in
   - Por responsável (checked_by)
   - Por status (CONFIRMADA, etc.)

3. **Estatísticas úteis:**
   - Total de participantes presentes
   - Taxa de presença por atividade
   - Horários de pico de check-in
   - Participantes que tentaram check-in duplicado

---

**Versão:** 2.5
**Última Atualização:** 18 de Novembro de 2025
**Status:** ✅ Produção

**Sistema desenvolvido para Dezembro Vermelho 2025 - 40 anos da resposta brasileira à AIDS**

---

🤖 *Documentação gerada com [Claude Code](https://claude.com/claude-code)*
