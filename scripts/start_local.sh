#!/bin/bash
set -e

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

echo "Starting LovePilot..."

docker-compose up -d db

cd "$ROOT_DIR/apps/api"
if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi
source .venv/bin/activate
pip install -r requirements.txt >/dev/null 2>&1 || true
uvicorn app.main:app --host 0.0.0.0 --port 8000 > /tmp/lovepilot_api.log 2>&1 &
BACKEND_PID=$!

cd "$ROOT_DIR/apps/web"
if [ ! -d "node_modules" ]; then
  npm install
fi
npm run dev > /tmp/lovepilot_web.log 2>&1 &
FRONTEND_PID=$!

echo "Backend PID: $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
echo "Open http://localhost:3000"
