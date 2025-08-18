#!/bin/bash
# 🐚 New Shell - Natural Language Interface for Shell Commands
# Version: 1.0.0-beta
# Author: Nexus Studio (Tryboy869)
# License: MIT
# Contact: nexusstudio100@gmail.com

set -euo pipefail

# Configuration
NEW_SHELL_VERSION="1.0.0-beta"
NEW_SHELL_CONFIG_DIR="$HOME/.new-shell"
NEW_SHELL_CACHE_DIR="$NEW_SHELL_CONFIG_DIR/cache"
NEW_SHELL_LOG_FILE="$NEW_SHELL_CONFIG_DIR/new-shell.log"
CORE_ENGINE_URL="https://api.github.com/repos/Tryboy869/new-shell-engine"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Initialize New Shell environment
init_new_shell() {
    echo -e "${BLUE}🐚 New Shell ${NEW_SHELL_VERSION}${NC}"
    echo -e "${CYAN}Natural language interface for shell commands${NC}"
    echo -e "${PURPLE}Powered by Nexus Studio${NC}"
    echo ""
    
    # Create config directory if it doesn't exist
    mkdir -p "$NEW_SHELL_CONFIG_DIR" "$NEW_SHELL_CACHE_DIR"
    
    # Check for core engine updates
    check_core_engine_update
}

# Log function
log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$NEW_SHELL_LOG_FILE"
}

# Security validation function
validate_input() {
    local input="$1"
    
    # Basic input validation
    if [[ ${#input} -gt 1000 ]]; then
        echo -e "${RED}❌ Input too long (max 1000 characters)${NC}"
        return 1
    fi
    
    # Check for suspicious patterns
    local dangerous_patterns=(
        "rm -rf /"
        "format c:"
        "> /dev/sda"
        "dd if="
        "mkfs"
        "fdisk"
        "eval"
        "exec"
        "curl.*|.*bash"
        "wget.*|.*sh"
    )
    
    for pattern in "${dangerous_patterns[@]}"; do
        if [[ "$input" =~ $pattern ]]; then
            echo -e "${RED}🚨 Potentially dangerous command detected${NC}"
            log_action "SECURITY_BLOCK: $input"
            return 1
        fi
    done
    
    return 0
}

# Check for core engine updates
check_core_engine_update() {
    if command -v curl >/dev/null 2>&1; then
        local latest_release
        latest_release=$(curl -s "$CORE_ENGINE_URL/releases/latest" 2>/dev/null | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4 || echo "")
        
        if [[ -n "$latest_release" ]]; then
            echo -e "${GREEN}✅ Core engine version: $latest_release${NC}"
        else
            echo -e "${YELLOW}⚠️  Using offline mode${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  curl not found, using offline mode${NC}"
    fi
}

# Translate natural language to shell command
translate_command() {
    local natural_input="$1"
    local shell_command=""
    
    # Simple pattern matching for common commands
    # This is a simplified version - the full engine would be more sophisticated
    
    case "$natural_input" in
        *"help"*|*"get started"*)
            shell_command="show_help"
            ;;
        *"list files"*|*"show files"*)
            shell_command="ls -la"
            ;;
        *"current directory"*|*"where am i"*)
            shell_command="pwd"
            ;;
        *"disk space"*|*"storage usage"*)
            shell_command="df -h"
            ;;
        *"system performance"*|*"system status"*)
            shell_command="show_system_performance"
            ;;
        *"running processes"*|*"process list"*)
            shell_command="ps aux"
            ;;
        *"network connections"*)
            shell_command="netstat -tuln"
            ;;
        *"memory usage"*)
            shell_command="free -h"
            ;;
        *"find"*"log files"*)
            shell_command="find . -name '*.log' -type f"
            ;;
        *"count"*"files"*)
            shell_command="find . -type f | wc -l"
            ;;
        *"git status"*)
            shell_command="git status"
            ;;
        *"large files"*)
            shell_command="find . -type f -size +10M -exec ls -lh {} + 2>/dev/null | head -20"
            ;;
        *)
            # For unrecognized patterns, provide helpful message
            shell_command="unknown_command"
            ;;
    esac
    
    echo "$shell_command"
}

