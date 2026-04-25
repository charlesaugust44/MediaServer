#!/bin/bash

FOLDERS=(
    "media/downloads"
    "media/movies"
    "media/music"
    "media/tv"
)

for folder in "${FOLDERS[@]}"; do
    if [ ! -d "$folder" ]; then
        mkdir -p "$folder"
        echo "Created: $folder"
    else
        echo "Already exists: $folder"
    fi
done

echo "Done. Media folder structure is ready."