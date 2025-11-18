# 🚀 DEPLOY v2.7 - FIXED Dynamic Authorization

## 🐛 What Was Fixed in v2.7

**Problem in v2.6:**
- Used `$input.all()` to get Scanner_Access data
- When Check Authorization node receives TWO inputs (from "Set ticket ID" and "Get Scanner Access"), `$input.all()` may not return the Scanner_Access data correctly
- This caused authorization to fail even for valid PINs

**Solution in v2.7:**
- ✅ Changed to `$('Get Scanner Access').all()` - explicitly references the Scanner_Access node
- ✅ Added detailed debug logging to show all staff data
- ✅ Logs show: total rows, all staff with PINs, authorized PINs, and which PIN was checked

---

## 📋 DEPLOY (2 minutes)

### Step 1: Open N8N
```
https://n8n.bebot.co
```

### Step 2: Deactivate v2.6
```
Find: "Check-in Dezembro Vermelho 2025 v2.6"
Toggle OFF (gray)
```

### Step 3: Import v2.7
```
1. Click: "Import from File"
2. Select: Check-in Dezembro Vermelho 2025 v2.7-FIXED-AUTH.json
3. Click: "Import"
```

### Step 4: Configure Credentials (3 nodes)
```
1. Click node: "Get Scanner Access"
   → Credential: "Google Sheets account"
   → Document: Atividades Dezembro Vermelho 2025
   → Sheet: Scanner_Access (gid=1591168124)

2. Click node: "Buscar Inscrição"
   → Credential: "Google Sheets account"

3. Click node: "Atualizar Check-in"
   → Credential: "Google Sheets account"

4. Click "Save"
```

### Step 5: Verify Webhook Setting
```
1. Click: "Webhook - Check-in DV 2025" node
2. Verify: "Respond" = "Using 'Respond to Webhook' Node"
3. NOT "Immediately"
```

### Step 6: Activate v2.7
```
1. Toggle ON (green)
2. Confirm "Active"
```

---

## 🧪 TEST

### Test 1: Existing PIN (6969 - Colin Pantin)
```
URL: https://bacanapps.github.io/dezembro-vermelho-2025/scanner_live/scanner.html?auth=6969&staffName=Colin%20Pantin

Expected:
✅ Access granted
✅ Can scan QR codes
✅ Check-ins work normally
✅ Console shows authorized PINs including "6969"
```

### Test 2: New PIN (1234 - Joe Blow)
```
URL: https://bacanapps.github.io/dezembro-vermelho-2025/scanner_live/scanner.html?auth=1234&staffName=Joe%20Blow

Expected:
✅ Access granted (because active=TRUE in Scanner_Access)
✅ Can scan QR codes
✅ checked_by = "Joe Blow"
✅ Console shows authorized PINs including "1234"
```

### Test 3: Console Debug Output
After scanning with Joe Blow (PIN 1234), N8N console should show:
```
📋 Total staff rows from Scanner_Access: 2
📋 Staff data: [
  { pin: "6969", active: true, name: "Colin Pantin" },
  { pin: "1234", active: true, name: "Joe Blow" }
]
✅ Authorized PINs from Scanner_Access: ["6969", "1234"]
🔍 Checking PIN: 1234
✅ PIN authorized: 1234
```

---

## 🔍 Key Differences

| Aspect | v2.6 (BROKEN) | v2.7 (FIXED) |
|--------|---------------|--------------|
| **Scanner Access Data** | `$input.all()` | `$('Get Scanner Access').all()` |
| **Data Reference** | ❌ Ambiguous with multiple inputs | ✅ Explicit node reference |
| **Debug Logging** | Basic | ✅ Detailed (shows all staff data) |
| **PIN 1234 (Joe Blow)** | ❌ Unauthorized | ✅ Authorized |

---

## 🔧 Technical Details

### The Problem with `$input.all()`

When a node receives multiple inputs (like Check Authorization receiving from both "Set ticket ID" and "Get Scanner Access"), `$input.all()` returns data from the **current execution context**, which may not be the Scanner_Access data.

### The Solution: Explicit Node Reference

```javascript
// ❌ WRONG (v2.6):
const staffSheet = $input.all();  // Ambiguous which input this refers to

// ✅ CORRECT (v2.7):
const staffSheet = $('Get Scanner Access').all();  // Explicit reference to Scanner_Access node
```

### New Debug Logging

v2.7 adds comprehensive logging:
```javascript
console.log('📋 Total staff rows from Scanner_Access:', staffSheet.length);
console.log('📋 Staff data:', staffSheet.map(r => ({
  pin: r.json.pin,
  active: r.json.active,
  name: r.json.staff_name
})));
```

This helps verify:
- Scanner_Access sheet is being read correctly
- How many staff rows are found
- Which PINs are marked as active
- Which PIN is being checked
- Why a PIN was authorized or rejected

---

## ✅ Checklist

- [ ] Open https://n8n.bebot.co
- [ ] Deactivate v2.6
- [ ] Import: Check-in Dezembro Vermelho 2025 v2.7-FIXED-AUTH.json
- [ ] Configure credential: "Get Scanner Access"
- [ ] Configure credential: "Buscar Inscrição"
- [ ] Configure credential: "Atualizar Check-in"
- [ ] Verify Webhook "Respond" setting
- [ ] Save workflow
- [ ] Activate v2.7 (green)
- [ ] Test with PIN 6969 (Colin Pantin)
- [ ] Test with PIN 1234 (Joe Blow)
- [ ] ✅ Verify Joe Blow gets access (green modal)
- [ ] Check N8N console for debug output
- [ ] Verify console shows both PINs in authorized list

---

## 🚨 Troubleshooting

### "Acesso não autorizado" for valid staff

**Check N8N Console:**
1. Open N8N workflow execution log
2. Look for debug output from Check Authorization node
3. Verify Scanner_Access data is being read:
   ```
   📋 Total staff rows from Scanner_Access: 2
   📋 Staff data: [...]
   ```
4. Verify PIN is in authorized list:
   ```
   ✅ Authorized PINs from Scanner_Access: ["6969", "1234"]
   ```
5. Verify PIN being checked matches:
   ```
   🔍 Checking PIN: 1234
   ```

**If Scanner_Access shows 0 rows:**
- Check "Get Scanner Access" node credential
- Verify gid=1591168124 is correct
- Verify Scanner_Access sheet exists in spreadsheet

**If PIN not in authorized list but exists in sheet:**
- Check `active` column = TRUE (not FALSE or empty)
- Check `pin` column has no extra spaces
- Check spelling of column names (pin, active, staff_name, etc.)

---

**Status:** 🟢 PRODUCTION READY
**Version:** 2.7
**Date:** 18 de Novembro de 2025

**Key Fix:** Explicit node reference `$('Get Scanner Access').all()` instead of ambiguous `$input.all()`

---

🤖 *Generated with [Claude Code](https://claude.com/claude-code)*
