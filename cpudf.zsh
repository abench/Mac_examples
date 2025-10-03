#!/bin/zsh

# Скрипт: cpudf
# Призначення: копіювання з UDF-дисків без збереження "чужих" прав
# Використання: cpudf /шлях/до/цілі /шлях/до/джерела

# Перевірка кількості аргументів
if [ "$#" -ne 2 ]; then
  echo "Використання: cpudf dest_dir source_dir"
  exit 1
fi

dest_dir="$1"
source_dir="$2"

# Перевірка, що джерело існує
if [ ! -e "$source_dir" ]; then
  echo "Помилка: джерело $source_dir не існує"
  exit 1
fi

# Створюємо цільову директорію, якщо її немає
mkdir -p "$dest_dir"

# Виконуємо копіювання
rsync -avh --progress --partial --no-perms --no-owner --no-group \
  "$source_dir" "$dest_dir"

# Статус завершення
if [ $? -eq 0 ]; then
  echo "✅ Копіювання завершено успішно"
else
  echo "⚠️ Виникла помилка під час копіювання"
fi