#!/bin/bash

# AWS Instance Metadata Service (IMDS) 
# Documentation: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html
# Returns JSON formatted output
# Supports both IMDS v1 and v2

set -euo pipefail

IMDS_BASE="http://169.254.169.254" # IMDS v1 and v2 endpoint
TOKEN_TTL="3600" # 1 hour

# Function to get IMDS v2 token
get_token() {
    curl -s -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: $TOKEN_TTL" \
        "$IMDS_BASE/latest/api/token" 2>/dev/null
}

# Function to make request with token
make_request() {
    local path="$1"
    local token="$2"
    local url="$IMDS_BASE/latest/meta-data/$path"
    
    if [[ -n "$token" ]]; then
        curl -s -H "X-aws-ec2-metadata-token: $token" "$url" 2>/dev/null
    else
        curl -s "$url" 2>/dev/null
    fi
}

# Function to get all metadata as JSON
get_all() {
    local token=""
    
    # Try IMDS v2 first
    token=$(get_token)
    if [[ -z "$token" ]]; then
        # Fall back to IMDS v1 - no token needed
        echo "{"
        local first=true
        curl -s "$IMDS_BASE/latest/meta-data/" | while read -r path; do
            [[ -z "$path" ]] && continue
            
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo ","
            fi
            
            local value
            value=$(curl -s "$IMDS_BASE/latest/meta-data/$path" 2>/dev/null || echo "null")
            value=$(echo "$value" | sed 's/"/\\"/g' | tr '\n' ' ')
            
            echo -n "\"$path\":\"$value\""
        done
        echo
        echo "}"
    else
        # Use IMDS v2 with token
        echo "{"
        local first=true
        make_request "" "$token" | while read -r path; do
            [[ -z "$path" ]] && continue
            
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo ","
            fi
            
            local value
            value=$(make_request "$path" "$token" 2>/dev/null || echo "null")
            value=$(echo "$value" | sed 's/"/\\"/g' | tr '\n' ' ')
            
            echo -n "\"$path\":\"$value\""
        done
        echo
        echo "}"
    fi
}

# Function to get specific key
get_key() {
    local key="$1"
    local token=""
    local value
    
    # Try IMDS v2 first
    token=$(get_token)
    if [[ -z "$token" ]]; then
        # Fall back to IMDS v1 - no token needed
        value=$(curl -s "$IMDS_BASE/latest/meta-data/$key" 2>/dev/null || echo "")
    else
        # Use IMDS v2 with token
        value=$(make_request "$key" "$token" 2>/dev/null || echo "")
    fi
    
    if [[ -z "$value" ]]; then
        echo "{\"error\":\"Key '$key' not found\"}" >&2
        exit 1
    fi
    
    echo "{\"$key\":\"$value\"}"
}

# Main logic
if [[ $# -eq 0 ]]; then
    # Get all metadata
    get_all
elif [[ $# -eq 1 ]]; then
    # Get specific key
    get_key "$1"
else
    echo "Usage: $0 [KEY]"
    echo "  $0        - Get all metadata"
    echo "  $0 KEY    - Get specific key"
    exit 1
fi