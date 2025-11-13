# AI Mail

Проект для автоматической обработки и отправки электронных писем с использованием искусственного интеллекта.

## Установка

1. Клонируйте репозиторий:
```bash
git clone https://github.com/YOUR_USERNAME/ai-mail.git
cd ai-mail
```

2. Создайте виртуальное окружение:
```bash
python -m venv venv
```

3. Активируйте виртуальное окружение:
- Windows: `venv\Scripts\activate`
- Linux/Mac: `source venv/bin/activate`

4. Установите зависимости:
```bash
pip install -r requirements.txt
```

5. Создайте файл `.env` на основе `.env.example` и заполните необходимые переменные окружения.

6. Запустите приложение:
```bash
python main.py
```

## Переменные окружения

Создайте файл `.env` в корне проекта со следующими переменными:

```
OPENAI_API_KEY=ваш_ключ_openai
EMAIL_SERVER=smtp.ваш_сервер.com
EMAIL_USERNAME=ваш_email@example.com
EMAIL_PASSWORD=ваш_пароль
EMAIL_PORT=587
IMAP_USERNAME=ваш_imap_логин
IMAP_PASSWORD=ваш_imap_пароль
IMAP_SERVER=imap.gmail.com
IMAP_PORT=993
```

## Использование

Приложение автоматически обрабатывает входящие письма и может отправлять ответы с использованием AI.

## Настройка Git и релиз в GitHub

### Требования
- Установленный Git (скачать с https://git-scm.com/download/win)

### Быстрая настройка (автоматическая)

**Рекомендуемый способ** - используйте скрипт релиза:
```powershell
.\release.ps1
```

Или с указанием GitHub username:
```powershell
.\release.ps1 -GitHubUsername "ваш_username"
```

Альтернативный способ - скрипт настройки:
```powershell
.\setup_git.ps1
```

### Ручная настройка

1. Инициализация репозитория:
```bash
git init
```

2. Добавление файлов:
```bash
git add .
```

3. Создание первого коммита:
```bash
git commit -m "Initial commit"
```

4. Подключение к удаленному репозиторию (замените YOUR_USERNAME на ваш GitHub username):
```bash
git remote add origin https://github.com/YOUR_USERNAME/ai-mail.git
git branch -M main
git push -u origin main
```

### Создание репозитория на GitHub

1. Перейдите на https://github.com/new
2. Создайте новый репозиторий с именем `ai-mail`
3. Не инициализируйте репозиторий (README, .gitignore и лицензия уже есть)
4. Скопируйте URL репозитория и используйте его в команде `git remote add origin`

## Структура проекта

```
ai-mail/
├── .env.example          # Пример файла с переменными окружения
├── .gitignore           # Игнорируемые файлы для Git
├── main.py              # Главный файл приложения
├── requirements.txt     # Зависимости Python
├── README.md           # Документация проекта
├── DEPLOYMENT.md       # Подробная инструкция по развертыванию
├── setup_git.ps1       # Скрипт для настройки Git
└── release.ps1         # Скрипт для автоматического релиза в GitHub

```

## Быстрый старт

1. Установите Git (если еще не установлен): https://git-scm.com/download/win
2. Создайте репозиторий на GitHub: https://github.com/new
3. Запустите скрипт релиза:
   ```powershell
   .\release.ps1
   ```
4. Следуйте инструкциям скрипта

Подробная инструкция доступна в файле `DEPLOYMENT.md`.

