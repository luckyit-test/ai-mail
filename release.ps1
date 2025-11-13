# Скрипт для релиза проекта в GitHub
# Использование: .\release.ps1 -GitHubUsername "YOUR_USERNAME"

param(
    [Parameter(Mandatory=$false)]
    [string]$GitHubUsername = "YOUR_USERNAME"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  AI Mail - Релиз в GitHub" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Проверка наличия Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "ОШИБКА: Git не установлен!" -ForegroundColor Red
    Write-Host "Установите Git с https://git-scm.com/download/win" -ForegroundColor Yellow
    Write-Host "После установки перезапустите терминал и запустите скрипт снова." -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Git найден: $(git --version)" -ForegroundColor Green
Write-Host ""

# Инициализация репозитория
if (-not (Test-Path .git)) {
    Write-Host "Инициализация Git репозитория..." -ForegroundColor Yellow
    git init
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Ошибка при инициализации Git репозитория!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✓ Git репозиторий уже инициализирован" -ForegroundColor Green
}

# Проверка конфигурации Git
$gitUser = git config --global user.name
$gitEmail = git config --global user.email

if (-not $gitUser -or -not $gitEmail) {
    Write-Host "⚠ Предупреждение: Git пользователь не настроен!" -ForegroundColor Yellow
    Write-Host "Настройте Git пользователя с помощью команд:" -ForegroundColor Yellow
    Write-Host "  git config --global user.name 'Ваше Имя'" -ForegroundColor White
    Write-Host "  git config --global user.email 'ваш.email@example.com'" -ForegroundColor White
    Write-Host ""
    $continue = Read-Host "Продолжить без настройки пользователя? (y/n)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 0
    }
} else {
    Write-Host "✓ Git пользователь настроен: $gitUser <$gitEmail>" -ForegroundColor Green
}

Write-Host ""

# Добавление файлов
Write-Host "Добавление файлов в индекс..." -ForegroundColor Yellow
git add .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Ошибка при добавлении файлов!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Файлы добавлены" -ForegroundColor Green
Write-Host ""

# Проверка статуса
Write-Host "Статус репозитория:" -ForegroundColor Cyan
git status
Write-Host ""

# Проверка наличия коммитов
$hasCommits = git rev-parse --verify HEAD 2>$null
if (-not $hasCommits) {
    Write-Host "Создание первого коммита..." -ForegroundColor Yellow
    $commitMessage = Read-Host "Введите сообщение коммита (или нажмите Enter для 'Initial commit')"
    if ([string]::IsNullOrWhiteSpace($commitMessage)) {
        $commitMessage = "Initial commit: AI Mail project setup"
    }
    git commit -m $commitMessage
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Ошибка при создании коммита!" -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Коммит создан" -ForegroundColor Green
} else {
    Write-Host "✓ Коммиты уже существуют" -ForegroundColor Green
}

Write-Host ""

# Проверка удаленного репозитория
$remoteExists = git remote get-url origin 2>$null
if ($remoteExists) {
    Write-Host "✓ Удаленный репозиторий уже настроен: $remoteExists" -ForegroundColor Green
    $remoteUrl = $remoteExists
} else {
    if ($GitHubUsername -eq "YOUR_USERNAME") {
        Write-Host "⚠ Удаленный репозиторий не настроен" -ForegroundColor Yellow
        $GitHubUsername = Read-Host "Введите ваш GitHub username"
    }
    $remoteUrl = "https://github.com/$GitHubUsername/ai-mail.git"
    Write-Host "Добавление удаленного репозитория: $remoteUrl" -ForegroundColor Yellow
    git remote add origin $remoteUrl
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Ошибка при добавлении удаленного репозитория!" -ForegroundColor Red
        Write-Host "Убедитесь, что репозиторий создан на GitHub: https://github.com/new" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "✓ Удаленный репозиторий добавлен" -ForegroundColor Green
}

Write-Host ""

# Переименование ветки в main
Write-Host "Проверка ветки..." -ForegroundColor Yellow
$currentBranch = git branch --show-current
if ($currentBranch -ne "main") {
    Write-Host "Переименование ветки в 'main'..." -ForegroundColor Yellow
    git branch -M main
    Write-Host "✓ Ветка переименована в 'main'" -ForegroundColor Green
} else {
    Write-Host "✓ Текущая ветка: main" -ForegroundColor Green
}

Write-Host ""

# Отправка в GitHub
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Готово к отправке в GitHub!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Для отправки кода выполните:" -ForegroundColor Green
Write-Host "  git push -u origin main" -ForegroundColor White
Write-Host ""
Write-Host "Если потребуется аутентификация:" -ForegroundColor Yellow
Write-Host "  - Используйте Personal Access Token вместо пароля" -ForegroundColor White
Write-Host "  - Создайте токен: https://github.com/settings/tokens" -ForegroundColor White
Write-Host ""
$pushNow = Read-Host "Отправить код сейчас? (y/n)"
if ($pushNow -eq "y" -or $pushNow -eq "Y") {
    Write-Host "Отправка кода в GitHub..." -ForegroundColor Yellow
    git push -u origin main
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Код успешно отправлен в GitHub!" -ForegroundColor Green
        Write-Host "Репозиторий: $remoteUrl" -ForegroundColor Cyan
    } else {
        Write-Host "⚠ Ошибка при отправке кода. Проверьте настройки аутентификации." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Готово!" -ForegroundColor Green

