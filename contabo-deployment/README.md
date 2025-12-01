# SMTP Relay Deployment Package
## Dezembro Vermelho 2025

Complete deployment package for sending emails from n8n through government internal SMTP server via VPN.

---

## 📋 Overview

### Architecture

```
n8n.bebot.co (Cloud)
    ↓ HTTPS POST
smtp-relay.bebot.co (Contabo: 173.249.XXX.XXX)
    ├── Nginx (reverse proxy, SSL)
    ├── Node.js SMTP Relay (port 3000)
    └── OpenVPN Client (connects to government network)
        ↓ VPN Tunnel
Government Network
    ↓ VPN assigns IP: 10.101.40.YYY (must be whitelisted)
    ↓ SMTP connection
Internal SMTP Server (10.101.40.1:25)
    ↓
Email sent from producao@aids.gov.br
```

### What This Package Contains

```
contabo-deployment/
├── vpn/                          # OpenVPN configuration
│   ├── government.conf           # OpenVPN config
│   ├── government-credentials.txt.template
│   └── government-up.sh          # Script to log VPN IP
│
├── smtp-relay/                   # Node.js SMTP relay application
│   ├── server.js                 # Main relay server
│   ├── package.json              # Dependencies
│   ├── test-smtp.js              # SMTP connection test
│   └── .env.template             # Environment variables
│
├── nginx/                        # Nginx reverse proxy
│   └── smtp-relay.bebot.co.conf  # Nginx config
│
├── systemd/                      # System services
│   └── smtp-relay.service        # Systemd service
│
├── scripts/                      # Installation & testing
│   ├── install.sh                # Main installation script
│   └── test-relay.sh             # API test script
│
├── n8n-workflow-update.json      # n8n node configuration
└── README.md                     # This file
```

---

## 🚀 Quick Start

### Prerequisites

Before starting, you need:

1. ✅ **VPN Credentials**
   - Username and password
   - Certificate files (ca.crt, cert.crt, key.key, ta.key)

2. ✅ **IT Whitelisting**
   - VPN-assigned IP must be whitelisted on SMTP server
   - Ask IT: "What IP will be assigned when this VPN connects?"

3. ✅ **SMTP Details**
   - Does 10.101.40.1:25 require authentication?
   - If yes, password for producao@aids.gov.br

4. ✅ **DNS Setup** (optional, for Nginx)
   - Point `smtp-relay.bebot.co` to your Contabo IP (173.249.XXX.XXX)

---

## 📦 Installation

### Step 1: Upload Package to Contabo

```bash
# On your local machine, copy package to Contabo
scp -r contabo-deployment/ root@173.249.XXX.XXX:/root/

# SSH into Contabo
ssh root@173.249.XXX.XXX
```

### Step 2: Copy VPN Certificates

```bash
# Create directory
mkdir -p /etc/openvpn/government

# Copy your certificate files to the server
scp ca.crt cert.crt key.key ta.key root@173.249.XXX.XXX:/etc/openvpn/government/

# Or if you're already on the server, copy them manually
# to /etc/openvpn/government/
```

### Step 3: Run Installation Script

```bash
cd /root/contabo-deployment/scripts
chmod +x install.sh
sudo bash install.sh
```

The script will:
- ✅ Install dependencies (OpenVPN, Node.js, Nginx)
- ✅ Create directories and users
- ✅ Set up SMTP relay application
- ✅ Configure OpenVPN
- ✅ Generate API key
- ✅ Install systemd services
- ✅ Configure Nginx (optional)
- ✅ Set up firewall (optional)

**Save the generated API key!** You'll need it for n8n.

---

## 🔧 Post-Installation

### 1. Start OpenVPN

```bash
# Start VPN connection
sudo systemctl start openvpn@government

# Check status
sudo systemctl status openvpn@government

# View logs
sudo journalctl -u openvpn@government -f
```

### 2. Check VPN-Assigned IP

```bash
# This is the IP that IT needs to whitelist!
sudo cat /var/log/openvpn/vpn-assigned-ip.log

# Or check current VPN interface
ip addr show tun0
```

**⚠️ IMPORTANT:** Send this IP to IT for whitelisting!

### 3. Test SMTP Connection

