#!/bin/bash

LOG_FILE="access.log"
REPORT_FILE="report.txt"

# Проверка, существует ли файл логов
if [ ! -f "$LOG_FILE" ]; then
    echo "Файл логов '$LOG_FILE' не найден!"
    exit 1
fi

echo "Анализ файла логов: $LOG_FILE"
echo "--------------------"


# 2. Подсчитать общее количество запросов.
total_requests=$(wc -l < "$LOG_FILE")
echo "Общее количество запросов: $total_requests"

# 3. Подсчитать количество уникальных IP-адресов. Строго с использованием awk.
# awk будет использовать ассоциативный массив для подсчета уникальных IP (первое поле $1)
# length(array) вернет количество ключей в массиве.
unique_ips=$(awk '{ips[$1]++} END {print length(ips)}' "$LOG_FILE")
echo "Количество уникальных IP-адресов: $unique_ips"

# 4. Подсчитать количество запросов по методам (GET, POST и т.д.). Строго с использованием awk.
# Метод запроса находится в 6-м поле (e.g., "GET). Удаляем кавычку с помощью gsub.
# Затем считаем в ассоциативном массиве.
echo "Количество запросов по методам:"
requests_per_method=$(awk '{
    method=$6;
    gsub(/^"/, "", method); # Удаляем начальную кавычку, если есть
    methods[method]++;
} END {
    for (m in methods) {
        print "  " m ": " methods[m];
    }
}' "$LOG_FILE")
echo "$requests_per_method"

# 5. Найти самый популярный URL. Строго с использованием awk.
# URL находится в 7-м поле. По умолчанию, awk использует один или несколько пробельных символов (пробелы, табы) в качестве разделителя полей.
# Считаем URL'ы, затем находим тот, у которого максимальное количество.
most_popular_url_info=$(awk '{
    urls[$7]++;
} END {
    max_count = 0;
    popular_url = "";
    for (url in urls) {
        if (urls[url] > max_count) {
            max_count = urls[url];
            popular_url = url;
        }
    }
    print popular_url " (запросов: " max_count ")";
}' "$LOG_FILE")
echo "Самый популярный URL: $most_popular_url_info"

# 6. Создать отчет в виде текстового файла.
echo "Генерация отчета в $REPORT_FILE..."

# Перезаписываем или создаем файл отчета
> "$REPORT_FILE"

echo "Отчет по анализу логов файла: $LOG_FILE" >> "$REPORT_FILE"
echo "Дата генерации: $(date)" >> "$REPORT_FILE"
echo "=======================================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "1. Общее количество запросов: $total_requests" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "2. Количество уникальных IP-адресов: $unique_ips" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "3. Количество запросов по методам:" >> "$REPORT_FILE"
echo "$requests_per_method" >> "$REPORT_FILE" # Уже содержит переносы строк
echo "" >> "$REPORT_FILE"

echo "4. Самый популярный URL: $most_popular_url_info" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "---------------------------------"
echo "Отчет успешно создан: $REPORT_FILE"