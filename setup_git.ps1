# Скрипт для настройки Git репозитория
# Запустите этот скрипт после установки Git

Write-Host "Настройка Git репозитория для AI Mail..." -ForegroundColor Green

# Проверка наличия Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "ОШИБКА: Git не установлен!" -ForegroundColor Red
    Write-Host "Установите Git с https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

Write-Host "Git найден: $(git --version)" -ForegroundColor Green

# Инициализация репозитория
if (-not (Test-Path .git)) {
    Write-Host "Инициализация Git репозитория..." -ForegroundColor Yellow
    git init
} else {
    Write-Host "Git репозиторий уже инициализирован" -ForegroundColor Yellow
}

# Добавление всех файлов
Write-Host "Добавление файлов в индекс..." -ForegroundColor Yellow
git add .

# Проверка статуса
Write-Host "`nСтатус репозитория:" -ForegroundColor Cyan
git status

Write-Host "`nДля создания первого коммита выполните:" -ForegroundColor Green
Write-Host "  git commit -m 'Initial commit'" -ForegroundColor White

Write-Host "`nДля подключения к удаленному репозиторию:" -ForegroundColor Green
Write-Host "  git remote add origin https://github.com/YOUR_USERNAME/ai-mail.git" -ForegroundColor White
Write-Host "  git branch -M main" -ForegroundColor White
Write-Host "  git push -u origin main" -ForegroundColor White