```bash
# Make sure VPN is connected first!
cd /opt/smtp-relay

# Test direct SMTP connection
node test-smtp.js your-email@example.com
```

If this succeeds, SMTP is working! ✅

### 4. Start SMTP Relay Service

```bash
# Start the relay
sudo systemctl start smtp-relay

# Check status
sudo systemctl status smtp-relay

# View logs
sudo journalctl -u smtp-relay -f
```

### 5. Test the Relay API

```bash
cd /root/contabo-deployment/scripts

# Set your API key (from installation)
export API_KEY="your-generated-api-key"

# Test the relay
bash test-relay.sh your-email@example.com
```

If all tests pass, the relay is working! ✅

### 6. Configure SSL (Optional but Recommended)

```bash
# Make sure DNS is pointing smtp-relay.bebot.co to your server IP
# Then run certbot
sudo certbot --nginx -d smtp-relay.bebot.co

# Follow the prompts to get SSL certificate
```

---

## 🔄 Update n8n Workflow

### Option A: Using n8n UI

1. Open workflow in n8n.bebot.co
2. Find the "Enviar Email" Gmail node
3. Delete it
4. Add new "HTTP Request" node
5. Configure:
   - **Method:** POST
   - **URL:** `https://smtp-relay.bebot.co/send-email`
   - **Headers:**
     - `X-API-Key`: [Your generated API key]
     - `Content-Type`: application/json
   - **Body (JSON):**
     ```json
     {
       "from": "Dezembro Vermelho 2025 <producao@aids.gov.br>",
       "to": "={{$node['Gerar Ticket'].json.email}}",
       "subject": "Confirmacao de Inscricao - Dezembro Vermelho 2025",
       "html": "[Copy HTML from old node]"
     }
     ```
6. Save and test!

### Option B: Direct URL (if no Nginx/SSL)

Use: `http://173.249.XXX.XXX:3000/send-email`

---

## 🧪 Testing

### Health Check

```bash
curl https://smtp-relay.bebot.co/health
```

Expected response:
```json
{
  "status": "ok",
  "service": "SMTP Relay - Dezembro Vermelho 2025",
  "smtp": {
    "host": "10.101.40.1",
    "port": 25
  }
}
```

### SMTP Verification

```bash
curl -H "X-API-Key: YOUR_API_KEY" \
  https://smtp-relay.bebot.co/verify-smtp
```

Expected response:
```json
{
  "success": true,
  "message": "SMTP server is ready to send emails"
}
```

### Send Test Email

```bash
curl -X POST https://smtp-relay.bebot.co/send-email \
  -H "X-API-Key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "your-email@example.com",
    "subject": "Test Email",
    "html": "<h1>Test</h1><p>If you receive this, it works!</p>"
  }'
```

---

## 📊 Monitoring & Logs

### SMTP Relay Logs

```bash
# Real-time logs
sudo journalctl -u smtp-relay -f

# Last 100 lines
sudo journalctl -u smtp-relay -n 100

# Application logs
sudo tail -f /var/log/smtp-relay/combined.log
sudo tail -f /var/log/smtp-relay/error.log
```

### OpenVPN Logs

```bash
# Real-time logs
sudo journalctl -u openvpn@government -f

# VPN connection status
sudo systemctl status openvpn@government

# Assigned IP log
sudo cat /var/log/openvpn/vpn-assigned-ip.log
```

### Nginx Logs

```bash
# Access log
sudo tail -f /var/log/nginx/smtp-relay.access.log

# Error log
sudo tail -f /var/log/nginx/smtp-relay.error.log
```

---

## 🔧 Configuration

### Update SMTP Settings

Edit `/opt/smtp-relay/.env`:

```bash
sudo nano /opt/smtp-relay/.env
```

Available settings:
```env
PORT=3000
SMTP_HOST=10.101.40.1
SMTP_PORT=25
SMTP_SECURE=false
SMTP_REQUIRE_AUTH=false
SMTP_USER=producao@aids.gov.br
SMTP_PASS=
API_KEY=your-api-key
```

After changes:
```bash
sudo systemctl restart smtp-relay
```

### Update VPN Credentials

Edit credentials:
```bash
sudo nano /etc/openvpn/government-credentials.txt
```

