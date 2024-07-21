import {
    AbstractStartedContainer,
    GenericContainer, StartedTestContainer, TestContainers, Wait,
} from "testcontainers";
import { Readable } from "node:stream";

//TODO how to avoid global variable?
let publicUrl: string = '';

function findUrl(readable: Readable) {
    let found: boolean = false;
    readable.on('data', (chunk) => {
        const data = chunk.toString();
        if (data.includes('Your quick Tunnel has been created')) {
            found = true;
        } else if (found) {
            const urlMatch = data.match(/https?:\/\/[^\s|]+/);
            publicUrl = urlMatch ? urlMatch[0] : null;
            readable.destroy();
        }
    });
}

export class CloudflaredContainer extends GenericContainer {

    private readonly port: number;

    constructor(port: number) {
        super("cloudflare/cloudflared:2024.5.0");
        this.port = port;
        this.withExposedPorts(port)
            .withCommand(["tunnel", "--url", `http://host.testcontainers.internal:${port}`])
            .withWaitStrategy(Wait.forLogMessage("Registered tunnel connection"))
            .withLogConsumer((output) => findUrl(output))
        ;
    }

    public override async start(): Promise<StartedCloudflaredContainer> {
        await TestContainers.exposeHostPorts(this.port);
        return new StartedCloudflaredContainer(await super.start());
    }
}

export class StartedCloudflaredContainer extends AbstractStartedContainer {
    constructor(startedTestContainer: StartedTestContainer) {
        super(startedTestContainer);
    }

    public async getUrl(): Promise<string> {
        return publicUrl;
    }
}