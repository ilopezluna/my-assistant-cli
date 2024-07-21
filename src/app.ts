import { CloudflaredContainer } from "./cloudflared";
import { OllamaContainer } from "@testcontainers/ollama";

const init = async () => {
    console.log('Starting containers...');
    try {
        const ollama = await new OllamaContainer("ilopezluna/thebloke_tinyllama-1_1b-chat-v1_0-gguf:tinyllama-1.1b-chat-v1.0.Q4_K_S.gguf_ollama_0.2.1").start();
        const cloudflared = await new CloudflaredContainer(ollama.getPort()).start();
        console.log('Containers started');
        const url = ollama.getEndpoint();
        const public_url = await cloudflared.getUrl();
        console.log(`Ollama URL: ${url}`);
        console.log(`Cloudflared URL: ${public_url}`);
    } catch (error) {
        console.error(error);
    }
}

process.on('SIGINT', async () => {
    console.log('Exiting...');
    process.exit();
});
console.log('Press Ctrl+C to exit...');
init();
process.stdin.resume();