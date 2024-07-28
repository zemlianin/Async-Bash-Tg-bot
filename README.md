# Simple Async Telegram Bot on bash
## Описание
Проект представляет из себя простой инструмент и тривиальную реализацию телеграм бота, обеспечивающего асихронную работу с несколькими чатами.
## Инструкция к запуску

Linux

Клонирование репозитория.
```
git clone https://github.com/zemlianin/Async-Bash-Tg-bot
```

Установка необходимых зависимостей.
```
sudo apt-get update
sudo apt-get install curl
sudo apt-get install jq
```

Добавление Bot-Token вашего Telegram бота.
- Открыть settings.sh
- Изменить строку
  ``` export BOT_TOKEN="" ```

Запуск бота
```
bash main.sh
```
