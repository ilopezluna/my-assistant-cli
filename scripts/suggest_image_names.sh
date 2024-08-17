#!/bin/bash

if [ -z "$1" ]; then
  echo "Please provide a folder path as an argument."
  exit 1
fi

FOLDER_PATH=$1

if [ ! -d "$FOLDER_PATH" ]; then
  echo "The provided folder path does not exist."
  exit 1
fi

for IMAGE_FILE in "$FOLDER_PATH"/*.{jpg,jpeg,png}; do
  if [ ! -e "$IMAGE_FILE" ]; then
    continue
  fi

  FILE_SIZE=$(wc -c <"$IMAGE_FILE")

  # Exclude files larger than 50KB (51200 bytes)
  if [ "$FILE_SIZE" -gt 51200 ]; then
    echo "Skipping $IMAGE_FILE (size: $FILE_SIZE bytes)"
    continue
  fi

  echo "image file: $IMAGE_FILE"
  BASE64_IMAGE=$(base64 -i "$IMAGE_FILE")

  IMAGE_DESCRIPTION=$(docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock ilopezluna/my-assistant-cli "ilopezluna/ollama-moondream:0.2.8-1.8b" "describe the image" "$BASE64_IMAGE")
  SUGGEST_NAME_PROMPT=$(cat <<EOF
  Your task is to suggest a new filename for $IMAGE_FILE
  These are the rules:
  1- Your answer must contain only the new name
  2- Keep the extension
  3- The new name has to be based on the following description: $IMAGE_DESCRIPTION
  4- The new name must be in lowercase
  )

  SUGGESTED_NAME=$(docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock ilopezluna/my-assistant-cli "ilopezluna/ollama-llama3.1:0.2.8-8b" "$SUGGEST_NAME_PROMPT")

  echo ">>> suggested name: $SUGGESTED_NAME"
done
