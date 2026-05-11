@echo off
REM 同步知识库 → 构建 → 推送部署（一键完成）
echo === 1. 同步 Obsidian 内容 ===
robocopy "C:\Users\Administrator\Desktop\知识库\新媒体增长" "content\新媒体增长" /E /XO /NJH /NJS /NP /NDL >nul 2>&1
if %errorlevel% geq 8 goto :error

echo === 2. 构建网站 ===
call npx quartz build
if %errorlevel% neq 0 goto :error

echo === 3. 推送部署 ===
git add -A
git commit -m "Content update: %date% %time%"
git push
if %errorlevel% neq 0 goto :error

echo === 完成！1-2 分钟后刷新网页 ===
goto :end

:error
echo === 出错，请检查 ===
pause

:end
