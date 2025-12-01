# Quick Start Guide
## SMTP Relay - Dezembro Vermelho 2025

---

## 🎯 Goal

Send emails from n8n (cloud) through government SMTP (10.101.40.1) via VPN.

---

## 📋 Before You Start

**You must have:**

1. VPN certificate files:
   - ca.crt
   - cert.crt
   - key.key
   - ta.key

2. VPN username & password

3. Access to Contabo server: 173.249.XXX.XXX

---

## ⚡ Installation (5 Steps)

### 1. Upload Package

```bash
scp -r contabo-deployment/ root@173.249.XXX.XXX:/root/
ssh root@173.249.XXX.XXX
```

### 2. Copy VPN Certificates

```bash
mkdir -p /etc/openvpn/government
# Copy your 4 certificate files to /etc/openvpn/government/
```

### 3. Run Installer

```bash
cd /root/contabo-deployment/scripts
chmod +x install.sh
sudo bash install.sh
```

**✏️ SAVE THE API KEY IT GENERATES!**

### 4. Start Services

```bash
# Start VPN
sudo systemctl start openvpn@government

# Check VPN assigned IP (send to IT for whitelisting!)
sudo cat /var/log/openvpn/vpn-assigned-ip.log

# Start relay
sudo systemctl start smtp-relay
```

### 5. Test

```bash
cd /opt/smtp-relay
node test-smtp.js your-email@example.com
```

If you receive the email → **SUCCESS!** ✅

---

## 🔄 Update n8n Workflow

Replace the Gmail node with HTTP Request:

**URL:** `https://smtp-relay.bebot.co/send-email`

**Headers:**
```
X-API-Key: [API key from installation]
Content-Type: application/json
```

**Body (JSON):**
```json
{
  "from": "Dezembro Vermelho 2025 <producao@aids.gov.br>",
  "to": "={{$node['Gerar Ticket'].json.email}}",
  "subject": "Confirmacao de Inscricao - Dezembro Vermelho 2025",
  "html": "[Your HTML content]"
}
```

---

## 🧪 Quick Tests

### Health Check
```bash
curl https://smtp-relay.bebot.co/health
```

### Send Test Email
```bash
curl -X POST https://smtp-relay.bebot.co/send-email \
  -H "X-API-Key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"to":"test@example.com","subject":"Test","html":"<h1>Test</h1>"}'
```

---

## 📊 Check Status

```bash
# VPN status
sudo systemctl status openvpn@government

# Relay status
sudo systemctl status smtp-relay

# View logs
sudo journalctl -u smtp-relay -f
```

---

## 🆘 Common Issues

### "SMTP Connection Failed"

```bash
# Make sure VPN is connected
sudo systemctl status openvpn@government

# Check VPN IP is whitelisted
sudo cat /var/log/openvpn/vpn-assigned-ip.log
# → Send this IP to IT
```

### "401 Unauthorized" from n8n

- Check API key in n8n matches the one from installation
- API key is in: `/opt/smtp-relay/.env`

### Can't connect to relay from n8n

```bash
# Check if relay is running
sudo systemctl status smtp-relay

# Check firewall
sudo ufw status

# Test locally first
curl http://localhost:3000/health
```

---

## 📞 Need Full Documentation?

See `README.md` for complete guide.

---

**Quick Commands:**

```bash
# Restart everything
sudo systemctl restart openvpn@government smtp-relay

# View all logs
sudo journalctl -u smtp-relay -u openvpn@government -f

# Check VPN IP (for IT)
sudo cat /var/log/openvpn/vpn-assigned-ip.log
```

---

**Support:** Check logs, verify VPN connection, confirm IP whitelist with IT
