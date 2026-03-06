@echo off
REM ClawApp PicoClaw 连接测试脚本

echo 🧪 ClawApp PicoClaw 连接测试
echo ================================

REM 检查 PicoClaw Gateway
echo.
echo 1️⃣ 检查 PicoClaw Gateway...
curl -s http://localhost:18790/health >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ PicoClaw Gateway 正在运行
) else (
    echo ❌ PicoClaw Gateway 未运行
    echo    请先启动: picoclaw gateway
    exit /b 1
)

REM 检查配置文件
echo.
echo 2️⃣ 检查配置文件...
if exist "server\.env" (
    echo ✅ 找到 server\.env
    
    findstr /C:"BACKEND_TYPE=picoclaw" server\.env >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo ✅ 后端类型: PicoClaw
    ) else (
        echo ⚠️  后端类型不是 picoclaw
        echo    请设置: BACKEND_TYPE=picoclaw
    )
    
    findstr /C:"PICOCLAW_GATEWAY_TOKEN=" server\.env | findstr /V "your-picoclaw-token" >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo ✅ PicoClaw Token 已配置
    ) else (
        echo ⚠️  PicoClaw Token 未配置
        echo    请设置: PICOCLAW_GATEWAY_TOKEN=your-token
    )
) else (
    echo ❌ 未找到 server\.env
    echo    请复制: copy server\.env.example server\.env
    exit /b 1
)

REM 检查依赖
echo.
echo 3️⃣ 检查依赖...
if exist "server\node_modules" (
    echo ✅ 服务端依赖已安装
) else (
    echo ⚠️  服务端依赖未安装
    echo    运行: cd server ^&^& npm install
)

if exist "h5\node_modules" (
    echo ✅ H5 依赖已安装
) else (
    echo ⚠️  H5 依赖未安装
    echo    运行: cd h5 ^&^& npm install
)

REM 检查构建
echo.
echo 4️⃣ 检查 H5 构建...
if exist "h5\dist" (
    echo ✅ H5 已构建
) else (
    echo ⚠️  H5 未构建
    echo    运行: npm run build:h5
)

echo.
echo ================================
echo ✨ 测试完成！
echo.
echo 启动命令:
echo   cd server ^&^& node index.js
echo.
echo 访问地址:
echo   http://localhost:3210
