#!/usr/bin/env python3
"""
VPN Monitor Service
Мониторинг подключения Cisco VPN AnyConnect и отправка уведомлений в Telegram
"""
import os
import sys
import time
import subprocess
import logging
from datetime import datetime
from pathlib import Path
from dotenv import load_dotenv
import requests
import json

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('vpn_monitor.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# Загрузка переменных окружения
load_dotenv()

# Конфигурация
TELEGRAM_BOT_TOKEN = os.getenv('TELEGRAM_BOT_TOKEN')
TELEGRAM_CHAT_ID = os.getenv('TELEGRAM_CHAT_ID')
CHECK_INTERVAL = int(os.getenv('VPN_CHECK_INTERVAL', '30'))  # секунды
VPN_ADAPTER_NAME = os.getenv('VPN_ADAPTER_NAME', 'Cisco AnyConnect')  # Имя адаптера VPN

# Пути к Cisco AnyConnect (стандартные)
VPNCLI_PATHS = [
    r'C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe',
    r'C:\Program Files\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe',
]


class VPNMonitor:
    """Класс для мониторинга VPN соединения"""
    
    def __init__(self):
        self.last_status = None
        self.vpncli_path = self._find_vpncli()
        
    def _find_vpncli(self):
        """Поиск пути к vpncli.exe"""
        for path in VPNCLI_PATHS:
            if os.path.exists(path):
                logger.info(f"Найден VPN CLI: {path}")
                return path
        logger.warning("VPN CLI не найден, будет использоваться метод проверки сетевых адаптеров")
        return None
    
    def check_vpn_via_cli(self):
        """Проверка VPN через vpncli.exe"""
        if not self.vpncli_path:
            return None
        
        try:
            # Выполняем команду проверки статуса
            result = subprocess.run(
                [self.vpncli_path, 'state'],
                capture_output=True,
                text=True,
                timeout=10
            )
            
            output = result.stdout.lower()
            
            # Проверяем статус подключения
            if 'state: connected' in output or 'connected' in output:
                return True
            elif 'state: disconnected' in output or 'disconnected' in output:
                return False
            else:
                # Если не удалось определить, возвращаем None
                return None
                
        except subprocess.TimeoutExpired:
            logger.error("Таймаут при проверке VPN через CLI")
            return None
        except Exception as e:
            logger.error(f"Ошибка при проверке VPN через CLI: {e}")
            return None
    
    def check_vpn_via_network_adapters(self):
        """Проверка VPN через сетевые адаптеры Windows"""
        try:
            # Используем PowerShell для проверки сетевых адаптеров
            ps_script = """
            Get-NetAdapter | Where-Object {
                $_.Name -like '*AnyConnect*' -or 
                $_.Name -like '*Cisco*' -or
                $_.InterfaceDescription -like '*AnyConnect*' -or
                $_.InterfaceDescription -like '*Cisco*'
            } | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
            """
            
            result = subprocess.run(
                ['powershell', '-Command', ps_script],
                capture_output=True,
                text=True,
                timeout=10
            )
            
            # Если найдены активные адаптеры, VPN подключен
            if result.returncode == 0 and result.stdout.strip():
                output = result.stdout.lower()
                if 'up' in output or 'connected' in output:
                    return True
            
            # Дополнительная проверка через ipconfig
            result = subprocess.run(
                ['ipconfig', '/all'],
                capture_output=True,
                text=True,
                timeout=10
            )
            
            output = result.stdout.lower()
            # Ищем упоминания Cisco или AnyConnect в активных адаптерах
            if 'anyconnect' in output or 'cisco' in output:
                # Проверяем, что адаптер не отключен
                if 'media disconnected' not in output:
                    return True
            
            return False
            
        except subprocess.TimeoutExpired:
            logger.error("Таймаут при проверке сетевых адаптеров")
            return None
        except Exception as e:
            logger.error(f"Ошибка при проверке сетевых адаптеров: {e}")
            return None
    
    def check_vpn_via_process(self):
        """Проверка VPN через процессы"""
        try:
            # Проверяем наличие процесса vpnui.exe или vpncli.exe
            result = subprocess.run(
                ['tasklist', '/FI', 'IMAGENAME eq vpnui.exe'],
                capture_output=True,
                text=True,
                timeout=10
            )
            
            if 'vpnui.exe' in result.stdout:
                # Процесс запущен, но это не гарантирует подключение
                # Используем как дополнительную проверку
                return self.check_vpn_via_network_adapters()
            
            return False
            
        except Exception as e:
            logger.error(f"Ошибка при проверке процессов: {e}")
            return None
    
    def check_vpn_status(self):
        """Основной метод проверки статуса VPN"""
        # Сначала пробуем через CLI
        status = self.check_vpn_via_cli()
        
        # Если CLI недоступен, используем проверку адаптеров
        if status is None:
            status = self.check_vpn_via_network_adapters()
        
        # Если и это не помогло, пробуем через процессы
        if status is None:
            status = self.check_vpn_via_process()
        
        return status
    
    def send_telegram_message(self, message):
        """Отправка сообщения в Telegram"""
        if not TELEGRAM_BOT_TOKEN or not TELEGRAM_CHAT_ID:
            logger.error("TELEGRAM_BOT_TOKEN или TELEGRAM_CHAT_ID не настроены")
            return False
        
        url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
        
        payload = {
            'chat_id': TELEGRAM_CHAT_ID,
            'text': message,
            'parse_mode': 'HTML'
        }
        
        try:
            response = requests.post(url, json=payload, timeout=10)
            response.raise_for_status()
            logger.info("Сообщение отправлено в Telegram")
            return True
        except requests.exceptions.RequestException as e:
            logger.error(f"Ошибка при отправке сообщения в Telegram: {e}")
            return False
    
    def format_message(self, status, timestamp=None):
        """Форматирование сообщения для Telegram"""
        if timestamp is None:
            timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        if status:
            emoji = "✅"
            status_text = "ПОДКЛЮЧЕНО"
            message = f"{emoji} <b>VPN AnyConnect</b>\n\nСтатус: {status_text}\nВремя: {timestamp}"
        else:
            emoji = "❌"
            status_text = "ОТКЛЮЧЕНО"
            message = f"{emoji} <b>VPN AnyConnect</b>\n\nСтатус: {status_text}\nВремя: {timestamp}"
        
        return message
    
    def run(self):
        """Основной цикл мониторинга"""
        logger.info("Запуск VPN Monitor Service")
        logger.info(f"Интервал проверки: {CHECK_INTERVAL} секунд")
        
        # Отправляем начальное сообщение
        initial_message = f"🚀 <b>VPN Monitor Service запущен</b>\n\nИнтервал проверки: {CHECK_INTERVAL} сек\nВремя запуска: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
        self.send_telegram_message(initial_message)
        
        while True:
            try:
                # Проверяем статус VPN
                current_status = self.check_vpn_status()
                
                # Если статус изменился, отправляем уведомление
                if current_status is not None and current_status != self.last_status:
                    if self.last_status is not None:  # Пропускаем первое уведомление при запуске
                        message = self.format_message(current_status)
                        self.send_telegram_message(message)
                    
                    self.last_status = current_status
                    logger.info(f"Статус VPN: {'Подключено' if current_status else 'Отключено'}")
                
                # Ждем перед следующей проверкой
                time.sleep(CHECK_INTERVAL)
                
            except KeyboardInterrupt:
                logger.info("Получен сигнал остановки")
                break
            except Exception as e:
                logger.error(f"Ошибка в цикле мониторинга: {e}")
                time.sleep(CHECK_INTERVAL)
        
        # Отправляем сообщение об остановке
        stop_message = f"⏹ <b>VPN Monitor Service остановлен</b>\n\nВремя остановки: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
        self.send_telegram_message(stop_message)
        logger.info("VPN Monitor Service остановлен")


def main():
    """Точка входа"""
    # Проверка обязательных переменных окружения
    if not TELEGRAM_BOT_TOKEN:
        logger.error("TELEGRAM_BOT_TOKEN не настроен в .env файле")
        sys.exit(1)
    
    if not TELEGRAM_CHAT_ID:
        logger.error("TELEGRAM_CHAT_ID не настроен в .env файле")
        sys.exit(1)
    
    # Создаем и запускаем монитор
    monitor = VPNMonitor()
    monitor.run()


if __name__ == "__main__":
    main()

