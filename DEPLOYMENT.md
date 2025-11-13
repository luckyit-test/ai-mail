# Инструкция по развертыванию и релизу

## Предварительные требования

1. **Установите Git** (если еще не установлен):
   - Скачайте с https://git-scm.com/download/win
   - Установите с настройками по умолчанию
   - Перезапустите терминал после установки

2. **Создайте репозиторий на GitHub**:
   - Перейдите на https://github.com/new
   - Создайте репозиторий с именем `ai-mail`
   - **Не** инициализируйте репозиторий (README, .gitignore уже есть локально)
   - Скопируйте URL репозитория (например: `https://github.com/YOUR_USERNAME/ai-mail.git`)

## Шаги по развертыванию

### 1. Настройка Git (если еще не сделано)

Если Git не установлен, выполните установку из раздела "Предварительные требования".

Проверьте наличие Git:
```bash
git --version
```

### 2. Инициализация репозитория

Инициализируйте Git репозиторий (если еще не инициализирован):
```bash
git init
```

### 3. Настройка Git пользователя (первый раз)

Настройте ваше имя и email для Git:
```bash
git config --global user.name "Ваше Имя"
git config --global user.email "ваш.email@example.com"
```

### 4. Добавление файлов в индекс

Добавьте все файлы проекта:
```bash
git add .
```

Проверьте статус:
```bash
git status
```

### 5. Создание первого коммита

Создайте первый коммит:
```bash
git commit -m "Initial commit: AI Mail project setup"
```

### 6. Подключение к удаленному репозиторию

Подключите удаленный репозиторий (замените YOUR_USERNAME на ваш GitHub username):
```bash
git remote add origin https://github.com/YOUR_USERNAME/ai-mail.git
```

Проверьте подключение:
```bash
git remote -v
```

### 7. Переименование ветки в main (если нужно)

Убедитесь, что ветка называется `main`:
```bash
git branch -M main
```

### 8. Отправка кода в GitHub

Отправьте код в удаленный репозиторий:
```bash
git push -u origin main
```

Если возникнет ошибка аутентификации, используйте Personal Access Token:
1. Создайте токен на https://github.com/settings/tokens
2. Используйте токен вместо пароля при выполнении `git push`

## Быстрая настройка (автоматическая)

Для автоматической настройки используйте скрипт:
```powershell
.\setup_git.ps1
```

Затем выполните:
```bash
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/ai-mail.git
git branch -M main
git push -u origin main
```

## Обновление кода

После внесения изменений в код:

1. Добавьте изменения:
```bash
git add .
```

2. Создайте коммит:
```bash
git commit -m "Описание изменений"
```

3. Отправьте изменения:
```bash
git push
```

## Полезные команды

- `git status` - проверить статус репозитория
- `git log` - просмотреть историю коммитов
- `git diff` - посмотреть изменения в файлах
- `git remote -v` - проверить подключенные удаленные репозитории

