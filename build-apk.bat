@echo off
REM ClawApp APK 构建脚本 (Windows)

echo 🚀 开始构建 ClawApp APK...

REM 检查 Node.js
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 错误: 未安装 Node.js
    exit /b 1
)

REM 检查 Java
where java >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 错误: 未安装 Java JDK
    exit /b 1
)

echo ✓ 环境检查通过

REM 安装依赖
echo 📦 安装依赖...
call npm ci
cd h5
call npm ci
cd ..

REM 构建 H5
echo 🔨 构建 H5 前端...
call npm run build:h5

REM 同步到 Android
echo 🔄 同步到 Android 项目...
call npx cap sync android

REM 构建 APK
echo 📱 构建 Debug APK...
cd android
call gradlew.bat assembleDebug

echo.
echo ✅ 构建完成！
echo 📦 APK 位置: android\app\build\outputs\apk\debug\app-debug.apk
echo.
echo 安装命令:
echo   adb install -r app\build\outputs\apk\debug\app-debug.apk

cd ..
