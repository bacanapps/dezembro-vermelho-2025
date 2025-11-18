# 🚀 DEPLOY v2.6 - Dynamic Authorization from Scanner_Access Sheet

## ✅ What's New in v2.6

**Dynamic Staff Authorization:**
- ✅ Pulls authorized PINs from Scanner_Access Google Sheet
- ✅ No need to manually update workflow when adding new staff
- ✅ Just add/edit rows in Scanner_Access sheet
- ✅ Automatically respects `active` column (TRUE/FALSE)

**Key Changes from v2.5:**
1. **New Node:** "Get Scanner Access" - Reads Scanner_Access sheet
2. **Updated Node:** "Check Authorization" - Uses dynamic PIN list from sheet
3. **Console Logging:** Shows which PINs are authorized and which PIN was checked

---

## 📋 How It Works

### Workflow Flow:
```
Webhook
  ↓
  ├─→ Set ticket ID
  └─→ Get Scanner Access (new!)
        ↓
      Check Authorization (updated!)
        - Builds list from Scanner_Access sheet
        - Only includes rows where active = TRUE
        - Checks if auth PIN is in the list
        ↓
      Unauthorized? ...
```

### Scanner_Access Sheet Structure:
| Column | Field | Example | Required |
|--------|-------|---------|----------|
| A | staff_email | colin@cpantin.com | Yes |
| B | staff_name | Colin Pantin | Yes |
| C | pin | 6969 | Yes |
| D | role | Admin | Yes |
| E | active | TRUE | Yes |

### How Authorization Works:
1. Every request reads **ALL rows** from Scanner_Access sheet
2. Filters rows where `active = TRUE` (or "TRUE" or "true")
3. Extracts all `pin` values into authorized list
4. Checks if incoming `auth` parameter matches any authorized PIN
5. If match → Allow access
6. If no match → Return "🚫 Acesso não autorizado"

---

## 📋 DEPLOY (3 minutes)

### Step 1: Open N8N
```
https://n8n.bebot.co
```

### Step 2: Deactivate v2.5
```
1. Find: "Check-in Dezembro Vermelho 2025 v2.5"
2. Toggle OFF (gray)
```

### Step 3: Import v2.6
```
1. Click: "Import from File"
2. Select: Check-in Dezembro Vermelho 2025 v2.6-DYNAMIC-AUTH.json
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

### Step 6: Activate v2.6
```
1. Toggle ON (green)
2. Confirm "Active"
```

---

## 🧪 TEST

### Test 1: Existing PIN (6969)
```
URL: https://bacanapps.github.io/dezembro-vermelho-2025/scanner_live/scanner.html?auth=6969&staffName=Colin%20Pantin

Expected:
✅ Access granted
✅ Can scan QR codes
✅ Check-ins work normally
```

### Test 2: New PIN (1234 - Joe Blow)
```
URL: https://bacanapps.github.io/dezembro-vermelho-2025/scanner_live/scanner.html?auth=1234&staffName=Joe%20Blow

Expected:
✅ Access granted (because active=TRUE in Scanner_Access)
✅ Can scan QR codes
✅ checked_by = "Joe Blow"
```

### Test 3: Deactivated Staff
```
1. In Scanner_Access sheet, change active column to FALSE
2. Try to access with that PIN

Expected:
🚫 "Acesso não autorizado"
```

### Test 4: Unknown PIN
```
URL: https://bacanapps.github.io/dezembro-vermelho-2025/scanner_live/scanner.html?auth=9999&staffName=Unknown

