#!/usr/bin/env bash
#
# meshnet-monitor.sh  —  v2 (with quick health guard)
#
# Runs forever in 15-minute loops:
#   1. Checks Meshnet reachability (ping or port).
#   2. Peeks at CPU & RAM; if either crosses a red line
#      ⇒ desktop warning  ⇒ exits (no more loops).
#
# Needs: libnotify-bin  +  netcat-openbsd  +  bc  (all standard on Debian)

############### USER SETTINGS ##############################################
MESH_IP=""   # Meshnet peer to test
PORT="22"                  # leave blank to use ping
CHK_TIMEOUT=15             # seconds to try reachability
CHK_INTERVAL=3             # seconds between attempts inside timeout
SLEEP_BETWEEN=900          # 15 min  (900 s) between checks

# “Crash-risk” thresholds
MAX_LOAD_FACTOR=1          # warn if load1  >  CORES * MAX_LOAD_FACTOR
MAX_RAM_PCT=90             # warn if used RAM ≥ this percent
###########################################################################

notify() { notify-send -u normal "Meshnet / Health Monitor" "$1"; }

while true; do
  ################ Meshnet reachability ################
  #notify "Checking Meshnet connectivity…"
  elapsed=0; ok=0
  while (( elapsed < CHK_TIMEOUT )); do
    if [[ -z "$PORT" ]]; then
      ping -c1 -W1 "$MESH_IP"   >/dev/null 2>&1 && { ok=1; break; }
    else
      nc   -z   "$MESH_IP" "$PORT" >/dev/null 2>&1 && { ok=1; break; }
    fi
    sleep "$CHK_INTERVAL"
    (( elapsed += CHK_INTERVAL ))
  done
  #notify "Meshnet $( [[ $ok -eq 1 ]] && echo '🟢 reachable' || echo '🔴 unreachable ./chatgpt-run.sh';/tmp/chatgpt-run.sh )."
if [[ $ok -eq 1 ]]; then
  gnome-terminal -- bash -c 'ssh pi@; exec bash'
  exit 0
fi
  
################ Quick health guard ################
  CORES=$(nproc)
  LOAD1=$(awk '{print $1}' /proc/loadavg)
  LOAD_LIMIT=$(echo "$CORES * $MAX_LOAD_FACTOR" | bc)
  USED_RAM_PCT=$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')

  if (( $(echo "$LOAD1 > $LOAD_LIMIT" | bc -l) )) || (( USED_RAM_PCT >= MAX_RAM_PCT )); then
      notify "⚠️ High load (Load=$LOAD1, RAM=${USED_RAM_PCT}%). Close apps or reboot."
      echo "ok"
      echo `date +%c` >> /home//share-to-chatgpt.txt 
      echo $LOAD1 >> /home//share-to-chatgpt.txt
      exit 0
  fi

  ################ Wait for next cycle ################
  sleep "$SLEEP_BETWEEN"
done

