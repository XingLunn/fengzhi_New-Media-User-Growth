@echo off
REM 一键：构建 → 推送
cd /d "%~dp0"
echo === 1. 构建网站 ===
call npx quartz build
if %errorlevel% neq 0 goto :error
echo === 2. 推送部署 ===
git add -A
git commit -m "Deploy: %date% %time%"
git push
if %errorlevel% neq 0 goto :error
echo === 完成！1-2 分钟后刷新网页 ===
goto :end
:error
echo === 出错 ===
pause
:end
