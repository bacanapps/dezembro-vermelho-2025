# SMTP Relay Deployment Package
## Summary Document

**Project:** Dezembro Vermelho 2025
**Version:** 1.0
**Created:** 2025-11-19
**Purpose:** Enable n8n (cloud) to send emails via government internal SMTP through VPN

---

## 📦 Package Contents

```
contabo-deployment/
├── README.md                        # Complete documentation
├── QUICK-START.md                   # 5-minute setup guide
├── CHECKLIST.md                     # Deployment checklist
├── PACKAGE-SUMMARY.md              # This file
│
├── vpn/                            # OpenVPN configuration
│   ├── government.conf             # OpenVPN config for vpndcci.aids.gov.br
│   ├── government-credentials.txt.template  # Username/password template
│   └── government-up.sh            # Script to log VPN-assigned IP
│
├── smtp-relay/                     # Node.js SMTP relay application
│   ├── server.js                   # Main relay server (Express + Nodemailer)
│   ├── package.json                # npm dependencies
│   ├── test-smtp.js                # Direct SMTP connection test
│   └── .env.template               # Environment variables template
│
├── nginx/                          # Nginx reverse proxy
│   └── smtp-relay.bebot.co.conf    # Nginx config with SSL support
│
├── systemd/                        # System services
│   └── smtp-relay.service          # Systemd service for relay
│
├── scripts/                        # Installation & testing
│   ├── install.sh                  # Automated installation script
│   └── test-relay.sh               # API testing script
│
└── n8n-workflow-update.json        # n8n HTTP Request node config
```

**Total Files:** 13 configuration/code files + 4 documentation files

---

## 🎯 What This Package Does

### Problem Solved

n8n.bebot.co (external cloud) needs to send emails from `producao@aids.gov.br`, but:
- Government SMTP (10.101.40.1:25) only accessible via VPN
- SMTP requires whitelisted IP
- No HTTP/REST email API available
- Standard n8n SMTP nodes don't work

### Solution Implemented

```
n8n.bebot.co (Cloud)
    ↓ HTTPS POST request
Contabo Server (173.249.XXX.XXX)
    ├── Nginx: SSL termination & reverse proxy
    ├── Node.js SMTP Relay: HTTP → SMTP translation
    └── OpenVPN: Connects to government network
        ↓ VPN Tunnel
        ↓ VPN assigns static IP: 10.101.40.YYY
        ↓ This IP is whitelisted by IT
Government Network
    ↓ SMTP connection
Internal SMTP Server (10.101.40.1:25)
    ↓
Email sent from producao@aids.gov.br ✅
```

---

## 🚀 Quick Setup (5 Steps)

1. **Upload to Contabo**
   ```bash
   scp -r contabo-deployment/ root@173.249.XXX.XXX:/root/
   ```

2. **Copy VPN Certificates**
   ```bash
   # Copy ca.crt, cert.crt, key.key, ta.key to /etc/openvpn/government/
   ```

3. **Run Installer**
   ```bash
   cd /root/contabo-deployment/scripts
   sudo bash install.sh
   ```

4. **Start Services & Get VPN IP**
   ```bash
   sudo systemctl start openvpn@government smtp-relay
   sudo cat /var/log/openvpn/vpn-assigned-ip.log
   # → Send this IP to IT for whitelisting!
   ```

5. **Test & Update n8n**
   ```bash
   node test-smtp.js your-email@example.com
   # Then update n8n workflow with HTTP Request node
   ```

---

## 📋 Prerequisites

### From IT Department

- [x] VPN certificate files (4 files)
- [x] VPN username & password
- [ ] VPN IP whitelisting confirmation
- [ ] SMTP authentication details (if required)

### Infrastructure

- [x] Contabo server with SSH access (173.249.XXX.XXX)
- [x] n8n running at n8n.bebot.co
- [x] Docker + Nginx already on Contabo
- [ ] DNS for smtp-relay.bebot.co (optional, for SSL)

---

## 🔧 Key Components

### 1. OpenVPN Client

**File:** `vpn/government.conf`

- Connects to: `vpndcci.aids.gov.br:1194`
- Protocol: UDP
- Authentication: Certificate + username/password
- Creates: `tun0` interface with VPN IP

**Key Feature:** Logs assigned IP to `/var/log/openvpn/vpn-assigned-ip.log`

### 2. Node.js SMTP Relay

**File:** `smtp-relay/server.js`

- Listens on: Port 3000
- Endpoints:
  - `GET /health` - Health check
  - `GET /verify-smtp` - Test SMTP connection
  - `POST /send-email` - Send email