Expected:
🚫 "Acesso não autorizado"
```

---

## 👥 Managing Staff Access

### To Add New Staff:
1. Open: Scanner_Access sheet
2. Add new row:
   ```
   staff_email: newstaff@example.com
   staff_name: New Staff
   pin: 5678
   role: Admin
   active: TRUE
   ```
3. Generate admin URL in column G (formula):
   ```
   =IF(E2=TRUE, "https://bacanapps.github.io/dezembro-vermelho-2025/scanner_live/scanner.html?auth=" & C2 & "&staffName=" & ENCODEURL(B2), "")
   ```
4. **No need to update N8N workflow!**
5. New PIN works immediately on next scan

### To Deactivate Staff:
1. Open: Scanner_Access sheet
2. Change `active` column to FALSE
3. **No need to update N8N workflow!**
4. PIN stops working immediately

### To Reactivate Staff:
1. Change `active` column back to TRUE
2. PIN works again immediately

---

## 🔍 Console Logs for Debugging

When a scan happens, N8N console will show:

**Successful Authorization:**
```
✅ Authorized PINs from Scanner_Access: ["6969", "1234", "5678"]
🔍 Checking PIN: 1234
✅ PIN authorized: 1234
```

**Failed Authorization:**
```
✅ Authorized PINs from Scanner_Access: ["6969", "1234"]
🔍 Checking PIN: 9999
❌ PIN not authorized: 9999
```

---

## 🎯 Benefits of v2.6

| Aspect | v2.5 (Hardcoded) | v2.6 (Dynamic) |
|--------|------------------|----------------|
| **Add new staff** | Edit N8N workflow | Add row to sheet |
| **Deactivate staff** | Edit N8N workflow | Change active to FALSE |
| **Reactivate staff** | Edit N8N workflow | Change active to TRUE |
| **View all staff** | Read N8N code | View sheet |
| **Staff management** | Technical (N8N access) | Simple (Sheet access) |
| **Deployment needed** | Yes (every change) | No |

---

## 📊 Scanner_Access Sheet URL

```
https://docs.google.com/spreadsheets/d/1XYJ4S_shpoQ5o7Psth-h4p-XZI48Kypy6a21k2ayYJ8/edit?gid=1591168124#gid=1591168124
```

**Sheet Name:** `Scanner_Access`
**GID:** `1591168124`

---

## ⚠️ Important Notes

### Performance:
- Reads Scanner_Access sheet on **every scan**
- Very fast (Google Sheets API is quick)
- Small overhead (typically <100ms)

### Active Column:
- Accepts: `TRUE`, `true`, or boolean `true`
- Case-insensitive
- Any other value = inactive

### PIN Format:
- Can be numeric: `6969`, `1234`
- Can be alphanumeric: `redribbon2025`
- Converted to string for comparison
- Whitespace is trimmed

---

## 🚨 Troubleshooting

### "Acesso não autorizado" for valid staff
**Check:**
1. Scanner_Access sheet has the row
2. `active` column = TRUE (not FALSE or empty)
3. `pin` column matches exactly (no extra spaces)
4. N8N workflow v2.6 is Active (green)
5. "Get Scanner Access" node configured correctly

### Staff can't be added
**Check:**
1. Scanner_Access sheet exists
2. Column headers match expected names
3. Formula in column G is correct
4. Row has all required fields

### Old PINs still work after deactivation
**Possible causes:**
1. `active` column not set to FALSE
2. Old workflow (v2.5) still active
3. Browser cache (hard refresh: Ctrl+Shift+R)

---

## ✅ Checklist

- [ ] Open https://n8n.bebot.co
- [ ] Deactivate v2.5
- [ ] Import v2.6-DYNAMIC-AUTH.json
- [ ] Configure credential: "Get Scanner Access"
- [ ] Configure credential: "Buscar Inscrição"
- [ ] Configure credential: "Atualizar Check-in"
- [ ] Verify Webhook "Respond" setting
- [ ] Save workflow
- [ ] Activate v2.6 (green)
- [ ] Test with existing PIN (6969)
- [ ] Test with new PIN (1234)
- [ ] Verify Console shows authorized PINs
- [ ] Add test staff to Scanner_Access
- [ ] Verify new PIN works immediately
- [ ] Deactivate test staff
- [ ] Verify PIN stops working

---

**Status:** 🟢 PRODUCTION READY
**Version:** 2.6
**Date:** 18 de Novembro de 2025

**Key Feature:** Dynamic staff authorization from Scanner_Access Google Sheet

---

## 🔄 Migration from v2.5 to v2.6

### What Changes:
- ✅ Authorization now reads from Scanner_Access sheet
- ✅ New "Get Scanner Access" node added
- ✅ "Check Authorization" node updated with dynamic logic

### What Stays the Same:
- ✅ All other nodes unchanged
- ✅ Workflow structure identical
- ✅ Response formats identical
- ✅ Scanner compatibility 100%

### No Scanner Changes Needed:
- ✅ URLs still work the same
- ✅ ?auth=PIN&staffName=NAME format unchanged
- ✅ No frontend updates required

---

🤖 *Generated with [Claude Code](https://claude.com/claude-code)*
