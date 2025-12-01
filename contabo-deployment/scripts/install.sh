#!/bin/bash
#
# Installation Script for SMTP Relay + VPN
# Dezembro Vermelho 2025
#
# This script installs and configures:
# 1. OpenVPN client
# 2. Node.js SMTP Relay
# 3. Nginx reverse proxy
# 4. Systemd services
#
# Usage: sudo bash install.sh
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}SMTP Relay Installation${NC}"
echo -e "${GREEN}Dezembro Vermelho 2025${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: This script must be run as root${NC}"
  echo "Usage: sudo bash install.sh"
  exit 1
fi

# Check if running on Contabo server
echo -e "${YELLOW}Step 1: Checking system...${NC}"
echo "Hostname: $(hostname)"
echo "IP Address: $(hostname -I | awk '{print $1}')"
echo ""

read -p "Is this the correct Contabo server? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${RED}Installation cancelled${NC}"
  exit 1
fi

# Update system
echo -e "${YELLOW}Step 2: Updating system packages...${NC}"
apt update
apt upgrade -y

# Install dependencies
echo -e "${YELLOW}Step 3: Installing dependencies...${NC}"
apt install -y \
  openvpn \
  nodejs \
  npm \
  nginx \
  certbot \
  python3-certbot-nginx \
  ufw \
  curl \
  wget \
  net-tools

echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Create directories
echo -e "${YELLOW}Step 4: Creating directories...${NC}"
mkdir -p /opt/smtp-relay
mkdir -p /etc/openvpn/government
mkdir -p /var/log/openvpn
mkdir -p /var/log/smtp-relay
mkdir -p /var/www/certbot

echo -e "${GREEN}✓ Directories created${NC}"
echo ""

# Create smtp-relay user
echo -e "${YELLOW}Step 5: Creating smtp-relay user...${NC}"
if ! id -u smtp-relay >/dev/null 2>&1; then
  useradd -r -s /bin/false smtp-relay
  echo -e "${GREEN}✓ User created${NC}"
else
  echo -e "${YELLOW}User smtp-relay already exists${NC}"
fi
echo ""

# Copy SMTP relay files
echo -e "${YELLOW}Step 6: Copying SMTP relay files...${NC}"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

cp "$SCRIPT_DIR/smtp-relay/package.json" /opt/smtp-relay/
cp "$SCRIPT_DIR/smtp-relay/server.js" /opt/smtp-relay/
cp "$SCRIPT_DIR/smtp-relay/.env.template" /opt/smtp-relay/.env

echo -e "${GREEN}✓ Files copied${NC}"
echo ""

# Install Node.js dependencies
echo -e "${YELLOW}Step 7: Installing Node.js dependencies...${NC}"
cd /opt/smtp-relay
npm install --production

echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Set permissions
echo -e "${YELLOW}Step 8: Setting permissions...${NC}"
chown -R smtp-relay:smtp-relay /opt/smtp-relay
chown -R smtp-relay:smtp-relay /var/log/smtp-relay
chmod 644 /opt/smtp-relay/.env

echo -e "${GREEN}✓ Permissions set${NC}"
echo ""

# Configure environment variables
echo -e "${YELLOW}Step 9: Configuring environment variables...${NC}"
echo ""
echo -e "${YELLOW}Please enter the following information:${NC}"

# Generate API key
API_KEY=$(openssl rand -hex 32)
echo -e "${GREEN}Generated API Key: ${API_KEY}${NC}"
echo -e "${YELLOW}Save this key! You'll need it for n8n configuration.${NC}"
echo ""

# Ask for SMTP password
read -p "Does SMTP require authentication? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  read -sp "Enter SMTP password for producao@aids.gov.br: " SMTP_PASS
  echo
  sed -i "s/SMTP_REQUIRE_AUTH=false/SMTP_REQUIRE_AUTH=true/" /opt/smtp-relay/.env
  sed -i "s/SMTP_PASS=/SMTP_PASS=$SMTP_PASS/" /opt/smtp-relay/.env
fi

# Update API key in .env
sed -i "s/API_KEY=CHANGE_THIS_API_KEY/API_KEY=$API_KEY/" /opt/smtp-relay/.env

echo -e "${GREEN}✓ Environment configured${NC}"
echo ""

