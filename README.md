# my-assistant-cli
Docker image to run an assistant CLI to interact with a dockerized LLM. You can find a list of available LLMs [here](https://hub.docker.com/repositories/ilopezluna)

## Requirements
- Docker
- NVIDIA for GPU support 

## Usage

```bash
docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock ilopezluna/my-assistant-cli  "ilopezluna/thebloke_tinyllama-1_1b-chat-v1_0-gguf:tinyllama-1.1b-chat-v1.0.Q4_K_S.gguf_ollama_0.2.1" "What is the capital of Spain?"
```

You can use bash commands to enrich the prompt, for example:

```bash
docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock ilopezluna/my-assistant-cli:nodejs  "ilopezluna/ollama-llama3.1:0.2.8-8b" "I will provide you the contents of the files of a folder, your task is to describe what this folder is about. Here is the content: '$(for file in src/*; do [[ -f "$file" ]] && echo -e "\nContents of $file:" && cat "$file"; done)'"

Based on the code you provided, this folder is a Node.js application that uses the Ollama Container from Testcontainers and Axios to generate text completions.

Here's a high-level description of what it does:

1. It starts an Ollama container using the provided Docker image.
2. Once the container is running, it generates a completion by sending a POST request to the container's API with the prompt and optional images.
3. The response from the API is streamed back to stdout in JSON format.

The `main` function handles command-line arguments:

* It expects exactly 1 or 2 arguments: the Docker image name and the prompt. If no images are provided, it defaults to an empty array.
* It starts the container with the provided image and retrieves its endpoint URL.
* It generates a completion using the prompt and optional images.
* If any errors occur during this process, it prints the error message and exits.

In summary, this folder is a simple Node.js script that uses Ollama to generate text completions from command-line arguments.
```


