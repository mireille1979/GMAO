@echo off
echo ============================================
echo    GMAO Frontend - Demarrage Flutter
echo    (Telephone physique via USB)
echo ============================================
echo.

set "PROJECT_ROOT=%~dp0"

:: Verification de Flutter
echo Verification de Flutter...
call flutter --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] Flutter n'est pas installe ou pas dans le PATH.
    pause
    exit /b %ERRORLEVEL%
)

:: Verification du telephone connecte
echo.
echo Appareils connectes :
call flutter devices
echo.

:: Configurer adb reverse pour rediriger le port 8081
echo Configuration de adb reverse (port 8081)...
adb reverse tcp:8081 tcp:8081
if %ERRORLEVEL% NEQ 0 (
    echo [ATTENTION] adb reverse a echoue. Verifiez que :
    echo   - Le telephone est connecte en USB
    echo   - Le debogage USB est active sur le telephone
    echo   - ADB est dans le PATH
    pause
    exit /b %ERRORLEVEL%
)
echo adb reverse OK : le telephone peut acceder au backend via localhost:8081
echo.

:: Installation des dependances
echo Installation des dependances...
cd "%PROJECT_ROOT%gmao_mobile"
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [ERREUR] Echec de l'installation des dependances.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo Lancement sur le telephone physique...
echo (Appuyez sur 'q' pour arreter)
echo (Appuyez sur 'r' pour hot-reload)
echo.
call flutter run
pause
