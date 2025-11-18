# 🔴 Live Activities Setup - Real-Time Availability

## Problem

Your Google Sheets updates when registrations happen:
- Row 1: `vagas_preenchidas: 2, vagas_disponiveis: 98` ✅
- But `activities.json` stays static: `vagas_preenchidas: 0, vagas_disponiveis: 100` ❌

## Solution: N8N Live Data Endpoint

Instead of updating a static file, fetch live data directly from Google Sheets via n8n webhook!

---

## 🚀 Quick Setup (5 minutes)

### Step 1: Import N8N Workflow

1. **Open your n8n instance**: https://n8n.bebot.co
2. **Click** "+ Add workflow" or "Import"
3. **Import the file**: `n8n-live-activities-workflow.json`
4. **Or manually create** (see detailed steps below)

### Step 2: Configure Google Sheets Connection

The workflow reads from:
- **Spreadsheet ID**: `1XYJ4S_shpoQ5o7Psth-h4p-XZI48Kypy6a21k2ayYJ8`
- **Sheet Name**: `Atividades_DezembroVermelho`
- **Range**: `A2:I100` (all activities, skip header)

**Column Mapping:**
- Column A: `id`
- Column B: `data`
- Column C: `horario`
- Column D: `nome_atividade`
- Column E: `tipo`
- Column F: `local`
- Column G: `capacidade`
- Column H: `vagas_preenchidas` ⭐
- Column I: `vagas_disponiveis` ⭐

### Step 3: Activate Workflow

1. **Click** the toggle switch to activate
2. **Copy the webhook URL**: Should look like:
   ```
   https://n8n.bebot.co/webhook/activities-json
   ```
3. **Test it** in browser - should return JSON array

### Step 4: Update Frontend

Edit **index.html** (line ~295):

```javascript
const CONFIG = {
    // OLD (static file):
    // activitiesDataURL: "./activities.json",

    // NEW (live from n8n):
    activitiesDataURL: "https://n8n.bebot.co/webhook/activities-json",

    formType: "dynamic",
    dynamicFormPath: "./form-template.html",
    staticFormPath: "./forms/form-{id}.html"
};
```

Edit **form-template.html** (line ~186):

```javascript
const CONFIG = {
    webhookURL: "https://n8n.bebot.co/webhook/inscricao-dv-2025",

    // OLD:
    // activitiesDataURL: "./activities.json"

    // NEW:
    activitiesDataURL: "https://n8n.bebot.co/webhook/activities-json"
};
```

### Step 5: Test

1. **Refresh index.html**
2. **Check availability numbers** - should match Google Sheets
3. **Make a test registration**
4. **Refresh index.html again**
5. **Availability should update automatically!** ✅

---

## 📋 Manual N8N Workflow Setup

If you prefer to create manually instead of importing:

### Node 1: Webhook (Trigger)

**Type**: Webhook
**Settings**:
- HTTP Method: `GET`
- Path: `activities-json`
- Response Mode: `When Last Node Finishes`
- Allow Origins: `*` (for CORS)

### Node 2: Google Sheets (Read)

**Type**: Google Sheets
**Operation**: Read
**Settings**:
- Document ID: `1XYJ4S_shpoQ5o7Psth-h4p-XZI48Kypy6a21k2ayYJ8`
- Sheet Name: `Atividades_DezembroVermelho`
- Range: `A2:I100`
- Options:
  - ✅ Use Header Row
  - Range Definition: `Specify Range`

### Node 3: Code (Transform)

**Type**: Code (JavaScript)
**Code**:

```javascript
// Transform Google Sheets data to activities.json format
const items = $input.all();

const activities = items
  .filter(item => item.json.id && item.json.id !== '')
  .map(item => ({
    id: parseInt(item.json.id) || 0,
    data: item.json.data || '',
    horario: item.json.horario || '',
    nome_atividade: item.json.nome_atividade || '',
    tipo: item.json.tipo || '',
    local: item.json.local || '',
    capacidade: parseInt(item.json.capacidade) || 0,
    vagas_preenchidas: parseInt(item.json.vagas_preenchidas) || 0,
    vagas_disponiveis: parseInt(item.json.vagas_disponiveis) || 0
  }));

return [{ json: activities }];
```

### Node 4: Respond to Webhook