Format:
```
USERNAME
PASSWORD
```

Restart VPN:
```bash
sudo systemctl restart openvpn@government
```

---

## 🛠️ Troubleshooting

### VPN Not Connecting

```bash
# Check VPN status
sudo systemctl status openvpn@government

# View detailed logs
sudo journalctl -u openvpn@government -n 50

# Test DNS resolution
nslookup vpndcci.aids.gov.br

# Try manual connection
sudo openvpn --config /etc/openvpn/government.conf
```

### SMTP Connection Failed

```bash
# Make sure VPN is connected first!
sudo systemctl status openvpn@government

# Check if you can reach SMTP server
ping 10.101.40.1
telnet 10.101.40.1 25

# Check VPN-assigned IP
ip addr show tun0

# Verify this IP is whitelisted with IT
```

### Relay Service Not Starting

```bash
# Check logs
sudo journalctl -u smtp-relay -n 50

# Check port 3000 is available
sudo netstat -tulpn | grep 3000

# Test manually
cd /opt/smtp-relay
node server.js
```

### n8n Workflow Errors

Common issues:

1. **401 Unauthorized** → Wrong API key
2. **500 Error** → Check relay logs
3. **Connection refused** → VPN not connected or firewall blocking
4. **Timeout** → SMTP server not responding (check VPN IP whitelist)

---

## 🔒 Security

### API Key

- Generated automatically during installation
- Stored in `/opt/smtp-relay/.env`
- Required for all API requests
- Change it: `openssl rand -hex 32`

### Firewall

```bash
# View rules
sudo ufw status

# Allow only n8n.bebot.co (if you know its IP)
sudo ufw allow from N8N_IP to any port 3000
```

### SSL/HTTPS

Always use HTTPS in production:
```bash
sudo certbot --nginx -d smtp-relay.bebot.co
```

Auto-renewal:
```bash
sudo certbot renew --dry-run
```

---

## 🔄 Maintenance

### Update Relay Application

```bash
cd /opt/smtp-relay
sudo -u smtp-relay npm update
sudo systemctl restart smtp-relay
```

### Renew SSL Certificate

```bash
sudo certbot renew
```

### Backup Configuration

```bash
# Backup script
tar -czf smtp-relay-backup-$(date +%Y%m%d).tar.gz \
  /opt/smtp-relay/.env \
  /etc/openvpn/government.conf \
  /etc/openvpn/government-credentials.txt \
  /etc/nginx/sites-available/smtp-relay.bebot.co.conf
```

---

## 📞 Support

### Check System Status

```bash
# All services
sudo systemctl status openvpn@government smtp-relay nginx

# VPN IP
sudo cat /var/log/openvpn/vpn-assigned-ip.log

# Test relay
curl https://smtp-relay.bebot.co/health
```

### Get Help

For issues:
1. Check logs (see Monitoring section)
2. Verify VPN is connected
3. Confirm VPN IP is whitelisted with IT
4. Test SMTP connection directly

---

## ✅ Checklist

- [ ] VPN certificates copied to `/etc/openvpn/government/`
- [ ] VPN credentials configured
- [ ] OpenVPN service started
- [ ] VPN-assigned IP identified
- [ ] VPN IP whitelisted by IT
- [ ] SMTP connection tested successfully
- [ ] SMTP relay service started
- [ ] API key saved securely
- [ ] Nginx configured (if using SSL)
- [ ] SSL certificate obtained (if using HTTPS)
- [ ] Test email sent successfully
- [ ] n8n workflow updated
- [ ] Production test completed

---

## 📝 Notes

### Important IPs

- **Contabo Public IP:** 173.249.XXX.XXX
- **VPN Assigned IP:** [Check /var/log/openvpn/vpn-assigned-ip.log]
- **Government SMTP:** 10.101.40.1:25

### Service URLs

- **Health Check:** https://smtp-relay.bebot.co/health
- **n8n Endpoint:** https://smtp-relay.bebot.co/send-email

### Credentials to Keep Safe

- VPN username/password
- SMTP password (if required)
- API key for relay
- SSL certificates

---

**Version:** 1.0
**Last Updated:** 2025-11-19
**Project:** Dezembro Vermelho 2025
