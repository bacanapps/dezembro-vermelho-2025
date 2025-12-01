# Deployment Checklist
## SMTP Relay - Dezembro Vermelho 2025

Use this checklist to ensure nothing is missed during deployment.

---

## 📋 Pre-Deployment

### Information from IT Department

- [ ] VPN certificate files received (ca.crt, cert.crt, key.key, ta.key)
- [ ] VPN username: _________________
- [ ] VPN password: _________________
- [ ] VPN server confirmed: vpndcci.aids.gov.br:1194
- [ ] IT confirmed VPN will assign **static IP** (critical!)
- [ ] Expected VPN IP (if known): _________________
- [ ] SMTP server confirmed: 10.101.40.1:25
- [ ] SMTP requires authentication: Yes / No
- [ ] If yes, SMTP password for producao@aids.gov.br: _________________

### DNS Configuration (if using Nginx with SSL)

- [ ] Created A record: smtp-relay.bebot.co → 173.249.XXX.XXX
- [ ] DNS propagated (check: `nslookup smtp-relay.bebot.co`)

### Contabo Server Access

- [ ] SSH access to Contabo server confirmed
- [ ] Server IP: 173.249.XXX.XXX
- [ ] Root or sudo access confirmed
- [ ] Server has internet connectivity

---

## 🚀 Deployment Steps

### 1. Upload Package

- [ ] Deployment package uploaded to `/root/contabo-deployment/`
- [ ] All files present and readable
- [ ] Scripts have execute permission

### 2. VPN Certificates

- [ ] Directory created: `/etc/openvpn/government/`
- [ ] ca.crt copied
- [ ] cert.crt copied
- [ ] key.key copied
- [ ] ta.key copied
- [ ] All files have correct permissions (600)

### 3. Run Installation

- [ ] Installation script executed: `sudo bash install.sh`
- [ ] All dependencies installed successfully
- [ ] No errors during installation
- [ ] **API key saved:** _________________________________
- [ ] SMTP relay user created
- [ ] Directories created:
  - [ ] /opt/smtp-relay/
  - [ ] /var/log/smtp-relay/
  - [ ] /var/log/openvpn/

### 4. VPN Configuration

- [ ] OpenVPN config file created: `/etc/openvpn/government.conf`
- [ ] VPN credentials file created: `/etc/openvpn/government-credentials.txt`
- [ ] Credentials file permissions: 600
- [ ] OpenVPN service enabled: `systemctl is-enabled openvpn@government`

### 5. SMTP Relay Configuration

- [ ] Node.js dependencies installed
- [ ] Environment file configured: `/opt/smtp-relay/.env`
- [ ] API key set in .env
- [ ] SMTP settings correct (host, port, auth)
- [ ] SMTP relay service enabled: `systemctl is-enabled smtp-relay`

### 6. Nginx Configuration (if applicable)

- [ ] Nginx config copied to sites-available
- [ ] Symlink created in sites-enabled
- [ ] Nginx config tested: `nginx -t`
- [ ] Nginx reloaded successfully

### 7. Firewall Configuration

- [ ] UFW installed
- [ ] Rules added:
  - [ ] Port 22 (SSH)
  - [ ] Port 80 (HTTP)
  - [ ] Port 443 (HTTPS)
  - [ ] Port 3000 (optional, if not using Nginx)
- [ ] UFW enabled (if desired)

---

## ✅ Post-Deployment Testing

### VPN Connection

- [ ] VPN service started: `sudo systemctl start openvpn@government`
- [ ] VPN service active: `sudo systemctl status openvpn@government`
- [ ] No errors in VPN logs: `sudo journalctl -u openvpn@government -n 50`
- [ ] VPN interface created: `ip addr show tun0`
- [ ] VPN assigned IP identified: _________________
- [ ] VPN assigned IP logged: `sudo cat /var/log/openvpn/vpn-assigned-ip.log`

### IT Whitelisting

- [ ] VPN assigned IP sent to IT department
- [ ] IT confirmed IP has been whitelisted on SMTP server
- [ ] Whitelisting confirmed date: _________________

### SMTP Connection Test

- [ ] Direct SMTP test executed: `cd /opt/smtp-relay && node test-smtp.js`
- [ ] SMTP connection successful
- [ ] Test email received
- [ ] Test email from address correct: producao@aids.gov.br

### SMTP Relay Service

- [ ] Relay service started: `sudo systemctl start smtp-relay`
- [ ] Relay service active: `sudo systemctl status smtp-relay`
- [ ] No errors in relay logs: `sudo journalctl -u smtp-relay -n 50`
- [ ] Relay listening on port 3000: `netstat -tulpn | grep 3000`

### API Testing

- [ ] Health check successful: `curl http://localhost:3000/health`
- [ ] SMTP verify endpoint works: `curl -H "X-API-Key: KEY" http://localhost:3000/verify-smtp`
- [ ] Send email endpoint works: Test with test-relay.sh
- [ ] Test email received