**Type**: Respond to Webhook
**Settings**:
- Respond With: `JSON`
- Response Body: `={{ $json }}`
- Response Headers:
  - `Content-Type`: `application/json`
  - `Access-Control-Allow-Origin`: `*`
  - `Access-Control-Allow-Methods`: `GET, OPTIONS`
  - `Cache-Control`: `no-cache, no-store, must-revalidate`

### Connections:

```
Webhook → Google Sheets → Code → Respond to Webhook
```

---

## 🧪 Testing the Webhook

### Test 1: Direct Browser Test

Open in browser:
```
https://n8n.bebot.co/webhook/activities-json
```

**Expected Response:**
```json
[
  {
    "id": 1,
    "data": "01/12/2025",
    "horario": "15:00-16:00",
    "nome_atividade": "Lançamento da campanha...",
    "tipo": "Palestra",
    "local": "SESILAB",
    "capacidade": 100,
    "vagas_preenchidas": 2,
    "vagas_disponiveis": 98
  },
  ...
]
```

### Test 2: Curl Test

```bash
curl https://n8n.bebot.co/webhook/activities-json
```

### Test 3: JavaScript Test

```javascript
fetch('https://n8n.bebot.co/webhook/activities-json')
  .then(r => r.json())
  .then(data => console.log('Activities:', data));
```

### Test 4: Real-Time Update Test

1. **Open index.html** in browser
2. **Note availability** for Activity #1 (e.g., "98 vagas disponíveis")
3. **Go to Google Sheets**
4. **Manually change** `vagas_preenchidas` to 3, `vagas_disponiveis` to 97
5. **Refresh index.html**
6. **Should show** "97 vagas disponíveis" immediately! ✅

---

## 🎯 Benefits

### ✅ Real-Time Updates
- Every page load fetches fresh data
- No manual sync needed
- Always shows current availability

### ✅ No File Updates
- No need to edit activities.json
- No deployment needed for data changes
- Google Sheets is single source of truth

### ✅ Simple Maintenance
- Update availability in Google Sheets only
- Frontend automatically reflects changes
- n8n handles all the transformation

### ✅ Works with Existing Registration Flow
- Registration workflow updates Google Sheets ✅
- Live activities endpoint reads from same sheet ✅
- Frontend shows updated numbers automatically ✅

---

## 🔄 Complete Data Flow

```
┌─────────────────────────────────────────────────┐
│                 USER JOURNEY                     │
└─────────────────────────────────────────────────┘

1. User visits index.html
   ↓
2. Frontend fetches: GET /webhook/activities-json
   ↓
3. N8N reads Google Sheets (current availability)
   ↓
4. N8N transforms to JSON format
   ↓
5. N8N returns activities array
   ↓
6. Frontend displays activities with real availability
   ↓
7. User makes registration
   ↓
8. Registration workflow updates Google Sheets:
   - vagas_preenchidas + 1
   - vagas_disponiveis - 1
   ↓
9. Next user visits → sees updated availability!
```

---

## 📊 Performance

### Speed:
- **Response time**: ~200-500ms (fast!)
- **Data size**: ~10KB (small!)
- **Concurrent users**: Unlimited (n8n handles it)

### Caching:
- **No caching** by default (shows real-time data)
- If needed, can add cache headers for 30-60 seconds
- Trade-off: Speed vs. Real-time accuracy

### Optional Cache (if traffic is very high):

Update **Node 4 (Respond)** headers:
```javascript
{
  "Cache-Control": "public, max-age=30"  // Cache for 30 seconds
}
```

---

## 🐛 Troubleshooting

### Issue: CORS Error

**Symptom:**
```
Access to fetch at 'https://n8n.bebot.co/...' has been blocked by CORS policy
```

**Fix:**
1. Check **Respond to Webhook** node
2. Verify response headers include:
   - `Access-Control-Allow-Origin: *`
   - `Access-Control-Allow-Methods: GET, OPTIONS`

### Issue: 404 Not Found

**Symptom:**
```
GET https://n8n.bebot.co/webhook/activities-json 404
```

**Fix:**
1. Check workflow is **activated** (toggle on)
2. Verify webhook path is `activities-json` (no typos)
3. Test workflow manually in n8n editor

### Issue: Empty Array Returned

**Symptom:**
```json
[]
```

