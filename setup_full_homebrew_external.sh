##/bin/bash

set -e

# === Налаштування шляху зовнішнього диска ===
EXTERNAL_DRIVE="/Volumes/DataSSD"
HOMEBREW_DIR="$EXTERNAL_DRIVE/homebrew"
APPLICATIONS_DIR="$EXTERNAL_DRIVE/Applications"

echo "🔎 Перевірка Xcode Command Line Tools..."

# === Перевірка наявності Xcode Command Line Tools ===
if ! xcode-select -p &>/dev/null; then
  echo "⚙️ Встановлення Xcode Command Line Tools..."
  xcode-select --install
  echo "⏳ Зачекай, доки завершиться встановлення, потім запусти скрипт ще раз."
  exit 1
else
  echo "✅ Xcode Command Line Tools вже встановлені."
fi


# === Клонування Homebrew, якщо потрібно ===
if [ ! -d "$HOMEBREW_DIR/.git" ]; then
  echo "🔧 Клонування Homebrew у $HOMEBREW_DIR..."
  git clone https://github.com/Homebrew/brew "$HOMEBREW_DIR"
else
  echo "✅ Homebrew вже клоновано."
fi

# === Підготовка директорій ===
echo "🔧 Створення директорій для Homebrew..."
#mkdir -p "$HOMEBREW_DIR" "$HOMEBREW_DIR/Cellar" "$HOMEBREW_DIR/tmp" "$HOMEBREW_DIR/cache" "$HOMEBREW_DIR/logs"
mkdir -p "$HOMEBREW_DIR/Cellar" "$HOMEBREW_DIR/tmp" "$HOMEBREW_DIR/cache" "$HOMEBREW_DIR/logs"
# mkdir -p "$APPLICATIONS_DIR"


# === Додавання налаштувань до .zshrc або .bash_profile ===
if [ -n "$ZSH_VERSION" ]; then
  PROFILE_FILE="$HOME/.zshrc"
else
  PROFILE_FILE="$HOME/.bash_profile"
fi

echo "🔧 Додаю Homebrew налаштування до $PROFILE_FILE..."

echo $PROFILE_FILE
echo $SHELL

if ! grep -q "Homebrew на зовнішньому диску" "$PROFILE_FILE"; then
  cat <<EOT >> "$PROFILE_FILE"

# --- Homebrew на зовнішньому диску ---
export HOMEBREW_PREFIX="$HOMEBREW_DIR"
export HOMEBREW_REPOSITORY="\$HOMEBREW_PREFIX"
export HOMEBREW_CELLAR="\$HOMEBREW_PREFIX/Cellar"
export HOMEBREW_CASK_OPTS="--appdir=$APPLICATIONS_DIR"
export HOMEBREW_TEMP="\$HOMEBREW_PREFIX/tmp"
export HOMEBREW_CACHE="\$HOMEBREW_PREFIX/cache"
export HOMEBREW_LOGS="\$HOMEBREW_PREFIX/logs"

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_MAKE_JOBS=4

export PATH="\$HOMEBREW_PREFIX/bin:\$HOMEBREW_PREFIX/sbin:\$PATH"
# --- Кінець блоку Homebrew ---
EOT
fi

# === Завантаження змін середовища ===
echo "🔁 Завантажую змінені змінні середовища..."
source "$PROFILE_FILE"

# === Перевірка готовності Homebrew ===
echo "🔍 Перевірка Homebrew..."
brew doctor || true

echo ""
echo "✅ Установка завершена! Тепер Homebrew працює через зовнішній диск."
echo "ℹ️ Якщо бачиш 'Your system is ready to brew.' — все успішно!"