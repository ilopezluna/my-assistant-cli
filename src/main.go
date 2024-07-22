package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"github.com/testcontainers/testcontainers-go"
	tcollama "github.com/testcontainers/testcontainers-go/modules/ollama"
	"io"
	"log"
	"net/http"
	"os"
)

type TagResponse struct {
	Models []struct {
		Name string `json:"name"`
	} `json:"models"`
}

type GenerateRequest struct {
	Model  string `json:"model"`
	Stream bool   `json:"stream"`
	Prompt string `json:"prompt"`
}

func startContainer(image string) (string, error) {
	ctx := context.Background()

	ollamaContainer, err := tcollama.Run(ctx, image, testcontainers.CustomizeRequestOption(func(req *testcontainers.GenericContainerRequest) error {
		req.Name = "my-ollama"
		req.Reuse = true
		return nil
	}))
	if err != nil {
		log.Fatalf("failed to start container: %s", err)
		return "", err
	}
	return ollamaContainer.Endpoint(ctx, "http")
}

func generate(url string, prompt string) error {
	tagsResp, err := http.Get(fmt.Sprintf("%s/api/tags", url))
	if err != nil {
		return err
	}
	defer func(Body io.ReadCloser) {
		_ = Body.Close()
	}(tagsResp.Body)

	var tags TagResponse
	if err := json.NewDecoder(tagsResp.Body).Decode(&tags); err != nil {
		return err
	}

	model := tags.Models[0].Name
	genReq := GenerateRequest{
		Model:  model,
		Stream: true,
		Prompt: prompt,
	}

	reqBody, err := json.Marshal(genReq)
	if err != nil {
		return err
	}

	resp, err := http.Post(fmt.Sprintf("%s/api/generate", url), "application/json", bytes.NewBuffer(reqBody))
	if err != nil {
		return err
	}
	defer func(Body io.ReadCloser) {
		_ = Body.Close()
	}(resp.Body)

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("failed to generate: %s", resp.Status)
	}

	decoder := json.NewDecoder(resp.Body)
	for {
		var data map[string]interface{}
		if err := decoder.Decode(&data); err == io.EOF {
			break
		} else if err != nil {
			return err
		}
		fmt.Print(data["response"])
	}

	return nil
}

func main() {
	if len(os.Args) != 3 {
		fmt.Println("Usage: ./app <image> <prompt>")
		os.Exit(1)
	}

	image := os.Args[1]
	prompt := os.Args[2]

	url, err := startContainer(image)
	if err != nil {
		fmt.Println("Error starting container:", err)
		os.Exit(1)
	}

	if err := generate(url, prompt); err != nil {
		fmt.Println("Error generating response:", err)
		os.Exit(1)
	}
}