**Fix:**
1. Check Google Sheets has data starting at row 2
2. Verify sheet name is exactly `Atividades_DezembroVermelho`
3. Check range `A2:I100` includes your data
4. Look at **Read Activities** node output in n8n

### Issue: Data Not Updating

**Symptom:** Old availability numbers still showing

**Fix:**
1. Hard refresh browser (Ctrl+Shift+R or Cmd+Shift+R)
2. Clear browser cache
3. Check if frontend is really using webhook URL (not static file)
4. Test webhook directly in browser - does it show fresh data?

### Issue: Slow Loading

**Symptom:** Activities take long to load

**Fix:**
1. Check n8n server performance
2. Reduce range (e.g., `A2:I50` if you only have 30 activities)
3. Add caching (see Performance section above)

---

## 🔒 Security Considerations

### Public Endpoint
- ✅ **Safe**: Only returns activity data (read-only)
- ✅ **No sensitive info**: Public event details only
- ✅ **No write access**: Can't modify Google Sheets

### Rate Limiting (Optional)
If you want to prevent abuse, add rate limiting in n8n:

**Add Node before "Read Activities":**
```javascript
// Rate limiting code
const ip = $node["Webhook - Get Activities"].json.headers['x-forwarded-for'];
// Implement rate limiting logic
```

---

## 📈 Monitoring

### Check Webhook Usage

In n8n:
1. **Go to** Executions tab
2. **Filter by** "Get Live Activities" workflow
3. **See** how many times it's been called
4. **Monitor** for errors

### Google Sheets API Quota

Google Sheets API has limits:
- **Read**: 100 requests per 100 seconds per user
- **Daily**: 300,000,000 cells per day

With your traffic, you won't hit limits, but good to know!

---

## 🎛️ Advanced Configuration

### Option 1: Add Specific Activity Endpoint

Create another workflow to get single activity:

**Webhook Path**: `activity/{id}`

**Code**:
```javascript
const activityId = $node["Webhook"].json.params.id;
const activities = $input.all();
const activity = activities.find(a => String(a.json.id) === activityId);
return [activity || { json: { error: 'Activity not found' } }];
```

**Use**: `https://n8n.bebot.co/webhook/activity/1`

### Option 2: Filter by Date

**Webhook Path**: `activities-by-date/{date}`

**Code**:
```javascript
const date = $node["Webhook"].json.params.date; // e.g., "01/12/2025"
const activities = $input.all();
const filtered = activities.filter(a => a.json.data === date);
return [{ json: filtered }];
```

**Use**: `https://n8n.bebot.co/webhook/activities-by-date/01/12/2025`

### Option 3: Include Statistics

**Code** (in Transform node):
```javascript
const items = $input.all();

const activities = items
  .filter(item => item.json.id && item.json.id !== '')
  .map(item => ({
    // ... existing mapping ...
  }));

// Calculate stats
const stats = {
  total: activities.length,
  total_capacity: activities.reduce((sum, a) => sum + a.capacidade, 0),
  total_filled: activities.reduce((sum, a) => sum + a.vagas_preenchidas, 0),
  total_available: activities.reduce((sum, a) => sum + a.vagas_disponiveis, 0),
  types: [...new Set(activities.map(a => a.tipo))].length
};

return [{
  json: {
    activities,
    stats,
    last_updated: new Date().toISOString()
  }
}];
```

---

## 📚 Summary

### What You Need to Do:

1. ✅ **Import workflow** to n8n (or create manually)
2. ✅ **Activate workflow**
3. ✅ **Update frontend** (2 lines in index.html, 2 in form-template.html)
4. ✅ **Test** - refresh page, should show live data

### What Happens After:

1. ✅ **Every page load** fetches fresh data from Google Sheets
2. ✅ **Registrations** update Google Sheets
3. ✅ **Next page load** shows updated availability
4. ✅ **No manual work** needed!

### Files:

- ✅ `n8n-live-activities-workflow.json` - Import this to n8n
- ✅ `LIVE-ACTIVITIES-SETUP.md` - This guide

---

## 🎉 Ready to Go!

1. Import workflow to n8n
2. Activate it
3. Update frontend config (4 lines total)
4. Done! Real-time availability is live! 🚀

**Test URL after setup:**
```
https://n8n.bebot.co/webhook/activities-json
```

Should return array of activities with **live** `vagas_disponiveis` from Google Sheets!

---

**Questions?** Test the workflow in n8n editor first to see it working.