### SSL Configuration (if using Nginx)

- [ ] DNS pointing to server: `nslookup smtp-relay.bebot.co`
- [ ] Certbot executed: `sudo certbot --nginx -d smtp-relay.bebot.co`
- [ ] SSL certificate obtained
- [ ] HTTPS working: `curl https://smtp-relay.bebot.co/health`
- [ ] HTTP redirects to HTTPS
- [ ] SSL auto-renewal configured

### External Access

- [ ] Relay accessible from external IP
- [ ] Health check works: `curl https://smtp-relay.bebot.co/health`
- [ ] API authentication working (401 without API key)
- [ ] Can send email via API from external source

---

## 🔄 n8n Workflow Update

### Preparation

- [ ] n8n workflow backed up
- [ ] Current workflow working before changes
- [ ] Test workflow created (clone of production)

### Test Workflow

- [ ] Test workflow cloned from production
- [ ] Gmail node removed from test workflow
- [ ] HTTP Request node added
- [ ] Node configured:
  - [ ] URL: https://smtp-relay.bebot.co/send-email
  - [ ] Method: POST
  - [ ] Headers: X-API-Key
  - [ ] Headers: Content-Type: application/json
  - [ ] Body: from, to, subject, html
- [ ] Test workflow executed
- [ ] Test email received
- [ ] Email content correct (HTML rendering, QR code, etc.)
- [ ] Email from address correct

### Production Workflow

- [ ] Test successful, ready for production
- [ ] Production workflow updated
- [ ] Production test enrollment performed
- [ ] Production email received
- [ ] All email content correct
- [ ] QR code working
- [ ] Activity details correct

---

## 📊 Monitoring Setup

### Services Auto-Start

- [ ] OpenVPN auto-starts on boot
- [ ] SMTP relay auto-starts on boot
- [ ] Nginx auto-starts on boot
- [ ] All services restart after reboot test

### Logging

- [ ] SMTP relay logs writing: `/var/log/smtp-relay/`
- [ ] OpenVPN logs writing: `/var/log/openvpn/`
- [ ] Nginx logs writing: `/var/log/nginx/`
- [ ] Log rotation configured

### Monitoring Commands Tested

- [ ] `sudo systemctl status openvpn@government smtp-relay nginx`
- [ ] `sudo journalctl -u smtp-relay -f`
- [ ] `sudo journalctl -u openvpn@government -f`
- [ ] `curl https://smtp-relay.bebot.co/health`

---

## 🔒 Security

### Credentials Secured

- [ ] API key saved in secure location
- [ ] VPN credentials secure (permissions 600)
- [ ] SMTP password (if any) not in version control
- [ ] No credentials in logs

### Access Control

- [ ] Only necessary ports open
- [ ] SSH key-based authentication (recommended)
- [ ] Root login disabled (recommended)
- [ ] API key strong (32+ random characters)

### SSL/TLS

- [ ] HTTPS enforced (if using Nginx)
- [ ] SSL certificate valid
- [ ] Certificate auto-renewal working

---

## 📝 Documentation

### Records Updated

- [ ] VPN assigned IP documented
- [ ] API key stored securely
- [ ] Service URLs documented
- [ ] IT contact information saved
- [ ] Deployment date recorded: _________________

### Handoff Documentation

- [ ] README.md reviewed
- [ ] QUICK-START.md reviewed
- [ ] Troubleshooting section understood
- [ ] Monitoring commands documented
- [ ] Team trained on monitoring/maintenance

---

## 🎉 Final Verification

### End-to-End Test

- [ ] Real user enrollment tested
- [ ] Email received by participant
- [ ] Email content correct
- [ ] QR code scannable
- [ ] Ticket ID correct
- [ ] Activity details accurate

### Performance

- [ ] Email delivery time acceptable (< 30 seconds)
- [ ] No errors in any logs
- [ ] System resources OK (CPU, memory, disk)

### Rollback Plan

- [ ] Original Gmail workflow backed up
- [ ] Can revert to Gmail if needed
- [ ] Rollback procedure documented

---

## ✅ Sign-Off

- [ ] All checklist items completed
- [ ] System operating normally
- [ ] Monitoring in place
- [ ] Team aware of new system
- [ ] Ready for production use

**Deployment completed by:** _________________

**Date:** _________________

**Sign-off:** _________________

---

## 📞 Support Contacts

**IT Department:**
- Contact: _________________
- Email: _________________
- Phone: _________________

**Technical Support:**
- VPN Issues: _________________
- SMTP Issues: _________________
- Server Issues: _________________

**Emergency Rollback:**
- Revert n8n workflow to Gmail node
- Disable SMTP relay: `sudo systemctl stop smtp-relay`
- Contact: _________________

---

**Notes:**

_Use this space for deployment-specific notes, issues encountered, or special configurations:_

_____________________________________________________________________________

_____________________________________________________________________________

_____________________________________________________________________________

_____________________________________________________________________________
