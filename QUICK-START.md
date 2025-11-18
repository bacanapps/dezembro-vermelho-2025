# 🚀 Quick Start Guide - Dezembro Vermelho 2025

## Start in 3 Minutes ⏱️

### Option A: Dynamic Form (Recommended)

**Best for**: Most scenarios, easy updates, minimal files

```bash
# 1. No setup needed! Just test locally:
python -m http.server 8000

# 2. Open in browser:
# http://localhost:8000

# 3. Deploy to production:
# Upload these 3 files to your web server:
#   - index.html
#   - form-template.html
#   - activities.json

# Done! ✅
```

### Option B: Static Forms

**Best for**: Maximum compatibility, no URL parameters needed

```bash
# 1. Generate 30 static forms:
node generate-forms.js

# 2. Test locally:
python -m http.server 8000

# 3. Deploy to production:
# Upload these to your web server:
#   - index.html
#   - activities.json
#   - forms/ (entire folder with 30 HTML files)

# Done! ✅
```

---

## 🎯 What You Get

### Files Created

```
✅ activities.json          - All 30 activities data
✅ index.html              - Main page listing all activities
✅ form-template.html      - Dynamic registration form
✅ generate-forms.js       - Static forms generator
✅ README.md               - Full documentation
✅ QUICK-START.md          - This file
```

### Features

- ✅ 30 registration forms for 30 activities
- ✅ Beautiful, responsive design
- ✅ Activity filtering by type
- ✅ Automatic capacity checking
- ✅ CPF formatting (000.000.000-00)
- ✅ LGPD compliance checkbox
- ✅ Integration with n8n workflow
- ✅ Email confirmation with QR code
- ✅ Google Sheets storage

---

## 📝 How to Update Activities

### Update Existing Activity

Edit `activities.json`:

```json
{
  "id": 1,
  "nome_atividade": "NEW NAME HERE",  ← Change this
  "data": "01/12/2025",
  "horario": "15:00-16:00",
  "capacidade": 150  ← Or this
}
```

**Option A (Dynamic)**: Just upload updated `activities.json`
**Option B (Static)**: Run `node generate-forms.js` then upload all

### Add New Activity

Add to `activities.json`:

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

**Option A (Dynamic)**: Just upload updated `activities.json`
**Option B (Static)**: Run `node generate-forms.js` then upload all

---

## 🔧 Configuration

### Change Webhook URL

**Option A** - Edit `form-template.html` line ~186:
```javascript
webhookURL: "https://YOUR-DOMAIN/webhook/inscricao-dv-2025"
```

**Option B** - Edit `generate-forms.js` line ~21:
```javascript
webhookURL: 'https://YOUR-DOMAIN/webhook/inscricao-dv-2025'
```
Then run: `node generate-forms.js`

### Switch Between Dynamic/Static

Edit `index.html` line ~273:

```javascript
// For Dynamic Forms (Option A)
formType: "dynamic"

// For Static Forms (Option B)
formType: "static"
```

---

## 🌐 Deployment Options

### GitHub Pages (Free)

```bash
# 1. Create GitHub repo
# 2. Push files
git add .
git commit -m "Add registration system"
git push

# 3. Enable GitHub Pages in repo settings
# 4. Done! Your site is live at:
# https://yourusername.github.io/repo-name/
```

### Netlify (Free)

```bash
# Option 1: Drag & drop
# Go to netlify.com/drop
# Drag your entire folder
# Done!

# Option 2: CLI
npm install -g netlify-cli
netlify deploy --prod
```

### Your Own Server (FTP/SFTP)

```bash
# Upload via FTP client (FileZilla, etc.)
# Or via command line:
scp -r * user@yourserver.com:/var/www/html/
```

---

## ✅ Testing Checklist

Before going live, test:

- [ ] Open `index.html` - does it show all 30 activities?
- [ ] Click filter buttons - does filtering work?
- [ ] Click "Fazer Inscrição" - does form open?
- [ ] Does form show correct activity details?
- [ ] Fill and submit form - does it process?
- [ ] Check email - did confirmation arrive?
- [ ] Check Google Sheets - is registration saved?

---

## 🐛 Quick Fixes

### "Activity not found" error
- Check if `activities.json` is in the same folder as HTML files
- Check browser console (F12) for errors

### Forms don't submit
- Check webhook URL in configuration
- Test webhook with Postman first
- Check browser console (F12) for errors

### Changes don't appear
- **Option A**: Clear browser cache (Ctrl+Shift+R)
- **Option B**: Did you run `node generate-forms.js` after changes?

### CPF not formatting
- Make sure JavaScript is enabled
- Check browser console (F12) for errors

---

## 📞 Need Help?

1. Read the full [README.md](README.md) documentation
2. Check browser console (F12) for error messages
3. Verify all files are uploaded correctly
4. Test the n8n webhook endpoint directly

---

## 🎉 You're All Set!

Your registration system is ready to handle inscriptions for all 30 Dezembro Vermelho 2025 activities.

**Important URLs:**
- Main page: `https://yoursite.com/index.html`
- Example form: `https://yoursite.com/form-template.html?id=1`

**Next Steps:**
- Share the main page URL with participants
- Monitor registrations in Google Sheets
- Update `activities.json` as needed

---

**Questions?** Check the full [README.md](README.md) for detailed documentation.

**Boa sorte! 🎗**
