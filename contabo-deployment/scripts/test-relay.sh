#!/bin/bash
#
# Test Script for SMTP Relay
# Tests the relay server via HTTP API
#
# Usage: bash test-relay.sh [your-email@example.com]
#

# Configuration
RELAY_URL="${RELAY_URL:-http://localhost:3000}"
API_KEY="${API_KEY:-CHANGE_THIS_API_KEY}"
TEST_EMAIL="${1:-test@example.com}"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}SMTP Relay API Test${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Relay URL: $RELAY_URL"
echo "Test Email: $TEST_EMAIL"
echo ""

# Test 1: Health check
echo -e "${YELLOW}[Test 1] Health Check${NC}"
HEALTH_RESPONSE=$(curl -s "$RELAY_URL/health")
echo "$HEALTH_RESPONSE" | jq .

if echo "$HEALTH_RESPONSE" | jq -e '.status == "ok"' > /dev/null; then
  echo -e "${GREEN}✓ Health check passed${NC}"
else
  echo -e "${RED}✗ Health check failed${NC}"
  exit 1
fi
echo ""

# Test 2: SMTP verification
echo -e "${YELLOW}[Test 2] SMTP Connection Verification${NC}"
VERIFY_RESPONSE=$(curl -s -H "X-API-Key: $API_KEY" "$RELAY_URL/verify-smtp")
echo "$VERIFY_RESPONSE" | jq .

if echo "$VERIFY_RESPONSE" | jq -e '.success == true' > /dev/null; then
  echo -e "${GREEN}✓ SMTP connection verified${NC}"
else
  echo -e "${RED}✗ SMTP connection failed${NC}"
  echo -e "${YELLOW}Make sure VPN is connected!${NC}"
  exit 1
fi
echo ""

# Test 3: Send test email
echo -e "${YELLOW}[Test 3] Sending Test Email${NC}"
echo "To: $TEST_EMAIL"
echo ""

SEND_RESPONSE=$(curl -s -X POST "$RELAY_URL/send-email" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $API_KEY" \
  -d "{
    \"to\": \"$TEST_EMAIL\",
    \"subject\": \"Test Email - SMTP Relay\",
    \"html\": \"<h1>Test Successful!</h1><p>SMTP relay is working correctly.</p><p>Timestamp: $(date)</p>\"
  }")

echo "$SEND_RESPONSE" | jq .

if echo "$SEND_RESPONSE" | jq -e '.success == true' > /dev/null; then
  echo -e "${GREEN}✓ Email sent successfully!${NC}"
  echo ""
  MESSAGE_ID=$(echo "$SEND_RESPONSE" | jq -r '.messageId')
  echo "Message ID: $MESSAGE_ID"
  echo ""
  echo -e "${GREEN}Check your inbox at: $TEST_EMAIL${NC}"
else
  echo -e "${RED}✗ Email send failed${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}All tests passed!${NC}"
echo -e "${GREEN}========================================${NC}"
