# Essential Files Audit - Dezembro Vermelho 2025 System

**Audit Date:** 2025-01-18
**System:** Enrollment system for Dezembro Vermelho 2025 events
**Purpose:** Identify essential files required to run n8n workflows and frontend system

---

## 🎯 CRITICAL FILES (Required for System to Function)

### 1. N8N Workflows

#### **Primary Active Workflow:**
- `Dezembro Vermelho - Inscrições v9.1.json` ⭐ **ESSENTIAL**
  - **Purpose:** Main enrollment workflow for accepting registrations
  - **Features:**
    - Webhook endpoint: `/webhook/inscricao-dv-2025`
    - Duplicate detection with manual filtering
    - Ticket generation (format: DV25-XXXXXXX)
    - Google Sheets integration (save enrollments)
    - Gmail integration (send confirmation emails)
    - Capacity management
    - QR code generation
  - **Dependencies:**
    - Google Sheets OAuth2 credentials
    - Gmail OAuth2 credentials
    - Active Google Sheet: `1XYJ4S_shpoQ5o7Psth-h4p-XZI48Kypy6a21k2ayYJ8`
  - **Status:** v9.1 with manual duplicate checking logic

#### **Secondary Workflow (Optional but Recommended):**
- `n8n-live-activities-workflow.json` ⚠️ **RECOMMENDED**
  - **Purpose:** Dynamic activities endpoint
  - **Endpoint:** `/webhook/activities-json`
  - **Function:** Serves activities data from Google Sheets to frontend
  - **Note:** Can be replaced with static `activities.json` file

### 2. Frontend Files (Public Website)

#### **Core HTML Pages:**
- `index.html` ⭐ **ESSENTIAL**
  - Homepage displaying all available activities
  - Activity cards with registration buttons
  - Filters by date, type, location
  - Links to form-template.html with activity ID

- `form-template.html` ⭐ **ESSENTIAL**
  - Dynamic enrollment form (works for all activities)
  - URL parameter: `?id={activity_id}`
  - Client-side duplicate prevention (localStorage)
  - Submits to n8n webhook
  - Form validation (nome_completo, email, atividade)
  - CPF field (optional)
  - LGPD consent checkbox

- `confirmation-template.html` ⭐ **ESSENTIAL**
  - Post-enrollment confirmation page
  - Displays ticket ID
  - Shows QR code for event access
  - Activity details display
  - Receives data from localStorage set by form-template.html

#### **Data Files:**
- `activities.json` ⭐ **ESSENTIAL**
  - Contains all event/activity data
  - Used by index.html and form-template.html
  - Fields: id, nome_atividade, data, horario, local, tipo, capacidade, vagas_preenchidas, vagas_disponiveis
  - **Can be replaced by dynamic webhook endpoint**

### 3. Configuration Files

- `package.json` ⚠️ **RECOMMENDED**
  - Defines local development server
  - Scripts: `npm run serve` (port 8000)
  - Not required for production if using different web server

---

## 📦 SUPPORTING FILES (Helpful but Not Critical)

### Documentation
- `README.md` - General project overview
- `SYSTEM-OVERVIEW.md` - System architecture documentation
- `START-HERE.md` - Quick start guide

### Utility Scripts
- `generate-forms.js` - Historical: Generated individual forms (no longer used with form-template.html)
- `sync-activities.js` - Sync activities from Google Sheets to local JSON
- `frontend-config-update.js` - Update configuration in frontend files
- `enable-live-data.sh` - Switch from static to dynamic data loading

### Testing Files
- `test-local.html` - Test form locally
- `test-confirmation.html` - Test confirmation page
- `test-form-debug.html` - Debug form submissions
- `test-webhook-data.js` - Test webhook data structure

---

## 🗑️ OBSOLETE/BACKUP FILES (Can Be Archived or Deleted)

### Old Workflow Versions (in `n8n broken/` and `n8n backups/`)
- `DEZEMBRO_VERMELHO_v8.0_FINAL.json` - Superseded by v9.1
- `DEZEMBRO_VERMELHO_v8.1_FIXED.json` - Had bug with filters
- `DEZEMBRO_VERMELHO_v8.2_DEBUG.json` - Debug version
- `1. DV _ Receber Inscrições 7.0.json` - Very old version
- `1. DV _ Receber Inscrições 2.0.json` - Old version
- All files in `n8n backups/v 1.0/` - Archived versions

**Recommendation:** Keep backups but can be moved to separate archive folder

### Old Documentation (Outdated Instructions)
- `N8N-WORKFLOW-FIX.md`
- `N8N-QUICK-FIX.md`
- `FIX-CORS-N8N.md`
- `FIX-FORM-NOT-SUBMITTING.md`
- `FIX-N8N-500-ERROR.md`
- `FIX-UNUSED-WEBHOOK-NODE.md`
- `IMPORT-N8N-WORKFLOW.md`
- `IMPORT-v8.0-NOW.md`
- `READ-ME-FIRST-v8.0.md`
- `URGENT-IMPORT-NOW.md`
- `URGENT-USE-v8.1.md`
- `v8.0-QUICK-START.md`
- `TEST-NOW.md`
- `TEST-DUPLICATE-PREVENTION.md`
- `DUPLICATE-PREVENTION-SUMMARY.md`
- `FINAL-SOLUTION-SUMMARY.md`

**Recommendation:** These document the troubleshooting process but are no longer needed for operation. Can be archived.

### Scanner Application (`scanner_live/` and `scanner_old/`)
- **Purpose:** Check-in system for scanning QR codes at events
- **Status:** Separate system, not required for enrollment workflow
- **Files:**
  - `scanner_live/` - Current scanner version
  - `scanner_old/` - Old scanner versions
- **Recommendation:** Keep scanner_live/, archive scanner_old/

