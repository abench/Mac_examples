ROLLBACK_SCRIPT="$HOME/rollback_move_downloads_$TIMESTAMP.sh"

cat <<EOL > "$ROLLBACK_SCRIPT"
#!/bin/bash

echo "⏪ Відновлення стану до перенесення..."
# Відновлення папки Downloads
rm -rf ~/Downloads
mv "$BACKUP_DIR/Downloads" ~/Downloads

# Відновлення файлів браузерів
find "$BACKUP_DIR" -type f -name "*.bak" | while read -r BACKUP_FILE; do
  ORIGINAL_FILE="\${BACKUP_FILE%.bak}"
  echo "🔄 Відновлення \$ORIGINAL_FILE"
  cp "\$BACKUP_FILE" "\$ORIGINAL_FILE"
done

echo "✅ Відновлення завершено."
EOL

chmod +x "$ROLLBACK_SCRIPT"
log "🔄 Створено скрипт для відновлення: $ROLLBACK_SCRIPT"