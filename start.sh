#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/backend"
LOG_DIR="$SCRIPT_DIR/.logs"
mkdir -p "$LOG_DIR"

# ── Cleanup on exit ──────────────────────────────────────────────────────────
cleanup() {
  echo ""
  echo "Shutting down..."
  [[ -n "$BACKEND_PID" ]] && kill "$BACKEND_PID" 2>/dev/null && echo "  Backend stopped"
  echo "  Run ./stop.sh to stop the database"
}
trap cleanup EXIT INT TERM

# ── 1. Database ───────────────────────────────────────────────────────────────
echo "🗄  Starting database..."
docker compose -f "$SCRIPT_DIR/docker-compose.yml" up -d

# Wait for Postgres to accept connections
MAX_WAIT=30
WAITED=0
until docker compose -f "$SCRIPT_DIR/docker-compose.yml" exec -T db \
      pg_isready -U chefs -d chefsquest -q 2>/dev/null; do
  sleep 1
  WAITED=$((WAITED + 1))
  if [[ $WAITED -ge $MAX_WAIT ]]; then
    echo "❌ Database did not become ready in ${MAX_WAIT}s"
    exit 1
  fi
done
echo "🗄  Database ready       → localhost:5433"

# ── 2. Run migrations ────────────────────────────────────────────────────────
echo "🔄  Running migrations..."
cd "$BACKEND_DIR"
PYTHONPATH="$SCRIPT_DIR" venv/bin/alembic upgrade head > "$LOG_DIR/alembic.log" 2>&1
echo "✅  Migrations up to date"

# ── 3. Backend ────────────────────────────────────────────────────────────────
echo "🚀  Starting backend..."
PYTHONPATH="$SCRIPT_DIR" venv/bin/uvicorn backend.main:app \
  --host 0.0.0.0 --port 8000 --reload \
  > "$LOG_DIR/backend.log" 2>&1 &
BACKEND_PID=$!

# Wait for backend to respond
MAX_WAIT=15
WAITED=0
until curl -sf http://localhost:8000/health > /dev/null 2>&1; do
  sleep 1
  WAITED=$((WAITED + 1))
  if [[ $WAITED -ge $MAX_WAIT ]]; then
    echo "❌ Backend did not start in ${MAX_WAIT}s — check .logs/backend.log"
    exit 1
  fi
done

# ── Ready ─────────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║         Chefs Quest — Dev Server Ready       ║"
echo "╠══════════════════════════════════════════════╣"
echo "║  🗄  Database    → localhost:5433             ║"
echo "║  🚀  Backend     → http://localhost:8000      ║"
echo "║  🌐  Web admin   → http://localhost:8000/admin║"
echo "║  📖  API docs    → http://localhost:8000/docs ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "Logs: .logs/backend.log"
echo "Press Ctrl+C to stop the backend (DB keeps running)"
echo ""

# Keep running so Ctrl+C triggers cleanup
wait "$BACKEND_PID"
