# 🔧 N8N Workflow Fix - Proper Duplicate Detection

## 🐛 THE PROBLEM

Your n8n workflow has a **critical bug** in the duplicate detection logic:

### Current "Verificar Duplicata" Node (Lines 639-649)
```javascript
// Get all registrations
const allRegistrations = $input.all();

// Get the email and activity we're checking
const checkEmail = $node["Validar Dados"].json.email;
const checkActivity = $node["Validar Dados"].json.atividade;

// Find duplicate
const duplicate = allRegistrations.find(item =>
  item.json.email === checkEmail &&
  item.json.atividade === checkActivity
);
```

### ❌ Why This Fails:

The node tries to check `$input.all()` but **there's NO Google Sheets query before it** to actually fetch existing enrollments! The workflow goes:

```
Capacidade Esgotada? → Verificar Duplicata
```

But "Verificar Duplicata" has **no input data** because it doesn't query the `Inscricoes_DezembroVermelho` sheet.

Result: **ALWAYS returns "no duplicate" even when duplicates exist!**

---

## ✅ THE SOLUTION

Add a new Google Sheets node to query existing enrollments **BEFORE** checking for duplicates.

### Step-by-Step Fix

#### 1. Add "Buscar Inscrições Existentes" Node

**Position:** Between "Capacidade Esgotada?1" and "Verificar Duplicata"

**Node Type:** Google Sheets
**Operation:** Read Rows
**Settings:**
- **Document ID:** `={{$node["Definir Constantes"].json.SHEET_ID}}`
- **Sheet Name:** `={{$node["Definir Constantes"].json.TAB_INSCRICOES}}`
- **Filters:**
  - **Column:** `email`
  - **Value:** `={{$node["Validar Dados"].json.email}}`
  - **Column:** `atividade_id`
  - **Value:** `={{$node["Validar Dados"].json.atividade}}`
- **Options:**
  - ✅ Return All Matches

#### 2. Update "Verificar Duplicata" Node

Replace the current code with:

```javascript
// Get the query results from Google Sheets
const enrollments = $input.all();

// Get the email and activity we're checking (normalize email to lowercase)
const checkEmail = $node["Validar Dados"].json.email.toLowerCase();
const checkActivity = String($node["Validar Dados"].json.atividade);

console.log(`🔍 Checking for duplicate: ${checkEmail} + Activity ${checkActivity}`);
console.log(`📊 Found ${enrollments.length} existing enrollment(s)`);

// Check if any enrollment matches
const duplicate = enrollments.find(item => {
  const enrollEmail = (item.json.email || '').toLowerCase().trim();
  const enrollActivity = String(item.json.atividade_id || item.json.atividade);

  return enrollEmail === checkEmail && enrollActivity === checkActivity;
});

if (duplicate) {
  console.log(`❌ DUPLICATE FOUND: Ticket ${duplicate.json.ticket_id}`);
  return [{
    json: {
      duplicate: true,
      ticket_id: duplicate.json.ticket_id,
      timestamp: duplicate.json.timestamp,
      status: duplicate.json.status
    }
  }];
} else {
  console.log(`✅ NO DUPLICATE - New enrollment allowed`);
  return [{
    json: {
      no_duplicate: true
    }
  }];
}
```

#### 3. Update "Já Inscrito?" IF Node

Change the condition to properly detect duplicates:

**Current:**
```
Condition: {{$json.ticket_id}} (boolean check)
```

**Change to:**
```
Field: {{$json.duplicate}}
Operator: equals (boolean)
Value: true
```

#### 4. Update "Responder Duplicata" Node

Make the response clearer:

```javascript
{
  "status": "duplicate",
  "message": "Você já está inscrito nesta atividade! Verifique seu email para mais detalhes da inscrição existente.",
  "ticket_id": "={{$json.ticket_id}}",
  "registration_date": "={{$json.timestamp}}"
}
```

---

## 📊 Updated Workflow Flow

