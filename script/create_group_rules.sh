#!/bin/bash

# ============================================
# Add a Page Rule (Path Matches Regex) to an existing group
# Usage: create_group_rules.sh <groupName> <regexPattern>
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

# Load .env if not already loaded
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

: ${WIKI_URL:?Variable WIKI_URL not set}
: ${API_TOKEN:?Variable API_TOKEN not set}

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ $# -ne 2 ]; then
    echo -e "${RED}Usage: $0 <groupName> <regexPattern>${NC}"
    exit 1
fi

GROUP_NAME="$1"
REGEX_PATTERN="$2"

call_graphql() {
    local query="$1"
    local compact_query=$(echo "$query" | tr -d '\n' | sed 's/"/\\"/g')
    curl -s -L -k -X POST "$WIKI_URL/graphql" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"query\": \"$compact_query\"}"
}

# 1. Get group ID and existing pageRules
echo -e "   ${YELLOW}Fetching group ID and current rules for '$GROUP_NAME'...${NC}"
QUERY='{ groups { list(filter: "'$GROUP_NAME'") { id name pageRules { id deny match roles path locales } } } }'
RESPONSE=$(call_graphql "$QUERY")
GROUP_ID=$(echo "$RESPONSE" | jq -r '.data.groups.list[0].id')
EXISTING_RULES=$(echo "$RESPONSE" | jq -c '.data.groups.list[0].pageRules // []')

if [ -z "$GROUP_ID" ] || [ "$GROUP_ID" = "null" ]; then
    echo -e "   ${RED}❌ Group '$GROUP_NAME' not found.${NC}"
    exit 1
fi
echo -e "   ${GREEN}Group ID: $GROUP_ID${NC}"

# 2. Build new rule object
NEW_RULE_ID="rule_$(echo "${GROUP_NAME}_${REGEX_PATTERN}" | sed 's/[^a-zA-Z0-9]/_/g')"
NEW_RULE=$(jq -n \
    --arg id "$NEW_RULE_ID" \
    --arg path "$REGEX_PATTERN" \
    '{
        id: $id,
        deny: false,
        match: "REGEX",
        roles: ["read:pages", "write:pages"],
        path: $path,
        locales: []
    }')

# 3. Merge with existing rules (avoid duplicate by id)
UPDATED_RULES=$(echo "$EXISTING_RULES" | jq --argjson new "$NEW_RULE" '
    if any(.id == $new.id) then . else . + [$new] end
')

# 4. Update group with merged rules
MUTATION="mutation {
  groups {
    update(
      id: $GROUP_ID,
      name: \"$GROUP_NAME\",
      redirectOnLogin: \"/\",
      permissions: [\"read:pages\", \"write:pages\"],
      pageRules: $UPDATED_RULES
    ) {
      responseResult { succeeded errorCode message }
    }
  }
}"

echo -e "   ${YELLOW}Sending mutation to add page rule...${NC}"
UPDATE_RESPONSE=$(call_graphql "$MUTATION")

if echo "$UPDATE_RESPONSE" | jq -e '.data.groups.update.responseResult.succeeded == true' > /dev/null; then
    echo -e "   ${GREEN}✅ Page Rule added for group '$GROUP_NAME' with regex: $REGEX_PATTERN${NC}"
else
    ERROR_MSG=$(echo "$UPDATE_RESPONSE" | jq -r '.errors[0].message // .data.groups.update.responseResult.message // "Unknown error"')
    echo -e "   ${RED}❌ Failed to add Page Rule: $ERROR_MSG${NC}"
    exit 1
fi
