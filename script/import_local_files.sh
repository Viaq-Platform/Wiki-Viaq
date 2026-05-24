#!/bin/bash

# ============================================
# Trigger a full import from Local File System storage
# ============================================

# Check and install jq if missing
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing it now..."
    sudo apt update && sudo apt install jq -y
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install jq. Please install it manually: sudo apt install jq"
        exit 1
    fi
    echo "✅ jq installed successfully."
fi

# Load environment variables from .env if not already set
if [ -z "$WIKI_URL" ]; then
    ENV_FILE="/var/www/Wiki-Viaq/environments/.env"
    if [ -f "$ENV_FILE" ]; then
        set -a
        source "$ENV_FILE"
        set +a
    else
        echo "❌ .env file not found at $ENV_FILE"
        exit 1
    fi
fi

# Check required variables
: ${WIKI_URL:?Variable WIKI_URL not set}
: ${API_TOKEN:?Variable API_TOKEN not set}

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper function to call GraphQL (follows redirects, ignores SSL)
call_graphql() {
    local query="$1"
    local compact_query=$(echo "$query" | tr -d '\n' | sed 's/"/\\"/g')
    curl -s -L -k -X POST "$WIKI_URL/graphql" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"query\": \"$compact_query\"}"
}

# Get storage ID for type "disk" (Local File System) using jq
get_local_storage_id() {
    local query='{ storage { list { id type } } }'
    local response=$(call_graphql "$query")
    # Use jq to extract the id where type is "disk"
    echo "$response" | jq -r '.data.storage.list[] | select(.type == "disk") | .id' 2>/dev/null
}

# Trigger full import
trigger_import() {
    local storage_id="$1"
    echo -e "${YELLOW}🔄 Triggering full import from Local File System storage...${NC}"
    local mutation='mutation { storage { sync(id: "'$storage_id'", mode: full) { responseResult { succeeded errorCode message } } } }'
    local response=$(call_graphql "$mutation")
    if echo "$response" | jq -e '.data.storage.sync.responseResult.succeeded == true' > /dev/null; then
        echo -e "${GREEN}✅ Import successfully started.${NC}"
        return 0
    else
        local error_msg=$(echo "$response" | jq -r '.errors[0].message // .data.storage.sync.responseResult.message // "Unknown error"')
        echo -e "${RED}❌ Import failed: $error_msg${NC}"
        return 1
    fi
}

# ---------- Main ----------
echo -e "${YELLOW}🔍 Locating Local File System storage...${NC}"
STORAGE_ID=$(get_local_storage_id)

if [ -z "$STORAGE_ID" ]; then
    echo -e "${RED}❌ Local File System storage not found. Please ensure it is enabled in Administration → Storage.${NC}"
    exit 1
fi
echo -e "${GREEN}Found storage ID: $STORAGE_ID${NC}"

trigger_import "$STORAGE_ID"
