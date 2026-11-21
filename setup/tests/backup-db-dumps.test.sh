#!/bin/bash
# Tests for bin/.local/bin/backup-db-dumps, run against a fake `docker`.
#   ~/dotfiles/setup/tests/backup-db-dumps.test.sh

set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
script="$here/../../bin/.local/bin/backup-db-dumps"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
fails=0

check() { # description, then a command that must succeed
  local what="$1"; shift
  if "$@"; then echo "ok   $what"; else echo "FAIL $what"; fails=$((fails + 1)); fi
}

# Fake docker: `ps` lists $FAKE_CONTAINERS; exec/cp print a line naming the
# container, or print partial output and fail when it is in $FAKE_FAIL.
mkdir -p "$work/bin"
cat > "$work/bin/docker" <<'EOF'
#!/bin/bash
case "$1" in
  ps) tr ' ' '\n' <<<"$FAKE_CONTAINERS"; exit 0 ;;
  exec) c="$2" ;;
  cp) c="${2%%:*}" ;;
  *) exit 2 ;;
esac
if [[ " $FAKE_FAIL " == *" $c "* ]]; then echo "partial"; exit 1; fi
echo "dump of $c: ${*:3}"
EOF
chmod +x "$work/bin/docker"

all="immich_postgres teslamate-database-1 teslamate-grafana-1 teslamate-mosquitto-1 homeassistant home_hq_private-web-abc123 kamal-proxy"
files="immich-postgres.sql.gz teslamate-postgres.sql.gz teslamate-grafana.tar.gz teslamate-mosquitto.tar.gz homeassistant-storage.tar.gz home-hq-production.sqlite3"

run() { # out-dir, containers, failing containers
  PATH="$work/bin:$PATH" BACKUP_DUMPS_DIR="$1" FAKE_CONTAINERS="$2" FAKE_FAIL="$3" \
    "$script" >"$1.log" 2>&1
}

# 1. Every app running (the beelink): one private, non-empty file per app.
out="$work/all"
run "$out" "$all" ""; status=$?
check "exits 0 when every dump works" [ "$status" = 0 ]
for f in $files; do check "writes $f" [ -s "$out/$f" ]; done
check "dump dir is private (700)" [ "$(stat -c %a "$out")" = 700 ]
check "dump files are private (600)" [ "$(stat -c %a "$out/immich-postgres.sql.gz")" = 600 ]
check "finds Home HQ's web container by prefix" \
  grep -q "home_hq_private-web-abc123" "$out/home-hq-production.sqlite3"

# 2. No apps running (framework13): nothing written, still a success.
out="$work/none"
run "$out" "kamal-proxy" ""; status=$?
check "exits 0 when nothing is running" [ "$status" = 0 ]
check "writes no dumps when nothing is running" [ -z "$(ls -A "$out")" ]
check "says what it skipped" grep -q "skip" "$out.log"

# 3. One dump fails: the others still run, the last good copy survives, the
#    run reports failure, and no half-written file is left behind.
out="$work/fail"
mkdir -p "$out" && echo "last night" > "$out/immich-postgres.sql.gz"
run "$out" "$all" "immich_postgres"; status=$?
check "exits non-zero when a dump fails" [ "$status" != 0 ]
check "keeps the last good dump when a new one fails" \
  grep -qx "last night" "$out/immich-postgres.sql.gz"
check "still writes the other dumps" [ -s "$out/teslamate-postgres.sql.gz" ]
check "leaves no temporary files" [ -z "$(find "$out" -name '*.tmp*')" ]
check "names the failed dump" grep -q "FAILED immich-postgres" "$out.log"

[ "$fails" = 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