### Other Archive Material
- `Archive 4.zip` - Unknown archive
- `forms.zip` - Old forms backup
- `programacao_dezembrovermelho_compartilhavel.docx` - Source document
- `programacao_dezembrovermelho_compartilhavel.pdf` - Source PDF
- `programacao_dezembrovermelho.txt` - Text extraction
- `v1.0/` folder - Version 1.0 of entire system

**Recommendation:** Archive to separate backup location

---

## 🔧 SYSTEM DEPENDENCIES

### External Services Required:
1. **n8n Instance** (https://n8n.bebot.co)
   - Running n8n version 1.117.3+
   - Active webhook endpoint
   - Credentials configured

2. **Google Sheets**
   - Sheet ID: `1XYJ4S_shpoQ5o7Psth-h4p-XZI48Kypy6a21k2ayYJ8`
   - Tabs:
     - `Atividades_DezembroVermelho` (activities master list)
     - `Inscricoes_DezembroVermelho` (enrollments)
   - OAuth2 credentials in n8n

3. **Gmail Account**
   - OAuth2 credentials in n8n
   - Sends confirmation emails

4. **QR Code API**
   - Service: api.qrserver.com
   - Used for generating QR codes
   - No authentication required

5. **Web Server**
   - For serving frontend files
   - Local: `http://localhost:8001`
   - Production: TBD

### Browser Requirements:
- Modern browser with localStorage support
- JavaScript enabled
- CORS-compatible for cross-origin requests to n8n

---

## 📋 MINIMAL DEPLOYMENT CHECKLIST

To run this system, you need:

### N8N Setup:
✅ Import `Dezembro Vermelho - Inscrições v9.1.json` to n8n
✅ Connect Google Sheets OAuth2 credentials (4 nodes)
✅ Connect Gmail OAuth2 credentials (1 node)
✅ Activate the workflow
✅ Test webhook endpoint: `https://n8n.bebot.co/webhook/inscricao-dv-2025`

### Frontend Setup:
✅ Deploy these files to web server:
   - `index.html`
   - `form-template.html`
   - `confirmation-template.html`
   - `activities.json`
   - `favicon_io/` (favicon files)

✅ Configure CORS on n8n webhook to allow your domain

✅ Update URLs in `form-template.html` if needed:
   - Line ~200: `webhookURL: "https://n8n.bebot.co/webhook/inscricao-dv-2025"`

### Optional Enhancements:
⚠️ Import `n8n-live-activities-workflow.json` for dynamic activities
⚠️ Deploy scanner application for check-in functionality
⚠️ Set up monitoring/logging for enrollment workflow

---

## 🎯 RECOMMENDED FILE STRUCTURE

### Production Environment:
```
/production/
├── index.html                              ⭐ ESSENTIAL
├── form-template.html                      ⭐ ESSENTIAL
├── confirmation-template.html              ⭐ ESSENTIAL
├── activities.json                         ⭐ ESSENTIAL
├── favicon_io/                             ⚠️ OPTIONAL
│   ├── favicon.ico
│   └── ...
└── scanner_live/                           ⚠️ OPTIONAL
    └── (scanner app files)
```

### N8N Workflows:
```
n8n Instance (https://n8n.bebot.co)
├── Dezembro Vermelho - Inscrições v9.1    ⭐ ESSENTIAL
└── n8n-live-activities-workflow           ⚠️ OPTIONAL
```

### Archive/Backup:
```
/archive/
├── n8n broken/                            🗑️ ARCHIVE
├── n8n backups/                           🗑️ ARCHIVE
├── scanner_old/                           🗑️ ARCHIVE
├── v1.0/                                  🗑️ ARCHIVE
├── (old MD documentation files)           🗑️ ARCHIVE
├── forms.zip                              🗑️ ARCHIVE
└── Archive 4.zip                          🗑️ ARCHIVE
```

---

## 🔍 WORKFLOW DATA FLOW

```
User fills form → form-template.html
                        ↓
                  POST to n8n webhook
                        ↓
            Dezembro Vermelho - Inscrições v9.1
                        ↓
            ┌───────────┴───────────┐
            ↓                       ↓
    Duplicate Check          New Enrollment
    (Google Sheets)          ┌────────┴────────┐
            ↓                ↓                  ↓
    Return Error      Save to Sheet    Send Email (Gmail)
            ↓                ↓                  ↓
    Show error msg   Update capacity   Confirmation email
    on form page           ↓
                    Return ticket ID
                           ↓
                  Redirect to confirmation-template.html
                           ↓
                  Display ticket + QR code
```

---

## 📊 FILE SIZE SUMMARY

**Total Directory Size:** ~6.9 MB

**Essential Files Only:** ~150 KB
- Dezembro Vermelho - Inscrições v9.1.json: 16.5 KB
- index.html: 16.8 KB
- form-template.html: 25.5 KB
- confirmation-template.html: 14.3 KB
- activities.json: 8.8 KB

**Archive Material:** ~6.7 MB
- Mostly old PDFs, ZIPs, and backup versions

---

## ✅ CONCLUSION

**Essential files for system operation:** 5 files (~150 KB)

**Recommended for full functionality:** +8 files (~50 KB)

**Everything else:** Can be archived or deleted (~6.7 MB)

**Next Steps:**
1. Keep essential files in production directory
2. Move archive material to `/archive/` folder
3. Keep current README.md and SYSTEM-OVERVIEW.md for reference
4. Delete old troubleshooting documentation (*.md files listed above)
5. Ensure n8n v9.1 workflow is active and tested

---

**Legend:**
- ⭐ **ESSENTIAL** - Required for system to work
- ⚠️ **RECOMMENDED** - Helpful but optional
- 🗑️ **ARCHIVE** - Can be moved to backup/deleted