# Show help
show_help() {
    echo -e "${PURPLE}🐚 New Shell - Help${NC}"
    echo ""
    echo "Usage: ./app.sh \"natural language command\""
    echo ""
    echo "Examples:"
    echo "  ./app.sh \"list files in current directory\""
    echo "  ./app.sh \"show disk space usage\""
    echo "  ./app.sh \"find all log files\""
    echo "  ./app.sh \"check system performance\""
    echo "  ./app.sh \"show running processes\""
    echo ""
    echo "Features:"
    echo "  • Natural language interface"
    echo "  • Security validation"
    echo "  • Command learning mode"
    echo "  • Safe execution"
    echo ""
    echo "For more examples: ./app.sh \"show me more examples\""
}

# Show system performance
show_system_performance() {
    echo -e "${CYAN}📊 System Performance${NC}"
    echo ""
    
    # CPU usage
    if command -v top >/dev/null 2>&1; then
        local cpu_usage
        cpu_usage=$(top -bn1 | head -3 | tail -1 | awk '{print $2}' | cut -d'%' -f1 2>/dev/null || echo "N/A")
        echo -e "CPU Usage: ${YELLOW}${cpu_usage:-N/A}%${NC}"
    fi
    
    # Memory usage
    if command -v free >/dev/null 2>&1; then
        echo -e "${CYAN}Memory:${NC}"
        free -h
    fi
    
    echo ""
    
    # Disk usage
    echo -e "${CYAN}Disk Usage:${NC}"
    df -h | head -5
}

# Handle unknown commands
handle_unknown_command() {
    local input="$1"
    
    echo -e "${YELLOW}🤔 I didn't understand: \"$input\"${NC}"
    echo ""
    echo "Try these examples:"
    echo "  • \"list files in current directory\""
    echo "  • \"show disk space usage\""
    echo "  • \"check system performance\""
    echo "  • \"find log files\""
    echo ""
    echo "For help: ./app.sh \"help\""
    
    log_action "UNKNOWN_COMMAND: $input"
}

# Execute command safely
execute_command() {
    local shell_command="$1"
    local natural_input="$2"
    
    case "$shell_command" in
        "show_help")
            show_help
            ;;
        "show_system_performance")
            show_system_performance
            ;;
        "unknown_command")
            handle_unknown_command "$natural_input"
            ;;
        *)
            # Show the generated command for learning
            echo -e "${CYAN}Generated command:${NC} $shell_command"
            echo ""
            
            # Execute with confirmation for potentially destructive commands
            if [[ "$shell_command" == *"rm"* ]] || [[ "$shell_command" == *"delete"* ]]; then
                echo -e "${YELLOW}⚠️  This command might delete files. Continue? (y/N)${NC}"
                read -r confirmation
                if [[ "$confirmation" != "y" ]] && [[ "$confirmation" != "Y" ]]; then
                    echo "Command cancelled."
                    return 0
                fi
            fi
            
            # Execute the command
            echo -e "${GREEN}📋 Output:${NC}"
            eval "$shell_command" || {
                echo -e "${RED}❌ Command failed${NC}"
                log_action "COMMAND_FAILED: $shell_command"
                return 1
            }
            ;;
    esac
    
    log_action "EXECUTED: $natural_input -> $shell_command"
}

# Main function
main() {
    # Check if input provided
    if [[ $# -eq 0 ]]; then
        echo -e "${RED}Usage: ./app.sh \"natural language command\"${NC}"
        echo "For help: ./app.sh \"help\""
        exit 1
    fi
    
    local natural_input="$*"
    
    # Initialize
    init_new_shell
    
    # Validate input
    if ! validate_input "$natural_input"; then
        exit 1
    fi
    
    # Translate natural language to shell command
    local shell_command
    shell_command=$(translate_command "$natural_input")
    
    # Execute command
    execute_command "$shell_command" "$natural_input"
    
    echo ""
    echo -e "${CYAN}🐚 New Shell completed${NC}"
    echo -e "${PURPLE}Powered by Nexus Studio ✨${NC}"
}

# Run main function with all arguments
main "$@"
