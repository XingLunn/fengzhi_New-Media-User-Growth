@echo off
REM 同步知识库到 Quartz 并重新构建
echo === 1. 复制最新内容 ===
xcopy "C:\Users\Administrator\Desktop\知识库\新媒体增长" "content\新媒体增长" /E /Y /D /EXCLUDE:exclude.txt
echo === 2. 构建网站 ===
call npx quartz build
echo === 3. 完成 ===
echo 运行 npx quartz build --serve 启动预览
pause
