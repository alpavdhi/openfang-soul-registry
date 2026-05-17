#!/usr/bin/env bash
# cli.sh — Универсальный интерфейс для Soul Registry Pipeline.
# Использует toml_apply_v3.py для атомарного деплоя агентов.

# Настройка окружения
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PYTHON_SCRIPT="${SCRIPT_DIR}/toml_apply_v3.py"
MANIFEST_DIR="${SCRIPT_DIR}/manifests"

# Функция помощи
show_help() {
    echo "========================================================="
    echo "🤖 Soul Registry CLI Tool (v3.0.0)"
    echo "========================================================="
    echo "Универсальный интерфейс для управления жизненным циклом агентов."
    echo ""
    echo "Использование:"
    echo "  $0 [ОПЦИИ] [АГЕНТ_ИМЯ]"
    echo ""
    echo "Опции:"
    echo "  --dry-run      Просмотр изменений без применения (Рекомендуется). "
    echo "  --live         Фактическое применение изменений (Опасно!)."
    echo "  --agent <name>  Обработать только указанного агента (например, architect)."
    echo "  --help         Показать это сообщение."
    echo ""
    echo "Пример:"
    echo "  $0 --dry-run           Проверить, что произойдет при деплое всех агентов."
    echo "  $0 --live --agent devops-lead # Применить изменения только к devops-lead."
    echo ""
    exit 0
}

# Обработка флагов и аргументов
DRY_RUN=true
TARGET_AGENT=""

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --live)
            DRY_RUN=false
            shift
            ;;
        --agent)
            if [ -n "$2" ]; then
                TARGET_AGENT="$2"
                shift 2
            else
                echo "Ошибка: Флаг --agent требует имя агента."
                show_help
            fi
            ;;
        *)
            # Если аргумент не распознан, предполагаем, что это имя агента
            if [ -z "$TARGET_AGENT" ]; then
                 TARGET_AGENT="$1"
                 shift
            else
                 echo "Предупреждение: Игнорирован неизвестный аргумент: $1"
                 shift
            fi
            ;;
    esac
done

# Проверка обязательных условий
if [ -z "$TARGET_AGENT" ]; then
    echo "❌ Ошибка: Необходимо указать имя агента или использовать флаг --dry-run."
    show_help
fi

# Вызов основного пайплайна
echo "🚀 Запуск Soul Registry Pipeline..."
echo "========================================================="
echo "  Целевой агент: $TARGET_AGENT"
echo "  Режим: $( [[ "$DRY_RUN" == "true" ]] && echo "DRY-RUN (Только просмотр)"; echo "LIVE (Фактивное применение)")"
echo "========================================================="

# Передача всех параметров в основной скрипт
python3 "$PYTHON_SCRIPT" "$MANIFEST_DIR" --dry-run "$DRY_RUN" "$TARGET_AGENT"

# Обработка выхода
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo ""
    echo "🚨 Скрипт завершился с ошибкой ($EXIT_CODE). Проверьте логи выше."
fi

