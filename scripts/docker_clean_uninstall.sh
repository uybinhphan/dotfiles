#!/bin/bash

# Prompt the user for confirmation
read -p "Are you sure you want to remove Docker Desktop and all its data? [y/N] " -n 1 -r
echo    # (new line after user input)

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✅ User confirmed. Proceeding with Docker Desktop uninstallation."

    # Step 1: Check if Docker app exists
    echo "🔍 Checking if Docker.app is installed..."
    if [ -d "/Applications/Docker.app" ]; then
        echo "→ Docker app found. Proceeding with uninstall."
    else
        echo "⚠️ Docker.app not found. Continuing without it."
    fi

    # Step 2: Quit Docker Desktop if running
    echo "🛑 Attempting to quit Docker Desktop..."
    osascript -e 'quit app "Docker"'
    if [ $? -eq 0 ]; then
        echo "→ Docker Desktop has been quit."
    else
        echo "⚠️ Could not quit Docker Desktop. Continuing anyway."
    fi

    # Step 3: Remove main app and binaries
    echo "🗑️ Removing Docker application files..."
    rm -rf /Applications/Docker.app
    if [ $? -eq 0 ]; then
        echo "→ Docker application removed."
    else
        echo "⚠️ Could not remove /Applications/Docker.app. It may not exist or permission denied."
    fi

    echo "🗑️ Removing Docker binaries from /usr/local/bin..."

    rm -f /usr/local/bin/docker
    if [ $? -eq 0 ]; then
        echo "→ /usr/local/bin/docker removed."
    else
        echo "⚠️ Could not remove /usr/local/bin/docker. It may not exist or permission denied."
    fi

    rm -f /usr/local/bin/docker-compose
    if [ $? -eq 0 ]; then
        echo "→ /usr/local/bin/docker-compose removed."
    else
        echo "⚠️ Could not remove /usr/local/bin/docker-compose. It may not exist or permission denied."
    fi

    rm -f /usr/local/bin/docker-credential-*
    if [ $? -eq 0 ]; then
        echo "→ /usr/local/bin/docker-credential-* removed."
    else
        echo "⚠️ Could not remove /usr/local/bin/docker-credential-*. It may not exist or permission denied."
    fi

    # Step 4: Remove Docker data (user-specific)
    echo "🗑️ Removing user-specific Docker data and configurations..."

    rm -rf ~/.docker
    if [ $? -eq 0 ]; then
        echo "→ ~/.docker removed."
    else
        echo "⚠️ Could not remove ~/.docker. It may not exist or permission denied."
    fi

    rm -rf ~/Library/Containers/com.docker.docker
    if [ $? -eq 0 ]; then
        echo "→ ~/Library/Containers/com.docker.docker removed."
    else
        echo "⚠️ Could not remove ~/Library/Containers/com.docker.docker. It may not exist or permission denied."
    fi

    rm -rf ~/Library/Application\ Support/Docker\ Desktop
    if [ $? -eq 0 ]; then
        echo "→ ~/Library/Application Support/Docker Desktop removed."
    else
        echo "⚠️ Could not remove ~/Library/Application Support/Docker Desktop. It may not exist or permission denied."
    fi

    rm -rf ~/Library/Group\ Containers/group.com.docker
    if [ $? -eq 0 ]; then
        echo "→ ~/Library/Group Containers/group.com.docker removed."
    else
        echo "⚠️ Could not remove ~/Library/Group Containers/group.com.docker. It may not exist or permission denied."
    fi

    rm -rf ~/Library/Preferences/com.docker.docker.plist
    if [ $? -eq 0 ]; then
        echo "→ ~/Library/Preferences/com.docker.docker.plist removed."
    else
        echo "⚠️ Could not remove ~/Library/Preferences/com.docker.docker.plist. It may not exist or permission denied."
    fi

    rm -rf ~/Library/Logs/Docker\ Desktop
    if [ $? -eq 0 ]; then
        echo "→ ~/Library/Logs/Docker Desktop removed."
    else
        echo "⚠️ Could not remove ~/Library/Logs/Docker Desktop. It may not exist or permission denied."
    fi

    rm -rf ~/Library/Saved\ Application\ State/com.electron.docker-frontend.savedState
    if [ $? -eq 0 ]; then
        echo "→ ~/Library/Saved Application State/com.electron.docker-frontend.savedState removed."
    else
        echo "⚠️ Could not remove ~/Library/Saved Application State/com.electron.docker-frontend.savedState. It may not exist or permission denied."
    fi

    echo "✅ Docker Desktop and all related files have been removed."

else
    echo "🛑 Aborting. No changes were made."
    exit 1
fi
