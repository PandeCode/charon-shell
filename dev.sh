#!/usr/bin/env bash
WATCH_DIR=${1:-.} # Directory to watch; defaults to current directory
echo "Watching directory: $WATCH_DIR"
# Debounce delay in seconds
DEBOUNCE_DELAY=1
last_run=0

# Function to transpile a Fennel file to Lua
transpile_fennel() {
    local fennel_file=$1
    # Extract the relative path from WATCH_DIR
    local rel_path=${fennel_file#"$WATCH_DIR"/}

    # Ensure path starts with fennel/
    if [[ ! "$rel_path" =~ ^fennel/ ]]; then
        return
    fi

    # Create the equivalent path in the lua directory
    local lua_path="lua/${rel_path#fennel/}"
    lua_path="${lua_path%.fnl}.lua"

    # Create the directory if it doesn't exist
    mkdir -p "$(dirname "$lua_path")"

    echo "Transpiling $fennel_file to $lua_path"
    fennel --compile "$fennel_file" >"$lua_path"

    if [ $? -eq 0 ]; then
        echo "Successfully transpiled to $lua_path"
    else
        echo "Error transpiling $fennel_file"
    fi
}

# Monitor the directory recursively for close_write, create, and delete events.
inotifywait -m -r -e close_write,create,delete --format '%w%f' "$WATCH_DIR" | while read FILE; do
    if [[ "$FILE" =~ \.(lua|glade|scss|fnl)$ ]]; then
        now=$(date +%s)
        # Check if the last command was executed within the debounce period
        if ((now - last_run < DEBOUNCE_DELAY)); then
            continue
        fi
        last_run=$now
        echo "Change detected in: $FILE"

        if [ -f /tmp/clear-log ]; then
            clear
            rm /tmp/clear-log
        fi
        # Check if it's a Fennel file and process it
        if [[ "$FILE" =~ \.fnl$ ]]; then
            echo fnl
            transpile_fennel "$FILE"
            return
        fi

        killall -9 lua
        if [ -f /tmp/debug ]; then
            GTK_DEBUG=interactive lua init.lua &
            rm /tmp/debug
        else
            lua init.lua &
        fi
    fi
done
