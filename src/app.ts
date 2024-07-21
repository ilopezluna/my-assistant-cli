import { OllamaContainer } from "@testcontainers/ollama";
import axios from "axios";

const startContainer = async (image: string): Promise<string> => {
    const ollama = await new OllamaContainer(image).withReuse().start();
    return ollama.getEndpoint();
}

const generate = async (url: string, prompt: string) => {
    const tagsResponse = await axios.get(`${url}/api/tags`);
    const model = tagsResponse.data.models[0].name;
    const response = await axios.post(`${url}/api/generate`, {
        model, stream: true, prompt
    }, {
        responseType: 'stream'
    });
    const stream = response.data;
    stream.on('data', data => {
        process.stdout.write(JSON.parse(data).response);
    });

    stream.on('end', () => {
        process.exit(0)
    });
};

const main = async () => {
    const args = process.argv.slice(2);
    if (args.length != 2) {
        console.error('Usage: npm run start <image> <prompt>');
        process.exit(1);
    }
    try {
        const url = await startContainer(args[0]);
        await generate(url, args[1]);
    } catch (error) {
        console.error(error);
    }
}

main();