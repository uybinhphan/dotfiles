#!/bin/bash

# fsz — Fast folder size summary
# Usage: fsz

# Ensure consistent output
export LC_ALL=C

# Print sizes of all items in current directory, sorted by size
du -sh .[^.]* * 2>/dev/null | sort -h | awk '
BEGIN {
    printf "\033[1;34m%-10s\033[0m %-s\n", "SIZE", "NAME"
    printf "----------------------------\n"
}
{
    size=$1
    name=$2
    printf "\033[1;32m%-10s\033[0m %-s\n", size, name
}'
