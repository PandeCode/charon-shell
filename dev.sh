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
            # G_DEBUG=fatal-criticals	Makes critical warnings crash the program immediately. Good for catching issues fast.
            # G_SLICE=debug-blocks	Disables GLib's memory optimizations to make Valgrind/memory debugging way easier.
            # GTK_DEBUG=updates	Visualizes all redraws and repaints. Good for hunting rendering bugs.
            # GTK_DEBUG=layout	Dumps layout allocations and widget sizes to the console. Great for UI sizing issues.
            # GTK_INSPECTOR_DISPLAY=all	Shows everything in GTK Inspector, even stuff normally hidden.
            # GOBJECT_DEBUG=signal-handlers	Logs when signal handlers are connected/disconnected. Useful for checking signal leaks.
            # GDK_DEBUG=events	Prints every low-level input event (key presses, mouse moves, etc.).
            # GDK_DEBUG=rendering	Prints when GDK draws stuff to the screen (compositing, frame drawing).
            # GDK_BACKEND=x11/wayland	Forces a specific backend if you want to debug platform-specific bugs.
            # G_MESSAGES_DEBUG=all

            GOBJECT_DEBUG=instance-count G_DEBUG=fatal-criticals G_SLICE=debug-blocks GTK_DEBUG=interactive lua init.lua &
            rm /tmp/debug
        else
            lua init.lua &
        fi
    fi
done
