#!/bin/bash

# ============================================================
# Async import with live log streaming (only new logs)
# Stores all logs in /var/www/Wiki-Viaq/logs/ with timestamped filename
# ============================================================

if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing it now..."
    sudo apt update && sudo apt install jq -y
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install jq. Please install it manually: sudo apt install jq"
        exit 1
    fi
    echo "✅ jq installed successfully."
fi

ENV_FILE="${ENV_FILE:-/var/www/Wiki-Viaq/environments/.env}"
if [ -f "$ENV_FILE" ]; then
    set -a; source "$ENV_FILE"; set +a
else
    echo "❌ .env file not found at $ENV_FILE"
    exit 1
fi

: ${WIKI_URL:?Variable WIKI_URL not set}
: ${API_TOKEN:?Variable API_TOKEN not set}

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ------------------------------------------------------------
# Create logs directory if it doesn't exist
# ------------------------------------------------------------
LOG_DIR="/var/www/Wiki-Viaq/logs"
if [ ! -d "$LOG_DIR" ]; then
    sudo mkdir -p "$LOG_DIR"
    echo -e "${BLUE}📁 Created logs directory: $LOG_DIR${NC}"
fi

# Generate timestamped log file name
TIMESTAMP=$(date -u +"%Y-%m-%d-%H-%M-%S")
LOG_FILE="$LOG_DIR/${TIMESTAMP}-import_local_files.log"

# ------------------------------------------------------------
# Record start time (UTC, format compatible with `docker logs --since`)
# ------------------------------------------------------------
START_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo -e "${YELLOW}📅 Starting import at $START_TIME (UTC)${NC}"
echo -e "${BLUE}📝 Logs will be stored in: $LOG_FILE${NC}"

# Initialize log file
echo "=== Import started at $START_TIME ===" | sudo tee "$LOG_FILE" > /dev/null

# ------------------------------------------------------------
# Async GraphQL caller – runs in background, writes to a file
# ------------------------------------------------------------
call_graphql_async() {
    local query="$1"
    local outfile="$2"
    local compact=$(echo "$query" | tr -d '\n' | sed 's/"/\\"/g')
    curl -s -L -k -X POST "$WIKI_URL/graphql" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"query\": \"$compact\"}" > "$outfile"
}

# ------------------------------------------------------------
# Main retry loop
# ------------------------------------------------------------
MAX_RETRIES=3
RETRY_DELAY=5
ATTEMPT=1
SUCCESS=false

while [ $ATTEMPT -le $MAX_RETRIES ]; do
    echo -e "\n${YELLOW}🔄 Triggering full import (handler: importAll) – attempt $ATTEMPT of $MAX_RETRIES${NC}"
    
    TMP_RESPONSE=$(mktemp)
    
    # Start the background mutation
    call_graphql_async 'mutation { storage { executeAction(targetKey: "disk", handler: "importAll") { responseResult { succeeded errorCode message } } } }' "$TMP_RESPONSE" &
    BG_PID=$!
    
    echo -e "${BLUE}📡 Streaming new logs (since $START_TIME) – only unique lines will appear${NC}"
    
    # Associative array to track seen log lines (based on timestamp)
    declare -A SEEN_LINES
    
    # Loop while the background job is running
    while kill -0 $BG_PID 2>/dev/null; do
        # Fetch logs generated since the start time
        LOGS=$(docker logs wikijs-app --since "$START_TIME" --tail 100 2>&1 | grep -iE "storage|import|disk")
        
        if [ -n "$LOGS" ]; then
            while IFS= read -r line; do
                # Extract timestamp (first field, like "2026-05-25T07:30:21.772Z")
                TS=$(echo "$line" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}Z')
                if [ -z "$TS" ]; then
                    # If no timestamp, treat as new line (shouldn't happen)
                    if [ -z "${SEEN_LINES[$line]}" ]; then
                        echo "$line"
                        echo "$line" | sudo tee -a "$LOG_FILE" > /dev/null
                        SEEN_LINES[$line]=1
                    fi
                    continue
                fi
                KEY="$TS"
                if [ -z "${SEEN_LINES[$KEY]}" ]; then
                    echo "$line"
                    echo "$line" | sudo tee -a "$LOG_FILE" > /dev/null
                    SEEN_LINES[$KEY]=1
                fi
            done <<< "$LOGS"
        fi
        
        sleep 1
    done
    
    # Background process finished – read the response
    RESPONSE=$(cat "$TMP_RESPONSE")
    rm -f "$TMP_RESPONSE"
    
    SUCCEEDED=$(echo "$RESPONSE" | jq -r '.data.storage.executeAction.responseResult.succeeded')
    if [ "$SUCCEEDED" = "true" ]; then
        echo -e "\n${GREEN}✅ Import successfully started.${NC}"
        echo "=== Import API succeeded at $(date -u +"%Y-%m-%dT%H:%M:%SZ") ===" | sudo tee -a "$LOG_FILE" > /dev/null
        SUCCESS=true
        break
    else
        ERROR_MSG=$(echo "$RESPONSE" | jq -r '.errors[0].message // .data.storage.executeAction.responseResult.message // "Unknown error"')
        echo -e "\n${RED}❌ Import failed on attempt $ATTEMPT: $ERROR_MSG${NC}"
        echo "=== Import API failed on attempt $ATTEMPT: $ERROR_MSG ===" | sudo tee -a "$LOG_FILE" > /dev/null
        if [ $ATTEMPT -lt $MAX_RETRIES ]; then
            echo -e "${YELLOW}Retrying in ${RETRY_DELAY} seconds...${NC}"
            sleep $RETRY_DELAY
            RETRY_DELAY=$((RETRY_DELAY * 2))
        fi
    fi
    
    ((ATTEMPT++))
done

if [ "$SUCCESS" = false ]; then
    echo -e "${RED}❌ Import failed after $MAX_RETRIES attempts.${NC}"
    echo "=== Import failed after $MAX_RETRIES attempts ===" | sudo tee -a "$LOG_FILE" > /dev/null
    echo -e "\n${YELLOW}📋 Full log saved at: $LOG_FILE${NC}"
    exit 1
fi

# ------------------------------------------------------------
# After success, show summary
# ------------------------------------------------------------
echo -e "\n${BLUE}📄 Last 10 lines of captured logs:${NC}"
tail -10 "$LOG_FILE"

echo -e "\n${GREEN}🏁 Import script completed. Check the wiki in a few moments for new content.${NC}"
echo -e "${BLUE}💡 Complete log saved at: $LOG_FILE${NC}"
