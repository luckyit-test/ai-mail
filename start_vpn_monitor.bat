@echo off
REM Скрипт для запуска VPN Monitor
REM Убедитесь, что .env файл настроен с TELEGRAM_BOT_TOKEN и TELEGRAM_CHAT_ID

echo ========================================
echo   VPN Monitor Service
echo ========================================
echo.

REM Проверка наличия .env файла
if not exist .env (
    echo ОШИБКА: .env файл не найден!
    echo Создайте .env файл на основе env.example
    echo Укажите TELEGRAM_BOT_TOKEN и TELEGRAM_CHAT_ID
    pause
    exit /b 1
)

REM Запуск монитора
echo Запуск VPN Monitor...
echo Для остановки нажмите Ctrl+C
echo.

python vpn_monitor.py

pause