# Install systemd service
echo -e "${YELLOW}Step 10: Installing systemd service...${NC}"
cp "$SCRIPT_DIR/systemd/smtp-relay.service" /etc/systemd/system/

systemctl daemon-reload
systemctl enable smtp-relay.service

echo -e "${GREEN}✓ Systemd service installed${NC}"
echo ""

# OpenVPN setup
echo -e "${YELLOW}Step 11: Setting up OpenVPN...${NC}"
echo ""
echo "Please copy the VPN certificate files to /etc/openvpn/government/"
echo "Required files:"
echo "  - ca.crt"
echo "  - cert.crt"
echo "  - key.key"
echo "  - ta.key"
echo ""

read -p "Have you copied the certificate files? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${YELLOW}Please copy the files and run: sudo bash install-vpn.sh${NC}"
else
  # Copy OpenVPN config
  cp "$SCRIPT_DIR/vpn/government.conf" /etc/openvpn/
  cp "$SCRIPT_DIR/vpn/government-up.sh" /etc/openvpn/
  chmod +x /etc/openvpn/government-up.sh

  # Create credentials file
  echo ""
  read -p "Enter VPN username: " VPN_USER
  read -sp "Enter VPN password: " VPN_PASS
  echo
  echo "$VPN_USER" > /etc/openvpn/government-credentials.txt
  echo "$VPN_PASS" >> /etc/openvpn/government-credentials.txt
  chmod 600 /etc/openvpn/government-credentials.txt

  # Enable OpenVPN service
  systemctl enable openvpn@government.service

  echo -e "${GREEN}✓ OpenVPN configured${NC}"
fi
echo ""

# Nginx configuration
echo -e "${YELLOW}Step 12: Configuring Nginx...${NC}"
echo ""
read -p "Do you want to set up Nginx with SSL? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  cp "$SCRIPT_DIR/nginx/smtp-relay.bebot.co.conf" /etc/nginx/sites-available/smtp-relay.bebot.co.conf

  # Remove SSL lines temporarily (will be added by certbot)
  sed -i '/ssl_certificate/d' /etc/nginx/sites-available/smtp-relay.bebot.co.conf
  sed -i 's/listen 443 ssl/listen 443/' /etc/nginx/sites-available/smtp-relay.bebot.co.conf

  ln -sf /etc/nginx/sites-available/smtp-relay.bebot.co.conf /etc/nginx/sites-enabled/

  # Test nginx config
  nginx -t

  # Reload nginx
  systemctl reload nginx

  echo -e "${GREEN}✓ Nginx configured${NC}"
  echo ""
  echo -e "${YELLOW}To enable SSL, run:${NC}"
  echo "sudo certbot --nginx -d smtp-relay.bebot.co"
fi
echo ""

# Firewall configuration
echo -e "${YELLOW}Step 13: Configuring firewall...${NC}"
echo ""
read -p "Configure UFW firewall? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  ufw allow 22/tcp comment 'SSH'
  ufw allow 80/tcp comment 'HTTP'
  ufw allow 443/tcp comment 'HTTPS'
  ufw allow 3000/tcp comment 'SMTP Relay (optional)'

  echo -e "${YELLOW}Enable UFW now? (y/n)${NC}"
  read -p "" -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    ufw --force enable
    echo -e "${GREEN}✓ Firewall enabled${NC}"
  fi
fi
echo ""

# Summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo "1. Start OpenVPN:"
echo "   sudo systemctl start openvpn@government"
echo "   sudo systemctl status openvpn@government"
echo ""
echo "2. Check assigned VPN IP:"
echo "   sudo cat /var/log/openvpn/vpn-assigned-ip.log"
echo "   (Share this IP with IT for whitelisting)"
echo ""
echo "3. Test SMTP connection:"
echo "   cd /opt/smtp-relay"
echo "   node test-smtp.js your-email@example.com"
echo ""
echo "4. Start SMTP Relay:"
echo "   sudo systemctl start smtp-relay"
echo "   sudo systemctl status smtp-relay"
echo ""
echo "5. Configure SSL (if using Nginx):"
echo "   sudo certbot --nginx -d smtp-relay.bebot.co"
echo ""
echo "6. Update n8n workflow with:"
echo "   URL: https://smtp-relay.bebot.co/send-email"
echo "   API Key: $API_KEY"
echo ""
echo -e "${GREEN}========================================${NC}"
