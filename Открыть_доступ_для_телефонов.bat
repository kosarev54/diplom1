@echo off
chcp 65001 >nul
rem ════════════════════════════════════════════════════════════════════
rem  Разрешает телефонам водителей (в той же сети Wi-Fi) и серверу 1С
rem  подключаться к АРМ диспетчера. Запускается ОДИН раз.
rem  Порт по умолчанию 5080; другой порт: Открыть_доступ_для_телефонов.bat 5090
rem ════════════════════════════════════════════════════════════════════
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo Нужны права администратора — подтвердите запрос Windows...
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList '%~1' -Verb RunAs"
  exit /b
)

set PORT=5080
if not "%~1"=="" set PORT=%~1

echo.
echo  1/2  Регистрация адреса http://+:%PORT%/ для всех пользователей...
netsh http delete urlacl url=http://+:%PORT%/ >nul 2>&1
netsh http add urlacl url=http://+:%PORT%/ sddl=D:(A;;GX;;;WD)

echo  2/2  Правило брандмауэра Windows для порта %PORT%...
netsh advfirewall firewall delete rule name="DispatcherARM driver app" >nul 2>&1
netsh advfirewall firewall add rule name="DispatcherARM driver app" dir=in action=allow protocol=TCP localport=%PORT% profile=any

echo.
echo  Готово. Перезапустите АРМ диспетчера (или нажмите «Остановить» / «Запустить»
echo  на странице «Трекинг водителей»). Адрес для телефонов показан на этой странице:
echo      http://IP-адрес-компьютера:%PORT%/driver
echo.
echo  Отменить:  netsh http delete urlacl url=http://+:%PORT%/
echo             netsh advfirewall firewall delete rule name="DispatcherARM driver app"
echo.
pause