```
Webhook
  ↓
Validar Dados
  ↓
Buscar Atividade
  ↓
Capacidade Esgotada?
  ├─ [YES] → Responder Capacidade Esgotada
  └─ [NO] → **Buscar Inscrições Existentes** (NEW!)
               ↓
            Verificar Duplicata (UPDATED!)
               ↓
            Já Inscrito? (UPDATED!)
              ├─ [YES] → Responder Duplicata (UPDATED!)
              └─ [NO] → Gerar Ticket e QR
                          ↓
                       [Continue normal flow...]
```

---

## 🎯 Complete Node Configuration

### Node 1: "Buscar Inscrições Existentes"

```json
{
  "parameters": {
    "operation": "read",
    "documentId": {
      "__rl": true,
      "value": "={{$node['Definir Constantes'].json.SHEET_ID}}",
      "mode": "id"
    },
    "sheetName": {
      "__rl": true,
      "value": "={{$node['Definir Constantes'].json.TAB_INSCRICOES}}",
      "mode": "name"
    },
    "filtersUI": {
      "values": [
        {
          "lookupColumn": "email",
          "lookupValue": "={{$node['Validar Dados'].json.email.toLowerCase().trim()}}"
        },
        {
          "lookupColumn": "atividade_id",
          "lookupValue": "={{String($node['Validar Dados'].json.atividade)}}"
        }
      ]
    },
    "options": {
      "returnAllMatches": "returnAllMatches"
    }
  },
  "name": "Buscar Inscrições Existentes",
  "type": "n8n-nodes-base.googleSheets",
  "typeVersion": 4.2,
  "position": [1376, 176]
}
```

### Node 2: "Verificar Duplicata" (Updated Code)

```javascript
// Get the query results from Google Sheets
const enrollments = $input.all();

// Get the email and activity we're checking (normalize email to lowercase)
const checkEmail = $node["Validar Dados"].json.email.toLowerCase().trim();
const checkActivity = String($node["Validar Dados"].json.atividade);

console.log(`🔍 Checking for duplicate: ${checkEmail} + Activity ${checkActivity}`);
console.log(`📊 Found ${enrollments.length} existing enrollment(s)`);

// Check if any enrollment matches (case-insensitive email comparison)
const duplicate = enrollments.find(item => {
  const enrollEmail = (item.json.email || '').toLowerCase().trim();
  const enrollActivity = String(item.json.atividade_id || item.json.atividade || '');

  const isMatch = enrollEmail === checkEmail && enrollActivity === checkActivity;

  if (isMatch) {
    console.log(`✅ Match found: ${item.json.ticket_id}`);
  }

  return isMatch;
});

if (duplicate) {
  console.log(`❌ DUPLICATE FOUND: Ticket ${duplicate.json.ticket_id}`);
  return [{
    json: {
      duplicate: true,
      ticket_id: duplicate.json.ticket_id,
      timestamp: duplicate.json.timestamp,
      status: duplicate.json.status,
      nome_completo: duplicate.json.nome_completo,
      atividade_nome: duplicate.json.atividade_nome
    }
  }];
} else {
  console.log(`✅ NO DUPLICATE - New enrollment allowed`);
  return [{
    json: {
      no_duplicate: true,
      duplicate: false
    }
  }];
}
```

---

## 🔗 Update Workflow Connections

### Remove This Connection:
```
Capacidade Esgotada?1 → Verificar Duplicata
```

### Add These Connections:
```
Capacidade Esgotada?1 → Buscar Inscrições Existentes
Buscar Inscrições Existentes → Verificar Duplicata
Verificar Duplicata → Handle Empty Result (keep existing)
```

---

## ✅ Testing Checklist

After implementing these changes:

### 1. Test New Enrollment
- [ ] Submit form with new email + activity combination
- [ ] Should succeed and create enrollment
- [ ] Should receive confirmation email
- [ ] Should show confirmation page

