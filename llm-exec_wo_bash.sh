#!/bin/sh

# Configuration
OLLAMA_HOST="${OLLAMA_HOST:-http://192.168.1.xxx:11434}"
MODEL="${OLLAMA_MODEL:-qwen2.5-coder:32b}"

# Colors for output (if terminal supports it)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to call Ollama API
call_ollama() {
    prompt="$1"
    
    system_prompt="You are a Linux command generator. The user will describe what they want to do, and you must respond with ONLY the bash command needed to accomplish it. Do not include explanations, markdown formatting, or anything else - just the raw command. The command should be safe and appropriate for execution."
    
    response=$(curl -s "$OLLAMA_HOST/api/generate" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"$MODEL\",
            \"prompt\": \"$system_prompt\n\nUser request: $prompt\n\nCommand:\",
            \"stream\": false
        }")
    
    if [ $? -ne 0 ]; then
        printf "${RED}Error: Failed to connect to Ollama at $OLLAMA_HOST${NC}\n" >&2
        exit 1
    fi
    
    # Extract the response text
    echo "$response" | grep -o '"response":"[^"]*"' | sed 's/"response":"//;s/"$//' | sed 's/\\n/\n/g'
}

# Function to decode unicode escapes
decode_unicode() {
    str="$1"
    # Decode common unicode escapes
    str=$(echo "$str" | sed 's/\\u003e/>/g')
    str=$(echo "$str" | sed 's/\\u003c/</g')
    str=$(echo "$str" | sed 's/\\u0026/\&/g')
    str=$(echo "$str" | sed "s/\\\\u0027/'/g")
    str=$(echo "$str" | sed 's/\\u0022/"/g')
    str=$(echo "$str" | sed 's/\\n/ /g')
    str=$(echo "$str" | sed 's/\\t/ /g')
    echo "$str"
}

# Function to clean command output from LLM
clean_command() {
    cmd="$1"
    # Decode unicode escapes first
    cmd=$(decode_unicode "$cmd")
    # Remove markdown code blocks if present
    cmd=$(echo "$cmd" | sed 's/```bash//g' | sed 's/```//g')
    # Remove leading/trailing whitespace
    cmd=$(echo "$cmd" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    # Get first non-empty line (in case LLM added explanation)
    cmd=$(echo "$cmd" | grep -v '^$' | head -1)
    echo "$cmd"
}

# Main script
if [ $# -eq 0 ]; then
    printf "${YELLOW}Usage: $0 \"your request in natural language\"${NC}\n"
    printf "${YELLOW}Example: $0 \"find all pdf files in current directory\"${NC}\n"
    printf "\n"
    printf "${BLUE}Environment variables:${NC}\n"
    printf "  OLLAMA_HOST  - Ollama server URL (default: http://localhost:11434)\n"
    printf "  OLLAMA_MODEL - Model to use (default: llama2)\n"
    exit 1
fi

USER_REQUEST="$*"

printf "${BLUE}Request:${NC} $USER_REQUEST\n"
printf "${YELLOW}Asking LLM for command...${NC}\n"

# Get command from LLM
LLM_RESPONSE=$(call_ollama "$USER_REQUEST")
COMMAND=$(clean_command "$LLM_RESPONSE")

if [ -z "$COMMAND" ]; then
    printf "${RED}Error: LLM did not return a valid command${NC}\n"
    exit 1
fi

printf "${GREEN}Generated command:${NC} $COMMAND\n"
printf "\n"

# Ask for confirmation
printf "Execute this command? (y/n): "
read -r REPLY

# Check if reply starts with y or Y
case "$REPLY" in
    [Yy]*)
        printf "${BLUE}Executing...${NC}\n"
        printf "----------------------------------------\n"
        eval "$COMMAND"
        EXIT_CODE=$?
        printf "----------------------------------------\n"
        if [ $EXIT_CODE -eq 0 ]; then
            printf "${GREEN}Command completed successfully${NC}\n"
        else
            printf "${RED}Command exited with code $EXIT_CODE${NC}\n"
        fi
        ;;
    *)
        printf "${YELLOW}Command execution cancelled${NC}\n"
        ;;
esac