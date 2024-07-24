import { OllamaContainer } from "@testcontainers/ollama";
import axios from "axios";

const startContainer = async (image: string): Promise<string> => {
    const ollama = await new OllamaContainer(image).withReuse().start();
    return ollama.getEndpoint();
}

const generate = async (url: string, prompt: string, images?: string[]) => {
    const tagsResponse = await axios.get(`${url}/api/tags`);
    const model = tagsResponse.data.models[0].name;
    const response = await axios.post(`${url}/api/generate`, {
        model, stream: true, prompt, images
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
    if (args.length != 2 && args.length != 3) {
        console.error('Usage: npm run start <docker image> <prompt> <optional: comma separated list of images in base64>');
        process.exit(1);
    }
    try {
        const url = await startContainer(args[0]);
        const images = args.length == 3 ? args[2].split(',') : undefined;
        await generate(url, args[1], images);
    } catch (error) {
        console.error(error);
    }
}

main();