### 2. Test Duplicate Enrollment
- [ ] Submit form again with **same email + same activity**
- [ ] Should return: `{"status":"duplicate","message":"..."}"`
- [ ] Should **NOT** create duplicate in Google Sheets
- [ ] Should **NOT** send duplicate email
- [ ] Frontend should show: "Você já está inscrito nesta atividade!"

### 3. Test Different Activity
- [ ] Submit form with **same email + different activity**
- [ ] Should succeed (allowed to enroll in multiple activities)
- [ ] Should create new enrollment

### 4. Test Case Sensitivity
- [ ] Enroll with: `colin@example.com`
- [ ] Try duplicate with: `Colin@Example.com` (different case)
- [ ] Should detect as duplicate (case-insensitive)

### 5. Test Console Logs
Open n8n execution logs and verify you see:
```
🔍 Checking for duplicate: colin@example.com + Activity 30
📊 Found 1 existing enrollment(s)
❌ DUPLICATE FOUND: Ticket DV25-ABC123
```

---

## 🐛 Troubleshooting

### "Buscar Inscrições Existentes" returns empty

**Problem:** Google Sheets filter not working
**Solution:**
1. Check column names in `Inscricoes_DezembroVermelho` sheet match exactly: `email` and `atividade_id`
2. Ensure email is stored in lowercase in the sheet
3. Try removing filters and use "Verificar Duplicata" code to filter instead

### Still creating duplicates

**Check:**
1. Is "Buscar Inscrições Existentes" node connected properly?
2. Are the connections in the right order?
3. Check n8n execution logs for the duplicate check output
4. Verify the "Já Inscrito?" IF condition is checking `{{$json.duplicate}} = true`

### Duplicate detection too strict

If you want to allow same person in different activities:
- ✅ Current filter checks: `email` AND `atividade_id` (correct)
- ❌ If checking only `email`, would block all activities for same person

---

## 📋 Implementation Steps

### Quick Setup (5 minutes):

1. **Open n8n workflow** "1. DV | Receber Inscrições 2.0"

2. **Add new node** after "Capacidade Esgotada?1":
   - Type: Google Sheets
   - Name: "Buscar Inscrições Existentes"
   - Configure as shown above

3. **Update "Verificar Duplicata"** node code (copy-paste from above)

4. **Update "Já Inscrito?"** IF condition:
   - Change to: `{{$json.duplicate}}` equals `true`

5. **Update connections**:
   - Disconnect: `Capacidade Esgotada?1` from `Verificar Duplicata`
   - Connect: `Capacidade Esgotada?1` → `Buscar Inscrições Existentes`
   - Connect: `Buscar Inscrições Existentes` → `Verificar Duplicata`

6. **Save** and **Activate** workflow

7. **Test** with the checklist above

---

## 📸 Visual Guide

### Before (Broken):
```
Capacidade Esgotada?
    ↓
Verificar Duplicata ❌ (no data to check!)
    ↓
Já Inscrito? ❌ (always false)
    ↓
Gerar Ticket ✅ (creates duplicate!)
```

### After (Fixed):
```
Capacidade Esgotada?
    ↓
Buscar Inscrições Existentes ✅ (queries sheet)
    ↓
Verificar Duplicata ✅ (has data!)
    ↓
Já Inscrito? ✅ (properly detects)
    ├─ YES → Responder Duplicata ✅
    └─ NO → Gerar Ticket ✅
```

---

## 🎉 Expected Result

After this fix:

✅ **First enrollment:** Creates new registration
❌ **Duplicate enrollment:** Returns error, no duplicate created
✅ **Same email, different activity:** Allowed
✅ **Case-insensitive email matching:** Works correctly
✅ **Frontend shows proper error:** "Você já está inscrito nesta atividade!"

---

## 📚 Related Files

- `form-template.html` - Already updated with client-side duplicate prevention
- `confirmation-template.html` - Already protected from unauthorized access
- `N8N-WORKFLOW-FIX.md` - General n8n configuration guide
- This file: `N8N-DUPLICATE-FIX.md` - Duplicate detection fix

---

**Questions?** Test the workflow and check the execution logs for detailed debugging information.
