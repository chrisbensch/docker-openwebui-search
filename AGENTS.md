# Repository instructions

- Keep local `.env` files, credentials, and runtime data under `data/` out of version control. Use placeholders in `.env.example` and leave generated secret entries commented so `setup.sh` can populate them.
- When changing Compose variables, service ports, or deployment steps, update the affected instructions in `README.md` and the relevant entries in `.env.example`.
- Validate Compose changes with `docker compose config --quiet`, supplying test values for required variables if needed. Use `bash -n setup.sh` and `bash -n teardown.sh` to check shell script changes.
- Treat `./teardown.sh --yes` as a destructive reset. Use an isolated test deployment when testing teardown behavior.
