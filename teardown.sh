#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "${ROOT_DIR}"

if [[ "$#" != 1 || "$1" != --yes ]]; then
  printf 'Usage: %s --yes\n' "${0##*/}" >&2
  printf 'Permanently deletes this stack’s accounts, chats, search data, and .env (including OmniRoute credentials).\n' >&2
  exit 2
fi

if [[ ! -f .env ]]; then
  export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-open-webui-search}"
fi

# Compose interpolates required secrets even when it only needs to stop services.
FIRECRAWL_POSTGRES_PASSWORD=teardown \
FIRECRAWL_BULL_AUTH_KEY=teardown \
SEARXNG_SECRET=teardown \
docker compose -f docker-compose.yml down --volumes --remove-orphans --rmi local

remove_local_directory() {
  local directory="$1"

  if rm -rf -- "${directory}" 2>/dev/null; then
    return
  fi

  # Legacy SearXNG data and config may belong to the container user.
  if [[ ! -d "${directory}" || -L "${directory}" ]]; then
    printf 'Cannot clean up %s safely.\n' "${directory}" >&2
    return 1
  fi
  docker run --rm --network none --user 0:0 \
    --mount "type=bind,source=${ROOT_DIR}/${directory},target=/cleanup,bind-recursive=disabled" \
    --entrypoint /bin/sh nginx:alpine \
    -c 'rm -rf -- /cleanup/* /cleanup/.[!.]* /cleanup/..?*'
  rmdir -- "${directory}"
}

remove_local_directory data
remove_local_directory config/searxng
rm -f -- .env

printf 'Reset complete. Run ./setup.sh to start a fresh stack.\n'
