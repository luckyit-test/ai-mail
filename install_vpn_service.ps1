# Скрипт для установки VPN Monitor как Windows Service
# Требуется права администратора

param(
    [Parameter(Mandatory=$false)]
    [string]$ServiceName = "VPNMonitorService",
    
    [Parameter(Mandatory=$false)]
    [string]$DisplayName = "VPN Monitor Service",
    
    [Parameter(Mandatory=$false)]
    [string]$Description = "Мониторинг подключения Cisco VPN AnyConnect и отправка уведомлений в Telegram"
)

# Проверка прав администратора
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ОШИБКА: Скрипт требует прав администратора!" -ForegroundColor Red
    Write-Host "Запустите PowerShell от имени администратора" -ForegroundColor Yellow
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Установка VPN Monitor Service" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Проверка наличия Python
$pythonPath = Get-Command python -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source

if (-not $pythonPath) {
    Write-Host "ОШИБКА: Python не найден!" -ForegroundColor Red
    Write-Host "Установите Python и добавьте его в PATH" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Python найден: $pythonPath" -ForegroundColor Green

# Проверка наличия pip
$pipPath = Get-Command pip -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source

if (-not $pipPath) {
    Write-Host "ОШИБКА: pip не найден!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ pip найден: $pipPath" -ForegroundColor Green
Write-Host ""

# Установка зависимостей
Write-Host "Установка зависимостей..." -ForegroundColor Yellow
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

pip install -r requirements.txt
if ($LASTEXITCODE -ne 0) {
    Write-Host "ОШИБКА: Не удалось установить зависимости!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Зависимости установлены" -ForegroundColor Green
Write-Host ""

# Проверка наличия .env файла
if (-not (Test-Path ".env")) {
    Write-Host "⚠ Предупреждение: .env файл не найден" -ForegroundColor Yellow
    Write-Host "Создайте .env файл на основе env.example" -ForegroundColor Yellow
    Write-Host "Обязательно укажите TELEGRAM_BOT_TOKEN и TELEGRAM_CHAT_ID" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Продолжить установку? (y/n)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 0
    }
}

# Проверка наличия NSSM (Non-Sucking Service Manager)
$nssmPath = Get-Command nssm -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source

if (-not $nssmPath) {
    Write-Host "⚠ NSSM не найден. Установка через Chocolatey..." -ForegroundColor Yellow
    
    # Проверка наличия Chocolatey
    $chocoPath = Get-Command choco -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
    
    if ($chocoPath) {
        Write-Host "Установка NSSM через Chocolatey..." -ForegroundColor Yellow
        choco install nssm -y
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ОШИБКА: Не удалось установить NSSM!" -ForegroundColor Red
            Write-Host "Установите NSSM вручную: https://nssm.cc/download" -ForegroundColor Yellow
            exit 1
        }
        $nssmPath = "C:\ProgramData\chocolatey\bin\nssm.exe"
    } else {
        Write-Host "Chocolatey не найден. Установите NSSM вручную:" -ForegroundColor Yellow
        Write-Host "1. Скачайте NSSM: https://nssm.cc/download" -ForegroundColor White
        Write-Host "2. Распакуйте в C:\nssm" -ForegroundColor White
        Write-Host "3. Добавьте C:\nssm\win64 в PATH" -ForegroundColor White
        Write-Host "4. Запустите скрипт снова" -ForegroundColor White
        exit 1
    }
}

Write-Host "✓ NSSM найден: $nssmPath" -ForegroundColor Green
Write-Host ""

# Путь к скрипту мониторинга
$monitorScript = Join-Path $scriptDir "vpn_monitor.py"
if (-not (Test-Path $monitorScript)) {
    Write-Host "ОШИБКА: vpn_monitor.py не найден!" -ForegroundColor Red
    exit 1
}

# Удаление существующего сервиса (если есть)
$existingService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existingService) {
    Write-Host "Удаление существующего сервиса..." -ForegroundColor Yellow
    if ($existingService.Status -eq 'Running') {
        Stop-Service -Name $ServiceName -Force
    }
    & $nssmPath remove $ServiceName confirm
}

# Установка сервиса
Write-Host "Установка сервиса..." -ForegroundColor Yellow
& $nssmPath install $ServiceName $pythonPath "$monitorScript"

if ($LASTEXITCODE -ne 0) {
    Write-Host "ОШИБКА: Не удалось установить сервис!" -ForegroundColor Red
    exit 1
}

# Настройка сервиса
Write-Host "Настройка сервиса..." -ForegroundColor Yellow
& $nssmPath set $ServiceName DisplayName "$DisplayName"
& $nssmPath set $ServiceName Description "$Description"
& $nssmPath set $ServiceName Start SERVICE_AUTO_START
& $nssmPath set $ServiceName AppDirectory "$scriptDir"
& $nssmPath set $ServiceName AppStdout (Join-Path $scriptDir "vpn_monitor_service.log")
& $nssmPath set $ServiceName AppStderr (Join-Path $scriptDir "vpn_monitor_service.error.log")

Write-Host "✓ Сервис установлен" -ForegroundColor Green
Write-Host ""

# Запуск сервиса
Write-Host "Запуск сервиса..." -ForegroundColor Yellow
Start-Service -Name $ServiceName

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Сервис запущен" -ForegroundColor Green
} else {
    Write-Host "⚠ Не удалось запустить сервис автоматически" -ForegroundColor Yellow
    Write-Host "Запустите вручную: Start-Service -Name $ServiceName" -ForegroundColor White
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Сервис установлен успешно!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Имя сервиса: $ServiceName" -ForegroundColor Cyan
Write-Host "Управление сервисом:" -ForegroundColor Yellow
Write-Host "  Start-Service -Name $ServiceName   # Запуск" -ForegroundColor White
Write-Host "  Stop-Service -Name $ServiceName    # Остановка" -ForegroundColor White
Write-Host "  Restart-Service -Name $ServiceName # Перезапуск" -ForegroundColor White
Write-Host "  Get-Service -Name $ServiceName     # Статус" -ForegroundColor White
Write-Host ""

