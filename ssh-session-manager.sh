#!/bin/bash

# Path to the sessions file
SESSIONS_FILE="$HOME/.ssh/sessions.json"

# Function to create sample sessions.json
create_sample_sessions() {
    local config_file="$HOME/.ssh/config"
    local temp_json=$(mktemp)
    echo '{}' > "$temp_json"

    if [[ -f "$config_file" ]]; then
        local current_host=""
        local user=""
        local hostname=""
        local port=22
        local key=""

        while IFS= read -r line; do
            line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            if [[ "$line" =~ ^Host[[:space:]]+(.*) ]]; then
                if [[ -n "$current_host" ]]; then
                    # Add previous host to temp_json
                    local h_host="$current_host"
                    if [[ -z "$hostname" ]]; then
                        h_host="$current_host"
                    fi
                    if [[ -z "$user" ]]; then
                        user=$(whoami)
                    fi
                    jq --arg h "$current_host" \
                       --arg hn "$h_host" \
                       --arg u "$user" \
                       --arg p "$port" \
                       --arg k "$key" \
                       '.[$h] = {host: $hn, user: $u, port: ($p | tonumber), key: $k}' \
                       "$temp_json" > "${temp_json}.tmp" && mv "${temp_json}.tmp" "$temp_json"
                fi
                current_host="${BASH_REMATCH[1]}"
                user=""
                hostname=""
                port=22
            elif [[ "$line" =~ ^[[:space:]]*HostName[[:space:]]+(.*) ]]; then
                hostname="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ ^[[:space:]]*User[[:space:]]+(.*) ]]; then
                user="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ ^[[:space:]]*Port[[:space:]]+(.*) ]]; then
                port="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ ^[[:space:]]*IdentityFile[[:space:]]+(.*) ]]; then
                key="${BASH_REMATCH[1]}"
                # Expand ~ to home directory
                if [[ "$key" == ~* ]]; then
                    key=$(eval echo "$key")
                fi
            fi
        done < "$config_file"

        # Add the last host
        if [[ -n "$current_host" ]]; then
            local h_host="$current_host"
            if [[ -z "$hostname" ]]; then
                h_host="$current_host"
            fi
            if [[ -z "$user" ]]; then
                user=$(whoami)
            fi
            jq --arg h "$current_host" \
               --arg hn "$h_host" \
               --arg u "$user" \
               --arg p "$port" \
               --arg k "$key" \
               '.[$h] = {host: $hn, user: $u, port: ($p | tonumber), key: $k}' \
               "$temp_json" > "${temp_json}.tmp" && mv "${temp_json}.tmp" "$temp_json"
        fi
    fi

    # If no hosts were added, add sample
    local num_hosts=$(jq 'keys | length' "$temp_json")
    if [[ "$num_hosts" -eq 0 ]]; then
        jq --arg h "SampleHost" \
           --arg hn "example.com" \
           --arg u "youruser" \
           --arg p "22" \
           --arg k "~/.ssh/id_rsa" \
           '.[$h] = {host: $hn, user: $u, port: ($p | tonumber), key: $k}' \
           "$temp_json" > "${temp_json}.tmp" && mv "${temp_json}.tmp" "$temp_json"
    fi

    # Write to file
    cp "$temp_json" "$SESSIONS_FILE"
    rm -f "$temp_json" "${temp_json}.tmp"
    echo "Created sample $SESSIONS_FILE based on ~/.ssh/config (or default sample)."
}

# Check if sessions file exists
if [[ ! -f "$SESSIONS_FILE" ]]; then
    create_sample_sessions
fi

# Check if jq is available (required for JSON parsing)
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    exit 1
fi

# Check if fzf is available
if ! command -v fzf &> /dev/null; then
    echo "Error: fzf is required but not installed."
    exit 1
fi

# Check if tmux is available
if ! command -v tmux &> /dev/null; then
    echo "Error: tmux is required but not installed."
    exit 1
fi

# Tmux session name
TMUX_SESSION="ssh-sessions"

# Function to check if tmux session exists
session_exists() {
    tmux has-session -t "$TMUX_SESSION" 2>/dev/null
}

# Create tmux session if it doesn't exist
if ! session_exists; then
    tmux new-session -d -s "$TMUX_SESSION"
fi

# Get list of session names (keys from JSON)
session_names=$(jq -r 'keys[]' "$SESSIONS_FILE")

# Select session using fzf
selected=$(echo "$session_names" | fzf --prompt="Select SSH session: " --height=20)

if [[ -z "$selected" ]]; then
    echo "No session selected."
    exit 0
fi

# Extract user, host, port, and key from JSON
user=$(jq -r --arg key "$selected" '.[$key].user // empty' "$SESSIONS_FILE")
host=$(jq -r --arg key "$selected" '.[$key].host // empty' "$SESSIONS_FILE")
port=$(jq -r --arg key "$selected" '.[$key].port // 22' "$SESSIONS_FILE")
key=$(jq -r --arg key "$selected" '.[$key].key // empty' "$SESSIONS_FILE")

# Expand key path if it contains ~
if [[ -n "$key" && "$key" == ~* ]]; then
    key=$(eval echo "$key")
fi

if [[ -z "$user" ]] || [[ -z "$host" ]]; then
    echo "Error: Invalid session data for '$selected'."
    exit 1
fi

# Create a new tmux window and run SSH (with port and key if specified)
ssh_cmd="ssh $user@$host"
if [[ "$port" != "22" ]]; then
    ssh_cmd="$ssh_cmd -p $port"
fi
if [[ -n "$key" ]]; then
    ssh_cmd="$ssh_cmd -i \"$key\""
fi
tmux new-window -t "$TMUX_SESSION" -n "$selected" "$ssh_cmd"

# Attach to the tmux session
tmux attach-session -t "$TMUX_SESSION"
