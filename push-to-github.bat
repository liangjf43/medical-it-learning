@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title 创建并推送 GitHub 仓库 medical-it-learning

echo ============================================================
echo   一键创建 GitHub 仓库并推送 medical-it-learning
echo ============================================================
echo.

set GITHUB_USER=liangjf43
set REPO_NAME=medical-it-learning
set REPO_DIR=D:\梁晶晶\medical-it-learning

if not exist "%REPO_DIR%" (
    echo [错误] 本地仓库目录不存在: %REPO_DIR%
    pause
    exit /b 1
)

echo 请输入你的 GitHub Personal Access Token
echo   ^(在 https://github.com/settings/tokens 生成，需勾选 repo 权限^)
echo   输入时屏幕不显示，粘贴后按回车即可
echo.
set /p TOKEN=
echo.

if "!TOKEN!"=="" (
    echo [错误] Token 为空，已取消。
    pause
    exit /b 1
)

echo [1/4] 正在创建远程仓库 %REPO_NAME% ...
curl -sS --ssl-no-revoke -X POST ^
  -H "Authorization: Bearer !TOKEN!" ^
  -H "Accept: application/vnd.github+json" ^
  -H "X-GitHub-Api-Version: 2022-11-28" ^
  -d "{\"name\":\"%REPO_NAME%\",\"description\":\"零基础医学生转医疗信息化的学习仓库\",\"private\":false,\"auto_init\":false}" ^
  "https://api.github.com/user/repos" > "%TEMP%\gh_create.json" 2>&1

findstr /C:"\"full_name\"" "%TEMP%\gh_create.json" >nul
if errorlevel 1 (
    echo.
    echo    仓库创建可能失败，返回信息：
    type "%TEMP%\gh_create.json"
    echo.
    echo    常见原因：Token 无效 / 权限不足 / 仓库已存在
    echo    若仓库已存在，可以直接继续推送。
    echo.
    set /p CONTINUE=是否继续尝试推送？(y/n):
    if /i not "!CONTINUE!"=="y" (
        pause
        exit /b 1
    )
) else (
    echo    仓库创建成功。
)
echo.

echo [2/4] 配置远程地址 ...
cd /d "%REPO_DIR%"
git remote remove origin >nul 2>&1
git remote add origin "https://github.com/%GITHUB_USER%/%REPO_NAME%.git"
echo    远程地址: https://github.com/%GITHUB_USER%/%REPO_NAME%.git
echo.

echo [3/4] 推送代码到 GitHub ...
git -c credential.helper= -c http.sslVerify=true push -u "https://%GITHUB_USER%:!TOKEN!@github.com/%GITHUB_USER%/%REPO_NAME%.git" main
if errorlevel 1 (
    echo.
    echo [失败] 推送未成功，请检查网络或 Token 权限。
    pause
    exit /b 1
)
echo.

echo [4/4] 清理凭据并验证 ...
git remote set-url origin "https://github.com/%GITHUB_USER%/%REPO_NAME%.git"
echo.
echo ============================================================
echo   完成！仓库地址：
echo   https://github.com/%GITHUB_USER%/%REPO_NAME%
echo ============================================================
echo.
pause
