#!/bin/bash

# ============================================
# Create groups and add page rules based on folders and include_rules.json
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

# Load environment variables
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
: ${SOURCE_DIR:?Variable SOURCE_DIR not set}
: ${GLOBAL_PERMISSIONS:?Variable GLOBAL_PERMISSIONS not set}

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper function to call GraphQL
call_graphql() {
    local query="$1"
    local compact_query=$(echo "$query" | tr -d '\n' | sed 's/"/\\"/g')
    curl -s -L -k -X POST "$WIKI_URL/graphql" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"query\": \"$compact_query\"}"
}

# Get all groups (id and name)
get_all_groups() {
    local query='{ groups { list { id name } } }'
    local response=$(call_graphql "$query")
    echo "$response" | jq -r '.data.groups.list[] | "\(.id):\(.name)"' 2>/dev/null
}

# Create a new group
create_group() {
    local name="$1"
    local mutation='mutation { groups { create(name: "'$name'") { responseResult { succeeded } group { id name } } } }'
    local response=$(call_graphql "$mutation")
    echo "$response" | jq -e '.data.groups.create.responseResult.succeeded' > /dev/null
}

# Add a single page rule to a group
add_page_rule() {
    local group_id="$1"
    local group_name="$2"
    local target_path="$3"   # e.g., "devops" (will be used as regex)
    local rule_id="rule_${group_name}_to_${target_path}"
    # Sanitize rule_id: replace non-alphanumeric with underscore
    rule_id=$(echo "$rule_id" | sed 's/[^a-zA-Z0-9]/_/g')
    
    local mutation="mutation {
        groups {
            update(
                id: $group_id,
                name: \"$group_name\",
                redirectOnLogin: \"/\",
                permissions: [\"read:pages\", \"write:pages\"],
                pageRules: [
                    {
                        id: \"$rule_id\",
                        deny: false,
                        match: REGEX,
                        roles: [\"read:pages\", \"write:pages\"],
                        path: \"$target_path\",
                        locales: []
                    }
                ]
            ) {
                responseResult { succeeded errorCode message }
            }
        }
    }"
    local response=$(call_graphql "$mutation")
    if echo "$response" | jq -e '.data.groups.update.responseResult.succeeded == true' > /dev/null; then
        return 0
    else
        local err=$(echo "$response" | jq -r '.errors[0].message // .data.groups.update.responseResult.message // "Unknown"')
        echo -e "   ${RED}❌ Failed to add rule for $group_name -> $target_path: $err${NC}" >&2
        return 1
    fi
}

# ----- Main -----
echo -e "${YELLOW}🔍 Scanning directory: $SOURCE_DIR${NC}"
# Get all groups and build mapping name->id
declare -A GROUP_IDS
while IFS=: read -r id name; do
    GROUP_IDS["$name"]="$id"
done < <(get_all_groups)

# Get list of all folder names (potential target groups)
all_folders=()
for dir in "$SOURCE_DIR"/*/ ; do
    if [ -d "$dir" ]; then
        folder=$(basename "$dir")
        all_folders+=("$folder")
    fi
done

# Process each folder
for dir in "$SOURCE_DIR"/*/ ; do
    if [ -d "$dir" ]; then
        GROUP_NAME=$(basename "$dir")
        echo -e "\n📁 Processing folder: ${GREEN}$GROUP_NAME${NC}"

        # Create group if not exists
        if [[ -z "${GROUP_IDS[$GROUP_NAME]}" ]]; then
            echo -e "   ${YELLOW}🆕 Creating new group: $GROUP_NAME ...${NC}"
            if create_group "$GROUP_NAME"; then
                echo -e "   ${GREEN}✅ Group '$GROUP_NAME' created.${NC}"
                sleep 2
                # Refresh group IDs
                while IFS=: read -r id name; do
                    GROUP_IDS["$name"]="$id"
                done < <(get_all_groups)
            else
                echo -e "   ${RED}❌ Failed to create group '$GROUP_NAME'.${NC}"
                continue
            fi
        fi
        GROUP_ID="${GROUP_IDS[$GROUP_NAME]}"

        # 1. Add default page rule for own folder (so group can access its own pages)
        echo -e "   🔧 Adding default page rule for '$GROUP_NAME' (self)..."
        if add_page_rule "$GROUP_ID" "$GROUP_NAME" "$GROUP_NAME"; then
            echo -e "   ${GREEN}✅ Default rule added.${NC}"
        else
            echo -e "   ${YELLOW}⚠️  Could not add default rule (maybe already exists).${NC}"
        fi

        # 2. Check for include_rules.json
        RULES_FILE="$dir/include_rules.json"
        if [ -f "$RULES_FILE" ]; then
            echo -e "   📄 Found include_rules.json, processing..."
            # Read the JSON array
            TARGETS=$(jq -r '.[]' "$RULES_FILE" 2>/dev/null)
            if [ -z "$TARGETS" ]; then
                echo -e "   ${YELLOW}⚠️  include_rules.json is empty or invalid.${NC}"
                continue
            fi
            
            # If contains "all", replace with all other folders
            if echo "$TARGETS" | grep -qx "all"; then
                TARGETS=()
                for f in "${all_folders[@]}"; do
                    if [ "$f" != "$GROUP_NAME" ]; then
                        TARGETS+=("$f")
                    fi
                done
                echo -e "   ${YELLOW}🔁 'all' detected. Will add rules for: ${TARGETS[*]}${NC}"
            fi
            
            # For each target, add a page rule
            for target in $TARGETS; do
                # Skip if target is the same as current group
                if [ "$target" == "$GROUP_NAME" ]; then
                    continue
                fi
                # Check if target folder exists (optional)
                if [ ! -d "$SOURCE_DIR/$target" ]; then
                    echo -e "   ${YELLOW}⚠️  Target folder '$target' does not exist, skipping.${NC}"
                    continue
                fi
                echo -e "   🔧 Adding page rule for '$GROUP_NAME' to access '/$target'..."
                if add_page_rule "$GROUP_ID" "$GROUP_NAME" "$target"; then
                    echo -e "   ${GREEN}✅ Rule added for target '$target'.${NC}"
                else
                    echo -e "   ${RED}❌ Failed to add rule for target '$target'.${NC}"
                fi
            done
        else
            echo -e "   ℹ️  No include_rules.json found. Only default self-rule added."
        fi
    fi
done

echo -e "${GREEN}✅ Group setup completed.${NC}"
