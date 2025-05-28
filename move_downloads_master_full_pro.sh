#!/bin/bash

# --- Налаштування ---
EXTERNAL_DISK_NAME="МійДиск"   # <-- замініть на вашу назву диска
NEW_DOWNLOADS_PATH="/Volumes/$EXTERNAL_DISK_NAME/Downloads"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/Downloads_Backups_$TIMESTAMP"
LOG_FILE="$HOME/move_downloads_$TIMESTAMP.log"

# --- Функція логування ---
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

# --- Початок роботи ---
log "🚀 Запуск перенесення папки Downloads."

# --- Перевірка диска ---
if [ ! -d "/Volumes/$EXTERNAL_DISK_NAME" ]; then
  log "❌ Зовнішній диск не знайдено: /Volumes/$EXTERNAL_DISK_NAME"
  exit 1
fi

# --- Створення папки на диску ---
mkdir -p "$NEW_DOWNLOADS_PATH"
log "✅ Створено папку $NEW_DOWNLOADS_PATH"

# --- Резервне копіювання старих завантажень ---
if [ -d "$HOME/Downloads" ]; then
  log "📦 Резервне копіювання ~/Downloads у $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
  mv "$HOME/Downloads" "$BACKUP_DIR/"
fi

# --- Створення символьного посилання ---
ln -s "$NEW_DOWNLOADS_PATH" "$HOME/Downloads"
log "🔗 Створено симлінк ~/Downloads -> $NEW_DOWNLOADS_PATH"

# --- Функція закриття браузера ---
close_browser() {
  local app_name="$1"
  if pgrep -x "$app_name" > /dev/null; then
    log "🚪 Закриваємо $app_name..."
    osascript -e "tell application \"$app_name\" to quit"
    sleep 2
  fi
}

# --- Закриття браузерів ---
close_browser "Safari"
close_browser "Google Chrome"
close_browser "Firefox"
close_browser "DuckDuckGo"

# --- Safari ---
read -p "🔵 Оновити шлях завантаження у Safari? (Y/n) " choice
if [[ "$choice" =~ ^[Yy]$ || -z "$choice" ]]; then
  defaults write com.apple.Safari DownloadsPath -string "$NEW_DOWNLOADS_PATH"
  log "✅ Оновлено Safari."
else
  log "⏩ Пропущено Safari."
fi

# --- Chrome (вибір профілів) ---
read -p "🟠 Оновити шлях завантаження у профілях Chrome? (Y/n) " choice
if [[ "$choice" =~ ^[Yy]$ || -z "$choice" ]]; then
  CHROME_PROFILES_DIR="$HOME/Library/Application Support/Google/Chrome"
  if [ -d "$CHROME_PROFILES_DIR" ]; then
    find "$CHROME_PROFILES_DIR" -type f -path "*/Preferences" | while read -r PREFS_FILE; do
      PROFILE_NAME=$(echo "$PREFS_FILE" | sed -E 's|.*/(.*)/Preferences|\1|')
      read -p "  🔧 Оновити профіль Chrome [$PROFILE_NAME]? (Y/n) " profile_choice
      if [[ "$profile_choice" =~ ^[Yy]$ || -z "$profile_choice" ]]; then
        cp "$PREFS_FILE" "${PREFS_FILE}.bak"
        /usr/bin/plutil -replace download.default_directory -string "$NEW_DOWNLOADS_PATH" "$PREFS_FILE" 2>/dev/null
        log "✅ Оновлено Chrome профіль [$PROFILE_NAME]"
      else
        log "⏩ Пропущено Chrome профіль [$PROFILE_NAME]"
      fi
    done
  else
    log "⚠️  Директорію Chrome не знайдено."
  fi
else
  log "⏩ Пропущено Chrome."
fi

# --- Firefox (вибір профілів) ---
read -p "🟣 Оновити шлях завантаження у профілях Firefox? (Y/n) " choice
if [[ "$choice" =~ ^[Yy]$ || -z "$choice" ]]; then
  FIREFOX_PROFILES_DIR="$HOME/Library/Application Support/Firefox/Profiles"
  if [ -d "$FIREFOX_PROFILES_DIR" ]; then
    find "$FIREFOX_PROFILES_DIR" -type d -name "*.default*" | while read -r PROFILE_DIR; do
      PROFILE_NAME=$(basename "$PROFILE_DIR")
      read -p "  🔧 Оновити профіль Firefox [$PROFILE_NAME]? (Y/n) " profile_choice
      if [[ "$profile_choice" =~ ^[Yy]$ || -z "$profile_choice" ]]; then
        USER_JS="$PROFILE_DIR/user.js"
        if [ -f "$USER_JS" ]; then
          cp "$USER_JS" "${USER_JS}.bak"
        fi
        {
          echo '// Налаштування завантажень'
          echo 'user_pref("browser.download.folderList", 2);'
          echo "user_pref(\"browser.download.dir\", \"$NEW_DOWNLOADS_PATH\");"
        } > "$USER_JS"
        log "✅ Оновлено Firefox профіль [$PROFILE_NAME]"
      else
        log "⏩ Пропущено Firefox профіль [$PROFILE_NAME]"
      fi
    done
  else
    log "⚠️  Директорію Firefox не знайдено."
  fi
else
  log "⏩ Пропущено Firefox."
fi

# --- DuckDuckGo ---
read -p "🟢 Оновити шлях завантаження у DuckDuckGo Browser? (Y/n) " choice
if [[ "$choice" =~ ^[Yy]$ || -z "$choice" ]]; then
  DDG_PREFS="$HOME/Library/Group Containers/8NW38VWS5BX.com.duckduckgo.macos.browser/Library/Application Support/DuckDuckGo Browser/Default/Preferences"
  if [ -f "$DDG_PREFS" ]; then
    cp "$DDG_PREFS" "${DDG_PREFS}.bak"
    /usr/bin/plutil -replace download.default_directory -string "$NEW_DOWNLOADS_PATH" "$DDG_PREFS" 2>/dev/null
    log "✅ Оновлено DuckDuckGo Browser."
  else
    log "⚠️  DuckDuckGo Browser не знайдено."
  fi
else
  log "⏩ Пропущено DuckDuckGo."
fi

# --- Підсумок ---
log "🎉 Перенесення папки Downloads завершено!"
log "📂 Нова папка завантажень: $NEW_DOWNLOADS_PATH"
log "📦 Бекапи розташовані у: $BACKUP_DIR"
echo "📜 Лог змін збережено у: $LOG_FILE"
echo ""