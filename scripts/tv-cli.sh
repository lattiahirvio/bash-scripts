#!/bin/bash

# Define URL
url="https://raw.githubusercontent.com/luongz/iptv-jp/main/jp.m3u"
filtered_data=$(curl -s "$url" | awk 'NR > 9 || !/google\.com/')

# AWK the data, and then throw that in to fzf, from where 
echo "$filtered_data" | awk -F',' '
/#EXTINF/ {
    # Extract metadata
    metadata = $0
    # Extract the TVG-ID
    match(metadata, /tvg-id="([^"]+)"/, arr)
    tvg_id = arr[1]
    # Get the link on the next line
    getline
    link = $0
    # Output formatted for fzf
    print tvg_id ": " link
}' | fzf --preview 'echo {} | awk -F": " "{print \$2}"' --preview-window=up:10 --height=20 | \
awk -F": " '{print $2}' | xargs -I {} mpv {} >> /dev/null
