@echo off
REM 一键：转换 → 构建 → 推送
cd /d "%~dp0"
echo === 1. 转换待处理文件 ===
powershell -ExecutionPolicy Bypass -File "convert.ps1"
echo === 2. 构建网站 ===
call npx quartz build
if %errorlevel% neq 0 goto :error
echo === 3. 推送部署 ===
git add -A
git commit -m "Deploy: %date% %time%"
git push
if %errorlevel% neq 0 goto :error
echo === 完成！ ===
goto :end
:error
echo === 出错 ===
pause
:end
