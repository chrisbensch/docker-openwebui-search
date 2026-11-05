# Open WebUI with web search

A Docker Compose stack that connects Open WebUI to an OpenAI-compatible endpoint for chat and to Firecrawl for web search and page loading. Firecrawl uses SearXNG to find results. You can use OmniRoute or another OpenAI-compatible provider.

## Requirements

- Docker with the Compose v2 plugin and access to a running Docker daemon
- Bash and OpenSSL on the Docker host
- An OpenAI-compatible API base URL reachable from the Open WebUI container and an API key if your provider requires one

## Deploy

```sh
git clone https://github.com/chrisbensch/docker-openwebui-search.git
cd docker-openwebui-search
cp .env.example .env
chmod 600 .env
```

Edit `.env` and set `OMNIROUTE_BASE_URL` to your provider's OpenAI-compatible API base URL and `OMNIROUTE_API_KEY` to its API key, if required. Use these variable names for any provider. If your endpoint runs on the Docker host, use an address the container can reach. Inside the container, `localhost` refers to the container itself.

Leave the generated secret entries commented out and run the setup script.

```sh
./setup.sh
```

The script generates missing secrets, starts the stack, and checks that a search request sent from the Open WebUI container returns results through Firecrawl. Keep `.env` private.

Open `http://localhost:8080` in a browser on the Docker host. From another machine, use the Docker host's address on port `8080`. Select a model from your configured provider, enable **Web Search** in the chat, and ask a question that needs web results.

## Default ports

| Service | Host binding | Purpose |
| --- | --- | --- |
| Open WebUI | All interfaces, port `8080` | Browser interface |
| Firecrawl | `127.0.0.1:3002` | Search and page-loading API |
| SearXNG | `127.0.0.1:8889` | Search endpoint proxied by Nginx |
| Camofox | `127.0.0.1:9377` | Browser automation service |

Open WebUI stores accounts and chats under `data/open-webui/`. Redis, RabbitMQ, and PostgreSQL use Docker named volumes.

## Operate the stack

Run these commands from the repository directory. Inspect container status and recent logs if setup or search fails.

```sh
docker compose ps
docker compose logs --tail=100 open-webui firecrawl-api searxng searxng-core
```

Use these commands to stop and restart the containers while keeping data.

```sh
docker compose stop
docker compose start
```

### Reset the deployment

**This permanently deletes Open WebUI accounts and chats, the stack's Docker volumes, and `.env`, including the saved endpoint settings.**

```sh
./teardown.sh --yes
```
