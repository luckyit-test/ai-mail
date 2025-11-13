# Скрипт для отправки кода в GitHub после создания репозитория
# Использование: .\push_to_github.ps1 -GitHubUsername "YOUR_USERNAME"

param(
    [Parameter(Mandatory=$true)]
    [string]$GitHubUsername
)

$gitPath = "C:\Program Files\Git\bin\git.exe"

if (-not (Test-Path $gitPath)) {
    Write-Host "ОШИБКА: Git не найден по пути $gitPath" -ForegroundColor Red
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Отправка кода в GitHub" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$remoteUrl = "https://github.com/$GitHubUsername/ai-mail.git"

# Проверка существования удаленного репозитория
$existingRemote = & $gitPath remote get-url origin 2>$null
if ($existingRemote) {
    Write-Host "Удаленный репозиторий уже настроен: $existingRemote" -ForegroundColor Yellow
    $update = Read-Host "Изменить на $remoteUrl? (y/n)"
    if ($update -eq "y" -or $update -eq "Y") {
        & $gitPath remote set-url origin $remoteUrl
        Write-Host "✓ URL удаленного репозитория обновлен" -ForegroundColor Green
    } else {
        $remoteUrl = $existingRemote
    }
} else {
    Write-Host "Добавление удаленного репозитория: $remoteUrl" -ForegroundColor Yellow
    & $gitPath remote add origin $remoteUrl
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Ошибка при добавлении удаленного репозитория!" -ForegroundColor Red
        Write-Host "Убедитесь, что репозиторий создан на GitHub: https://github.com/new" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "✓ Удаленный репозиторий добавлен" -ForegroundColor Green
}

Write-Host ""

# Проверка текущей ветки
$currentBranch = & $gitPath branch --show-current
if ($currentBranch -ne "main") {
    Write-Host "Переименование ветки в 'main'..." -ForegroundColor Yellow
    & $gitPath branch -M main
    Write-Host "✓ Ветка переименована в 'main'" -ForegroundColor Green
} else {
    Write-Host "✓ Текущая ветка: main" -ForegroundColor Green
}

Write-Host ""

# Отправка в GitHub
Write-Host "Отправка кода в GitHub..." -ForegroundColor Yellow
Write-Host "URL: $remoteUrl" -ForegroundColor Cyan
Write-Host ""

& $gitPath push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✓ Код успешно отправлен в GitHub!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Репозиторий: $remoteUrl" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "⚠ Ошибка при отправке кода." -ForegroundColor Red
    Write-Host ""
    Write-Host "Возможные причины:" -ForegroundColor Yellow
    Write-Host "1. Репозиторий не создан на GitHub" -ForegroundColor White
    Write-Host "   Создайте его: https://github.com/new" -ForegroundColor White
    Write-Host "2. Неправильные учетные данные" -ForegroundColor White
    Write-Host "   Используйте Personal Access Token вместо пароля" -ForegroundColor White
    Write-Host "   Создайте токен: https://github.com/settings/tokens" -ForegroundColor White
    Write-Host "3. Репозиторий уже существует и не пуст" -ForegroundColor White
    Write-Host "   Используйте: git push -u origin main --force (осторожно!)" -ForegroundColor White
}

