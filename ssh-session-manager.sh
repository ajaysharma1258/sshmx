#!/bin/bash

# Path to the sessions file
SESSIONS_FILE="$HOME/.ssh/sessions.json"

# Log file for parsing
LOG_FILE="$HOME/.ssh/ssh-session-manager.log"

# Function to create sample sessions.json
create_sample_sessions() {
    local config_file="$HOME/.ssh/config"
    local temp_json=$(mktemp)
    echo '{}' > "$temp_json"

    echo "$(date): Starting config parsing" >> "$LOG_FILE"

    if [[ -f "$config_file" ]]; then
        echo "$(date): Parsing ~/.ssh/config file..." >> "$LOG_FILE"
        local current_host=""
        local user=""
        local hostname=""
        local port=22
        local key=""

        while IFS= read -r line; do
            line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            echo "$(date): Processing line: '$line'" >> "$LOG_FILE"
            if [[ "$line" =~ ^Host[[:space:]]+(.*) ]]; then
                echo "$(date): Checking Host regex on: '$line'" >> "$LOG_FILE"
                local captured="${BASH_REMATCH[1]}"
                echo "$(date): Matched Host, captured: '$captured'" >> "$LOG_FILE"
                if [[ -n "$current_host" ]]; then
                    # Add previous host to temp_json
                    local h_host="$hostname"
                    if [[ -z "$h_host" ]]; then
                        h_host="$current_host"
                    fi
                    if [[ -z "$user" ]]; then
                        user=$(whoami)
                    fi

                    # Resolve h_host to IP if it's a hostname
                    local resolved_host="$h_host"
                    if [[ ! "$h_host" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                        if command -v getent &> /dev/null; then
                            local temp_ip=$(getent hosts "$h_host" | awk '{print $1}' | head -n1)
                            if [[ -n "$temp_ip" && "$temp_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                                resolved_host="$temp_ip"
                                echo "$(date): Resolved '$h_host' to IP: $resolved_host" >> "$LOG_FILE"
                            else
                                echo "$(date): Could not resolve '$h_host' to IP, using hostname" >> "$LOG_FILE"
                            fi
                        else
                            echo "$(date): getent not available, using hostname '$h_host'" >> "$LOG_FILE"
                        fi
                    fi

                    echo "$(date): Adding host '$current_host': user='$user', host='$resolved_host', port=$port, key='$key'" >> "$LOG_FILE"
                    jq --arg h "$current_host" \
                       --arg hn "$resolved_host" \
                       --arg u "$user" \
                       --arg p "$port" \
                       --arg k "$key" \
                       '.[$h] = {host: $hn, user: $u, port: ($p | tonumber), key: $k}' \
                       "$temp_json" > "${temp_json}.tmp" && mv "${temp_json}.tmp" "$temp_json"
                fi
                current_host="$captured"
                if [[ -z "$current_host" ]]; then
                    echo "$(date): Invalid empty Host line: '$line'" >> "$LOG_FILE"
                    continue
                fi
                user=""
                hostname=""
                port=22
                key=""
                echo "$(date): Starting new host block: '$current_host'" >> "$LOG_FILE"
            elif [[ "$line" =~ ^[[:space:]]*HostName[[:space:]]+(.*) ]]; then
                hostname="${BASH_REMATCH[1]}"
                echo "$(date): HostName: '$hostname'" >> "$LOG_FILE"
            elif [[ "$line" =~ ^[[:space:]]*User[[:space:]]+(.*) ]]; then
                user="${BASH_REMATCH[1]}"
                echo "$(date): User: '$user'" >> "$LOG_FILE"
            elif [[ "$line" =~ ^[[:space:]]*Port[[:space:]]+(.*) ]]; then
                port="${BASH_REMATCH[1]}"
                echo "$(date): Port: $port" >> "$LOG_FILE"
            elif [[ "$line" =~ ^[[:space:]]*IdentityFile[[:space:]]+(.*) ]]; then
                key="${BASH_REMATCH[1]}"
                # Expand ~ to home directory
                if [[ "$key" == ~* ]]; then
                    key=$(eval echo "$key")
                fi
                echo "$(date): IdentityFile: '$key'" >> "$LOG_FILE"
            else
                echo "$(date): Line did not match any pattern: '$line'" >> "$LOG_FILE"
                if [[ -n "$line" ]]; then  # Skip empty lines
                    echo "$(date): Skipping line: '$line'" >> "$LOG_FILE"
                fi
            fi
        done < "$config_file"

        # Add the last host
        if [[ -n "$current_host" ]]; then
            local h_host="$hostname"
            if [[ -z "$h_host" ]]; then
                h_host="$current_host"
            fi
            if [[ -z "$user" ]]; then
                user=$(whoami)
            fi

            # Resolve h_host to IP if it's a hostname
            local resolved_host="$h_host"
            if [[ ! "$h_host" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                if command -v getent &> /dev/null; then
                    local temp_ip=$(getent hosts "$h_host" | awk '{print $1}' | head -n1)
                    if [[ -n "$temp_ip" && "$temp_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                        resolved_host="$temp_ip"
                        echo "$(date): Resolved last host '$h_host' to IP: $resolved_host" >> "$LOG_FILE"
                    else
                        echo "$(date): Could not resolve last host '$h_host' to IP, using hostname" >> "$LOG_FILE"
                    fi
                else
                    echo "$(date): getent not available for last host, using hostname '$h_host'" >> "$LOG_FILE"
                fi
            fi

            echo "$(date): Adding last host '$current_host': user='$user', host='$resolved_host', port=$port, key='$key'" >> "$LOG_FILE"
            jq --arg h "$current_host" \
               --arg hn "$resolved_host" \
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
        local sample_host="example.com"
        local resolved_sample="$sample_host"
        if [[ ! "$sample_host" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            if command -v getent &> /dev/null; then
                local temp_ip=$(getent hosts "$sample_host" | awk '{print $1}' | head -n1)
                if [[ -n "$temp_ip" && "$temp_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    resolved_sample="$temp_ip"
                fi
            fi
        fi

        echo "$(date): No hosts found in config, adding sample host." >> "$LOG_FILE"
        jq --arg h "SampleHost" \
           --arg hn "$resolved_sample" \
           --arg u "youruser" \
           --arg p "22" \
           --arg k "~/.ssh/id_rsa" \
           '.[$h] = {host: $hn, user: $u, port: ($p | tonumber), key: $k}' \
           "$temp_json" > "${temp_json}.tmp" && mv "${temp_json}.tmp" "$temp_json"
    else
        echo "$(date): Added $num_hosts hosts from config." >> "$LOG_FILE"
    fi

    # Write to file
    cp "$temp_json" "$SESSIONS_FILE"
    rm -f "$temp_json" "${temp_json}.tmp"
    echo "Created sample $SESSIONS_FILE based on ~/.ssh/config (or default sample)."
    echo "$(date): Generated JSON content:" >> "$LOG_FILE"
    cat "$SESSIONS_FILE" >> "$LOG_FILE"
    echo "$(date): Config parsing complete" >> "$LOG_FILE"
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

# Check if chromaterm (ct) is available for colorizing output
if ! command -v ct &> /dev/null; then
    echo "Warning: chromaterm (ct) not found. Install it for colored terminal output (e.g., cargo install chromaterm)."
    USE_CHROMATERM=false
else
    USE_CHROMATERM=true
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

# Resolve host to IP if it's a hostname (not already an IP)
connect_host="$host"
if [[ ! "$host" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    if command -v getent &> /dev/null; then
        resolved_ip=$(getent hosts "$host" | awk '{print $1}' | head -n1)
        if [[ -n "$resolved_ip" && "$resolved_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            connect_host="$resolved_ip"
            echo "Resolved '$host' to IP: $connect_host"
        else
            echo "Warning: Could not resolve '$host' to IP, using hostname."
        fi
    else
        echo "Warning: getent not available, using hostname '$host'."
    fi
fi

if [[ -z "$user" ]] || [[ -z "$connect_host" ]]; then
    echo "Error: Invalid session data for '$selected'."
    exit 1
fi

# Create a new tmux window and run SSH (with port and key if specified)
ssh_cmd="ssh $user@$connect_host"
if [[ "$port" != "22" ]]; then
    ssh_cmd="$ssh_cmd -p $port"
fi
if [[ -n "$key" ]]; then
    ssh_cmd="$ssh_cmd -i \"$key\""
fi
if [[ "$USE_CHROMATERM" == true ]]; then
    ssh_cmd="ct $ssh_cmd"
fi
tmux new-window -t "$TMUX_SESSION" -n "$selected" "$ssh_cmd"

# Attach to the tmux session
tmux attach-session -t "$TMUX_SESSION"