- Security: API key authentication
- Features: Rate limiting, logging, error handling

**Dependencies:**
- express - HTTP server
- nodemailer - SMTP client
- winston - Logging
- helmet - Security headers

### 3. Nginx Reverse Proxy

**File:** `nginx/smtp-relay.bebot.co.conf`

- Domain: smtp-relay.bebot.co
- SSL: Let's Encrypt (via certbot)
- Proxies: Port 443 → localhost:3000
- Features: HTTPS redirect, security headers

### 4. Systemd Services

**Files:**
- `systemd/smtp-relay.service`
- Built-in: `openvpn@government.service`

**Features:**
- Auto-start on boot
- Auto-restart on failure
- Dependency management (relay waits for VPN)

---

## 🔒 Security Features

### API Authentication

- 64-character random API key
- Required in `X-API-Key` header
- Generated during installation

### Network Security

- Firewall configuration (UFW)
- Rate limiting (100 requests/15min)
- HTTPS/SSL encryption
- Security headers (helmet.js)

### Access Control

- Dedicated `smtp-relay` user (no shell)
- Restricted file permissions
- Isolated directories
- Log rotation

---

## 📊 Monitoring & Logging

### Service Logs

```bash
# SMTP Relay
sudo journalctl -u smtp-relay -f
/var/log/smtp-relay/combined.log
/var/log/smtp-relay/error.log

# OpenVPN
sudo journalctl -u openvpn@government -f
/var/log/openvpn/government.log
/var/log/openvpn/vpn-assigned-ip.log

# Nginx
/var/log/nginx/smtp-relay.access.log
/var/log/nginx/smtp-relay.error.log
```

### Health Checks

```bash
# Service status
systemctl status openvpn@government smtp-relay nginx

# API health
curl https://smtp-relay.bebot.co/health

# SMTP verification
curl -H "X-API-Key: KEY" https://smtp-relay.bebot.co/verify-smtp
```

---

## 🧪 Testing Strategy

### 1. VPN Connection Test

```bash
sudo systemctl start openvpn@government
sudo systemctl status openvpn@government
ip addr show tun0
```

### 2. Direct SMTP Test

```bash
cd /opt/smtp-relay
node test-smtp.js your-email@example.com
```

### 3. Relay API Test

```bash
cd /root/contabo-deployment/scripts
bash test-relay.sh your-email@example.com
```

### 4. n8n Integration Test

- Clone production workflow
- Replace Gmail node with HTTP Request
- Test with real enrollment data
- Verify email delivery

---

## 🔄 n8n Workflow Integration

### Old Node (Gmail)

```json
{
  "name": "Enviar Email",
  "type": "n8n-nodes-base.gmail",
  "parameters": {
    "sendTo": "={{$node['Gerar Ticket'].json.email}}",
    "subject": "Confirmacao de Inscricao...",
    "message": "=<!DOCTYPE html>..."
  }
}
```

### New Node (HTTP Request)

```json
{
  "name": "Enviar Email",
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "method": "POST",
    "url": "https://smtp-relay.bebot.co/send-email",
    "headers": {
      "X-API-Key": "YOUR_API_KEY",
      "Content-Type": "application/json"
    },
    "body": {
      "from": "Dezembro Vermelho 2025 <producao@aids.gov.br>",
      "to": "={{$node['Gerar Ticket'].json.email}}",
      "subject": "Confirmacao de Inscricao - Dezembro Vermelho 2025",
      "html": "=<!DOCTYPE html>..."
    }
  }
}
```

**See:** `n8n-workflow-update.json` for complete configuration

---

## 🛠️ Troubleshooting

### VPN Not Connecting

**Symptoms:** OpenVPN service fails to start

**Checks:**
1. Certificate files in `/etc/openvpn/government/`
2. Credentials in `/etc/openvpn/government-credentials.txt`
3. Can reach vpndcci.aids.gov.br: `nslookup vpndcci.aids.gov.br`
4. Logs: `sudo journalctl -u openvpn@government -n 50`

### SMTP Connection Failed

**Symptoms:** test-smtp.js fails

**Checks:**
1. VPN connected: `sudo systemctl status openvpn@government`
2. VPN IP assigned: `ip addr show tun0`
3. Can reach SMTP: `ping 10.101.40.1`, `telnet 10.101.40.1 25`
4. VPN IP whitelisted by IT

### Relay API Errors

**Symptoms:** n8n gets 500 errors

**Checks:**
1. Relay running: `sudo systemctl status smtp-relay`
2. Logs: `sudo journalctl -u smtp-relay -f`
3. VPN still connected
4. Test locally: `curl http://localhost:3000/health`

