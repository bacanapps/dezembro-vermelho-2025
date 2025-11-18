# 🔄 Activities Sync Setup Guide

## Problem

Your Google Sheets updates in real-time when registrations come in, but `activities.json` stays static. Users see outdated availability on the frontend.

## Solution: 3 Options

---

## ✅ Option 1: Simple N8N Webhook (Recommended - Easiest!)

**No Google API setup needed!** Use your existing n8n workflow.

### Step 1: Add New Webhook to N8N

1. **Open your n8n instance**
2. **Create a new workflow** (or add to existing)
3. **Add these nodes**:

```
Webhook → Get Activities from Sheet → Format as JSON → Respond
```

#### Node 1: Webhook
- **Webhook Name**: `get-activities`
- **Method**: `GET`
- **Path**: `activities-json`
- **Response**: `When Last Node Finishes`

#### Node 2: Google Sheets (Read)
- **Operation**: `Read`
- **Spreadsheet ID**: `1XYJ4S_shpoQ5o7Psth-h4p-XZI48Kypy6a21k2ayYJ8`
- **Sheet Name**: `Atividades_DezembroVermelho`
- **Range**: `A2:I100` (or adjust as needed)

#### Node 3: Code (Transform to JSON)
```javascript
// Transform Google Sheets data to activities.json format
const rows = $input.all();

const activities = rows.map(item => ({
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

#### Node 4: Respond to Webhook
- **Respond With**: `JSON`
- **Response Body**: `={{$json}}`
- **Options** → **Response Headers**:
  - `Content-Type`: `application/json`
  - `Access-Control-Allow-Origin`: `*` (for CORS)

### Step 2: Update Frontend to Use Live Data

Edit `index.html` line ~273:

```javascript
const CONFIG = {
    // Option A: Use static file (manual updates)
    // activitiesDataURL: "./activities.json",

    // Option B: Use live data from n8n (real-time!)
    activitiesDataURL: "https://n8n.bebot.co/webhook/activities-json",

    formType: "dynamic",
    dynamicFormPath: "./form-template.html"
};
```

Edit `form-template.html` line ~186:

```javascript
const CONFIG = {
    webhookURL: "https://n8n.bebot.co/webhook/inscricao-dv-2025",

    // Option A: Static file
    // activitiesDataURL: "./activities.json"

    // Option B: Live data from n8n
    activitiesDataURL: "https://n8n.bebot.co/webhook/activities-json"
};
```

### Step 3: Test

1. Activate the n8n workflow
2. Test the endpoint: `https://n8n.bebot.co/webhook/activities-json`
3. Should return JSON array with all activities and current availability
4. Refresh your index.html - should show live data!

### ✅ Benefits:
- ✅ No API credentials needed
- ✅ Uses existing n8n setup
- ✅ Real-time data automatically
- ✅ Works immediately
- ✅ No periodic sync needed

---

## ✅ Option 2: Automated Sync Script (Google Sheets API)

**Best for**: Periodic syncing without n8n dependency

### Step 1: Install Dependencies

```bash
npm install googleapis
```

### Step 2: Get Google API Credentials

1. **Go to**: https://console.cloud.google.com/
2. **Create a new project** (or use existing)
3. **Enable Google Sheets API**:
   - Go to "APIs & Services" → "Library"
   - Search for "Google Sheets API"
   - Click "Enable"
4. **Create Service Account**:
   - Go to "APIs & Services" → "Credentials"
   - Click "Create Credentials" → "Service Account"
   - Name it: `dezembro-vermelho-sync`
   - Click "Create and Continue"
   - Skip roles (optional)
   - Click "Done"
5. **Create Key**:
   - Click on the service account you just created
   - Go to "Keys" tab
   - Click "Add Key" → "Create New Key"
   - Choose "JSON"
   - Click "Create"
   - Save the downloaded JSON file as `google-credentials.json`

### Step 3: Share Google Sheet with Service Account

1. Open your downloaded `google-credentials.json`
2. Copy the `client_email` (looks like: `xxx@xxx.iam.gserviceaccount.com`)
3. Open your Google Sheet
4. Click "Share"
5. Paste the email
6. Give "Viewer" permission
7. Click "Send"

### Step 4: Save Credentials

Place the downloaded JSON file in your project directory:

```bash
mv ~/Downloads/your-credentials-file.json ./google-credentials.json
```

### Step 5: Run Sync

```bash
# Manual sync
node sync-activities.js

# Or add to package.json scripts:
npm run sync
```

### Step 6: Automate (Optional)

**Mac/Linux (cron):**
```bash
# Edit crontab
crontab -e

# Add line to sync every 5 minutes:
*/5 * * * * cd /path/to/project && node sync-activities.js >> sync.log 2>&1
```

**Windows (Task Scheduler):**
1. Open Task Scheduler
2. Create Basic Task
3. Trigger: Every 5 minutes
4. Action: Start a program
5. Program: `node`
6. Arguments: `sync-activities.js`
7. Start in: Your project directory

### ✅ Benefits:
- ✅ Works offline (after initial fetch)
- ✅ Independent of n8n
- ✅ Can be automated with cron/Task Scheduler
- ✅ Creates backups automatically

---

## ✅ Option 3: Manual Sync (Simplest)

**No setup required!** Use this Google Sheets script.

### Step 1: Add Script to Google Sheets

1. Open your Google Sheet
2. Go to **Extensions** → **Apps Script**
3. Paste this code:

