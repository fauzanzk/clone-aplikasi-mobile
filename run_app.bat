@echo off
title TraveLokuy Launcher
echo ====================================================
echo   Menjalankan TraveLokuy (DB + Backend + Flutter)
echo ====================================================

echo [1/3] Menjalankan MySQL Database (Port 3307)...
start "TraveLokuy - MySQL Database" cmd /k "cd /d "%~dp0backend" && npm run db:start"

echo Menunggu database siap...
timeout /t 3 /nobreak >nul

echo [2/3] Menjalankan Backend Server (Port 5000)...
start "TraveLokuy - Backend API" cmd /k "cd /d "%~dp0backend" && npm start"

echo Menunggu backend siap...
timeout /t 2 /nobreak >nul

echo [3/3] Menjalankan Flutter App (Chrome)...
cd /d "%~dp0frontend"
flutter run -d chrome
