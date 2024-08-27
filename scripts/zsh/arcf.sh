#! usr/bin/env bash

# Check if a directory argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Check if the provided argument is a directory
if [ -d "$1" ]; then
  datetime=$(date +"%Y%m%d_%H%M%S")
  new_name="${1}_$datetime"
  mv "$1" "$new_name"
  echo "Directory renamed to '$new_name'"
else
  echo "Error: '$1' is not a directory."
  exit 1
fi
