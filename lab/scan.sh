#!/usr/bin/env bash
# Dùng: SONAR_TOKEN=xxx ./lab/scan.sh
# Bản Community không quét theo nhánh -> mỗi nhánh = 1 project riêng.
set -euo pipefail
: "${SONAR_TOKEN:?Hãy export SONAR_TOKEN (SonarQube: My Account > Security)}"
cd "$(git rev-parse --show-toplevel)"

BRANCH=$(git rev-parse --abbrev-ref HEAD)
KEY="lab-$(echo "$BRANCH" | tr '/' '-')"
HOST="${SONAR_HOST:-http://localhost:9000}"
OUT="reports/report-${KEY}.md"

docker compose -f lab/docker-compose.yml run --rm scanner \
  -Dsonar.projectKey="$KEY" -Dsonar.projectName="$KEY"

echo "Đợi SonarQube xử lý kết quả..."; sleep 15

{
  echo "# Báo cáo quét - nhánh \`$BRANCH\`"
  echo
  echo "## Issues (Bug / Vulnerability / Code smell)"
  echo "| Mức độ | Loại | Quy tắc | Vị trí | Mô tả |"
  echo "|---|---|---|---|---|"
  curl -s -u "$SONAR_TOKEN:" \
    "$HOST/api/issues/search?componentKeys=$KEY&ps=500&resolved=false" |
  jq -r '.issues[] |
    "| \(.severity) | \(.type) | \(.rule) | \(.component | split(":")[1]):\(.line // "-") | \(.message) |"'
  echo
  echo "## Security Hotspots"
  echo "| Xác suất | Nhóm | Vị trí | Mô tả |"
  echo "|---|---|---|---|"
  curl -s -u "$SONAR_TOKEN:" \
    "$HOST/api/hotspots/search?projectKey=$KEY&ps=500" |
  jq -r '.hotspots[] |
    "| \(.vulnerabilityProbability) | \(.securityCategory) | \(.component | split(":")[1]):\(.line // "-") | \(.message) |"'
} > "$OUT"

echo "Đã ghi: $OUT"
echo "Dashboard: $HOST/dashboard?id=$KEY"
