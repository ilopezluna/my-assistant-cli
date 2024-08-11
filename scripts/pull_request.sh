#!/bin/bash

usage() {
    echo "Usage: $0 <path-to-git-repo>"
}

if [ -z "$1" ]; then
    echo "Error: No path to the Git repository provided."
    usage
    exit 1
fi

REPO_PATH=$1

if [ ! -d "$REPO_PATH" ]; then
    echo "Error: Provided path is not a directory."
    usage
    exit 1
fi

if [ ! -d "$REPO_PATH/.git" ]; then
    echo "Error: Provided directory is not a Git repository."
    usage
    exit 1
fi

cd "$REPO_PATH" || exit


BRANCH_NAME=$(git symbolic-ref --short HEAD)
GIT_DIFF=$(git diff main.."$BRANCH_NAME")

GIT_DIFF_EXPLANATION_PROMPT=$(cat <<EOF
  Given the following git diff output, write a detailed explanation of the changes made in the code.

  =====
  $GIT_DIFF
  =====

  Your task is to provide a very detailed explanation of the changes made in the code. You need to answer the following questions:
  1- What is the main purpose of the changes?
  2- What are the differences between the original and the new code?
)

GIT_DIFF_EXPLANATION=$(docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock ilopezluna/my-assistant-cli "ilopezluna/ollama-llama3.1:0.3.4-8b" "$GIT_DIFF_EXPLANATION_PROMPT")
echo ">>> Changes: $GIT_DIFF_EXPLANATION"

PR_TITLE_PROMPT=$(cat <<EOF
  Given the following explanation of the changes made in the code, write a title for a pull request that best describes the changes:
  =====
  $GIT_DIFF_EXPLANATION
  =====
  Your task is to provide a title for a pull request that best describes the changes made in the code. Only provide the title and nothing else.
)
PR_TITLE=$(docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock ilopezluna/my-assistant-cli "ilopezluna/ollama-llama3.1:0.3.4-8b" "$PR_TITLE_PROMPT")
echo ">>> PR Title: $PR_TITLE"

PR_DESCRIPTION_PROMPT=$(cat <<EOF
  Given the following explanation of the changes made in the code, and the title of the pull request, write a pull request description that best describes the changes:
  =====
  $GIT_DIFF_EXPLANATION
  =====
  $PR_TITLE
  =====
  Your task is to provide a description for a pull request that best describes the changes made in the code. Only provide the description and nothing else.
)
PR_DESCRIPTION=$(docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock ilopezluna/my-assistant-cli "ilopezluna/ollama-llama3.1:0.3.4-8b" "$PR_DESCRIPTION_PROMPT")
echo ">>> PR Description: $PR_DESCRIPTION"


