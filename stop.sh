#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Stopping Chefs Quest dev environment..."

# Stop backend if running
BACKEND_PID=$(lsof -ti:8000 2>/dev/null || true)
if [[ -n "$BACKEND_PID" ]]; then
  kill "$BACKEND_PID" 2>/dev/null && echo "🛑  Backend stopped"
fi

# Stop database
docker compose -f "$SCRIPT_DIR/docker-compose.yml" down
echo "🗄  Database stopped"
echo "Done."
