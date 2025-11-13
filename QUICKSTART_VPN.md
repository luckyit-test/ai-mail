# Быстрый старт VPN Monitor

## Шаг 1: Установка зависимостей

```bash
pip install -r requirements.txt
```

## Шаг 2: Создание Telegram бота

1. Откройте Telegram и найдите [@BotFather](https://t.me/botfather)
2. Отправьте команду `/newbot`
3. Следуйте инструкциям и создайте бота
4. **Сохраните токен** (например: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

## Шаг 3: Получение Chat ID

1. Найдите бота [@userinfobot](https://t.me/userinfobot) в Telegram
2. Запустите бота командой `/start`
3. **Скопируйте ваш Chat ID** (например: `123456789`)

## Шаг 4: Настройка конфигурации

1. Создайте файл `.env` на основе `env.example`:
```bash
copy env.example .env
```

2. Откройте `.env` файл и укажите:
```env
TELEGRAM_BOT_TOKEN=ваш_токен_бота
TELEGRAM_CHAT_ID=ваш_chat_id
VPN_CHECK_INTERVAL=30
```

## Шаг 5: Запуск монитора

### Вариант 1: Ручной запуск (для тестирования)

```bash
python vpn_monitor.py
```

Или используйте скрипт:
```bash
start_vpn_monitor.bat
```

### Вариант 2: Установка как Windows Service (фоновый режим)

1. Запустите PowerShell **от имени администратора**
2. Выполните:
```powershell
.\install_vpn_service.ps1
```

3. Сервис будет установлен и запущен автоматически

## Управление сервисом

```powershell
# Запуск
Start-Service -Name VPNMonitorService

# Остановка
Stop-Service -Name VPNMonitorService

# Перезапуск
Restart-Service -Name VPNMonitorService

# Статус
Get-Service -Name VPNMonitorService
```

## Проверка работы

1. Подключите VPN AnyConnect
2. Проверьте Telegram - должно прийти уведомление "✅ VPN AnyConnect ПОДКЛЮЧЕНО"
3. Отключите VPN
4. Проверьте Telegram - должно прийти уведомление "❌ VPN AnyConnect ОТКЛЮЧЕНО"

## Логи

Логи сохраняются в файле `vpn_monitor.log`

Для просмотра логов:
```bash
type vpn_monitor.log
```

## Устранение неполадок

### Не приходят уведомления

1. Проверьте правильность `TELEGRAM_BOT_TOKEN` в `.env`
2. Проверьте правильность `TELEGRAM_CHAT_ID` в `.env`
3. Убедитесь, что бот запущен
4. Проверьте логи: `vpn_monitor.log`

### VPN не определяется

1. Убедитесь, что Cisco AnyConnect установлен
2. Проверьте имя VPN адаптера в `.env` (по умолчанию: "Cisco AnyConnect")
3. Проверьте логи для диагностики

### Сервис не запускается

1. Проверьте права администратора
2. Проверьте наличие `.env` файла
3. Проверьте логи сервиса: `vpn_monitor_service.error.log`

## Поддержка

Подробная документация: [VPN_MONITOR_README.md](VPN_MONITOR_README.md)