```javascript
function exportToJSON() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName('Atividades_DezembroVermelho');
  const range = sheet.getRange('A2:I100'); // Adjust as needed
  const values = range.getValues();

  const activities = values
    .filter(row => row[0]) // Skip empty rows
    .map(row => ({
      id: parseInt(row[0]) || 0,
      data: row[1] || '',
      horario: row[2] || '',
      nome_atividade: row[3] || '',
      tipo: row[4] || '',
      local: row[5] || '',
      capacidade: parseInt(row[6]) || 0,
      vagas_preenchidas: parseInt(row[7]) || 0,
      vagas_disponiveis: parseInt(row[8]) || 0
    }));

  const json = JSON.stringify(activities, null, 2);

  // Log the JSON (you can copy from logs)
  Logger.log(json);

  // Or save to Drive
  const fileName = 'activities.json';
  const folder = DriveApp.getRootFolder(); // Or get specific folder

  // Check if file exists
  const files = folder.getFilesByName(fileName);
  if (files.hasNext()) {
    const file = files.next();
    file.setContent(json);
    Logger.log('Updated: ' + file.getUrl());
  } else {
    const file = folder.createFile(fileName, json, MimeType.PLAIN_TEXT);
    Logger.log('Created: ' + file.getUrl());
  }
}
```

### Step 2: Run Manually

1. Click the ▶️ Run button
2. Authorize the script (first time only)
3. Check **Execution log** for the JSON
4. Copy and paste into your `activities.json`

### Step 3: Create Menu (Optional)

Add this to create a menu item:

```javascript
function onOpen() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('🎗 Dezembro Vermelho')
    .addItem('Export to JSON', 'exportToJSON')
    .addToUi();
}
```

Now you'll have a menu item to export with one click!

### ✅ Benefits:
- ✅ No API setup
- ✅ No credentials needed
- ✅ Simple copy-paste
- ✅ Good for occasional updates

---

## 🎯 Comparison

| Feature | Option 1 (N8N) | Option 2 (API) | Option 3 (Manual) |
|---------|---------------|----------------|-------------------|
| **Setup Difficulty** | Easy | Medium | Very Easy |
| **Real-time** | ✅ Yes | ⚠️ Periodic | ❌ Manual |
| **API Credentials** | ❌ Not needed | ✅ Required | ❌ Not needed |
| **Automation** | ✅ Automatic | ✅ Cron/Scheduled | ❌ Manual |
| **N8N Dependency** | ✅ Required | ❌ Independent | ❌ Independent |
| **Best For** | Production | Automation | Development |

---

## 🧪 Testing

After setup, verify the sync works:

### Test Sync:

```bash
# If using Option 2 (API):
node sync-activities.js

# Expected output:
# 🎗 DEZEMBRO VERMELHO 2025 - Activities Sync
# ============================================
# 📊 Fetching data from Google Sheets...
# ✅ Fetched 30 rows from Google Sheets
# 💾 Creating backup of current activities.json...
# 📝 Writing updated data to activities.json...
# ✅ activities.json updated successfully!
```

### Test Frontend:

1. Open `index.html`
2. Check activity availability numbers
3. Make a test registration
4. Check Google Sheets (should update)
5. Re-sync or refresh (depending on option)
6. Refresh `index.html`
7. Availability should be updated!

---

## 🔧 Troubleshooting

### Option 1 (N8N): "Failed to fetch"

**Problem**: CORS error or endpoint not accessible

**Solution**:
- Check n8n workflow is active
- Verify CORS headers are set in response
- Test endpoint directly in browser
- Check URL is correct in frontend config

### Option 2 (API): "Google credentials file not found"

**Problem**: Missing or incorrectly named credentials file

**Solution**:
```bash
# Check file exists
ls -la google-credentials.json

# Should be in the project root directory
# Rename if needed:
mv your-file.json google-credentials.json
```

### Option 2 (API): "Permission denied"

**Problem**: Service account not shared with sheet

**Solution**:
1. Open `google-credentials.json`
2. Copy the `client_email`
3. Share your Google Sheet with that email
4. Give "Viewer" permission

### All Options: "Data not updating"

**Problem**: Cache or old data

**Solution**:
- Hard refresh browser (Ctrl+Shift+R or Cmd+Shift+R)
- Clear browser cache
- Check activities.json file was actually updated
- Verify correct URL is being fetched

---

## 📚 Files

- `sync-activities.js` - Sync script (Option 2)
- `google-credentials.json` - API credentials (Option 2, you create this)
- `activities.json` - Activities data (updated by sync)
- `activities.backup.json` - Backup (created automatically)

---

## 🎉 Recommended Setup

**For Production**: Use **Option 1 (N8N Webhook)**
- Real-time updates
- No extra setup
- Most reliable

**For Development**: Use **Option 3 (Manual)**
- Simple and quick
- No credentials needed
- Good enough for testing

**For Automation**: Use **Option 2 (API + Cron)**
- Independent of n8n
- Scheduled updates
- Best for long-term maintenance

---

## 📞 Need Help?

Check these resources:
- Main documentation: [README.md](README.md)
- N8N workflow fix: [N8N-WORKFLOW-FIX.md](N8N-WORKFLOW-FIX.md)
- Quick start: [QUICK-START.md](QUICK-START.md)

---

**Questions?** Check the console output for error messages and refer to the troubleshooting section above.
