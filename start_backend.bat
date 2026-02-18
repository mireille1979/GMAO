@echo off
echo Setting up Maven environment...
set "PROJECT_ROOT=%~dp0"
set "JAVA_HOME=C:\Program Files\Java\jdk-21"
set "MAVEN_HOME=%PROJECT_ROOT%tools\apache-maven-3.9.6"
set "PATH=%JAVA_HOME%\bin;%MAVEN_HOME%\bin;%PATH%"

echo Verifying Maven installation...
call mvn -version
if %ERRORLEVEL% NEQ 0 (
    echo Maven installation failed or not found.
    pause
    exit /b %ERRORLEVEL%
)

echo Starting GMAO Backend...
cd gmao_backend
call mvn spring-boot:run
pause