### Email Not Delivered

**Symptoms:** API succeeds but email not received

**Checks:**
1. Check spam folder
2. Verify "from" address: producao@aids.gov.br
3. SMTP server logs (ask IT)
4. Test with known good email address

---

## 📞 Support

### Self-Help

1. Check service status: `systemctl status openvpn@government smtp-relay`
2. Check logs: `sudo journalctl -u smtp-relay -f`
3. Verify VPN IP: `sudo cat /var/log/openvpn/vpn-assigned-ip.log`
4. Run tests: `bash test-relay.sh your-email@example.com`

### Contact IT If:

- VPN IP needs to be whitelisted
- SMTP server is not responding
- Need to change VPN credentials
- SMTP authentication issues

### Emergency Rollback

```bash
# In n8n: Restore Gmail node from backup
# On server:
sudo systemctl stop smtp-relay
sudo systemctl stop openvpn@government
```

---

## ✅ Success Criteria

- [ ] VPN connects and assigns static IP
- [ ] VPN IP whitelisted by IT
- [ ] Direct SMTP test succeeds
- [ ] Relay API tests pass
- [ ] n8n can send emails via relay
- [ ] Emails arrive from producao@aids.gov.br
- [ ] Email content/formatting correct
- [ ] QR codes render properly
- [ ] Services auto-start on reboot

---

## 📝 Important Information

### Network Details

| Component | Value |
|-----------|-------|
| Contabo Public IP | 173.249.XXX.XXX |
| VPN Server | vpndcci.aids.gov.br:1194 |
| VPN Assigned IP | Check /var/log/openvpn/vpn-assigned-ip.log |
| Government SMTP | 10.101.40.1:25 |
| Relay Port | 3000 |

### Service URLs

| Service | URL |
|---------|-----|
| Health Check | https://smtp-relay.bebot.co/health |
| SMTP Verify | https://smtp-relay.bebot.co/verify-smtp |
| Send Email | https://smtp-relay.bebot.co/send-email |
| n8n Instance | https://n8n.bebot.co |

### Files to Backup

- `/opt/smtp-relay/.env` (contains API key)
- `/etc/openvpn/government-credentials.txt` (VPN credentials)
- `/etc/openvpn/government/` (certificates)
- `/etc/nginx/sites-available/smtp-relay.bebot.co.conf`

---

## 🎓 Training Notes

### For System Administrators

1. Monitoring: Check logs daily for errors
2. VPN: Ensure connection stays active
3. SSL: Certificates renew automatically (Let's Encrypt)
4. Updates: `npm update` in /opt/smtp-relay periodically

### For Developers

1. n8n workflow uses HTTP Request node
2. API key required in X-API-Key header
3. JSON body: from, to, subject, html
4. Returns: success, messageId, or error

### For Support Team

1. If emails stop: Check VPN connection first
2. Get VPN IP: `sudo cat /var/log/openvpn/vpn-assigned-ip.log`
3. Test relay: `curl https://smtp-relay.bebot.co/health`
4. Escalate: If SMTP fails, contact IT (VPN/whitelist issue)

---

## 📅 Maintenance Schedule

### Daily
- Monitor service status
- Check for errors in logs

### Weekly
- Review email sending logs
- Verify VPN connection stable
- Check disk space

### Monthly
- Review security logs
- Update Node.js packages
- Test backup/restore procedure

### Quarterly
- Review and rotate API keys
- Audit access logs
- Update documentation

---

## 🚨 Emergency Contacts

**IT Department (VPN/SMTP):**
- Name: _________________
- Email: _________________
- Phone: _________________

**Server Administrator:**
- Name: _________________
- Email: _________________
- Phone: _________________

**n8n Administrator:**
- Name: _________________
- Email: _________________
- Phone: _________________

---

## 📚 Additional Resources

### Documentation Files

- `README.md` - Complete documentation (detailed)
- `QUICK-START.md` - 5-minute setup guide
- `CHECKLIST.md` - Deployment checklist
- `PACKAGE-SUMMARY.md` - This file (overview)

### External Resources

- OpenVPN Documentation: https://openvpn.net/community-resources/
- Nodemailer Documentation: https://nodemailer.com/
- n8n Documentation: https://docs.n8n.io/
- Let's Encrypt: https://letsencrypt.org/

---

**Package Version:** 1.0
**Last Updated:** 2025-11-19
**Maintained By:** Colin Pantin
**Project:** Dezembro Vermelho 2025 - Sistema de Inscrições
