#!/usr/bin/env bash
# Claude Code — desktop notification hook
# Fires on: Notification (needs input), Stop (finished)

INPUT="$(cat)"
EVENT=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('hook_event_name',''))" 2>/dev/null)
MSG=$(echo "$INPUT"   | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('message') or d.get('last_assistant_message','')[:80])" 2>/dev/null)
CWD=$(echo "$INPUT"   | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('cwd',''))" 2>/dev/null)
DIR=$(basename "$CWD")

case "$EVENT" in
  Notification)
    osascript -e "display notification \"${MSG:-需要你的输入}\" with title \"Claude Code — ${DIR}\" subtitle \"等待确认\" sound name \"Ping\""
    ;;
  Stop)
    osascript -e "display notification \"${MSG:-任务已完成}\" with title \"Claude Code — ${DIR}\" subtitle \"已结束\" sound name \"Glass\""
    ;;
esac
