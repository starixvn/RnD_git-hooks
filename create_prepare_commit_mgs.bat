@echo off
setlocal enabledelayedexpansion

REM Batch script to create prepare-commit-msg hook with inline content
REM
REM USAGE EXAMPLES:
REM   create_prepare_commit_mgs.bat                    - Run from any directory within Git repo
REM   create_prepare_commit_mgs.bat "C:\projects"     - Search from custom path
REM   create_prepare_commit_mgs.bat /help              - Show this help
REM   create_prepare_commit_mgs.bat /verbose           - Show detailed output
REM   create_prepare_commit_mgs.bat /force             - Overwrite existing hook
REM
REM EXAMPLES:
REM   cd C:\projects\my-project
REM   ..\scripts\create_prepare_commit_mgs.bat
REM
REM   cd C:\projects\my-project\src\components
REM   ..\..\..\..\scripts\create_prepare_commit_mgs.bat
REM
REM   cd C:\git\game-client-main\.git\hooks
REM   create_prepare_commit_mgs.bat
REM
REM   REM Search from custom path
REM   create_prepare_commit_mgs.bat "C:\projects\my-project"
REM   create_prepare_commit_mgs.bat "C:\projects" /verbose

set "HELP_FLAG="
set "VERBOSE_FLAG="
set "FORCE_FLAG="
set "CUSTOM_PATH="

REM Parse command line arguments
:parse_args
if "%~1"=="" goto :end_parse
if /i "%~1"=="-help" set "HELP_FLAG=1"
if /i "%~1"=="--help" set "HELP_FLAG=1"
if /i "%~1"=="/help" set "HELP_FLAG=1"
if /i "%~1"=="-verbose" set "VERBOSE_FLAG=1"
if /i "%~1"=="--verbose" set "VERBOSE_FLAG=1"
if /i "%~1"=="/verbose" set "VERBOSE_FLAG=1"
if /i "%~1"=="-force" set "FORCE_FLAG=1"
if /i "%~1"=="--force" set "FORCE_FLAG=1"
if /i "%~1"=="/force" set "FORCE_FLAG=1"
if /i "%~1"=="-path" (
    set "CUSTOM_PATH=%~2"
    shift
)
if /i "%~1"=="--path" (
    set "CUSTOM_PATH=%~2"
    shift
)
if /i "%~1"=="/path" (
    set "CUSTOM_PATH=%~2"
    shift
)
if not "%~1"=="-help" if not "%~1"=="--help" if not "%~1"=="/help" (
    if not "%~1"=="-verbose" if not "%~1"=="--verbose" if not "%~1"=="/verbose" (
        if not "%~1"=="-force" if not "%~1"=="--force" if not "%~1"=="/force" (
            if not "%~1"=="-path" if not "%~1"=="--path" if not "%~1"=="/path" (
                if not defined CUSTOM_PATH set "CUSTOM_PATH=%~1"
            )
        )
    )
)
shift
goto :parse_args
:end_parse

REM Show help if requested
if defined HELP_FLAG goto :show_help

REM Main script execution
if defined VERBOSE_FLAG (
    echo Running in verbose mode...
    echo Current directory: %CD%
    if defined CUSTOM_PATH echo Custom search path: !CUSTOM_PATH!
    echo.
)

echo Searching for .git folder...

REM Determine the starting path for search
if defined CUSTOM_PATH (
    set "SEARCH_PATH=!CUSTOM_PATH!"
) else (
    set "SEARCH_PATH=%CD%"
)

REM Find Git repository
call :find_git_repository "!SEARCH_PATH!"
if errorlevel 1 (
    echo ERROR: No .git folder found!
    echo Please run this script from within a Git repository or its subdirectories.
    if defined CUSTOM_PATH echo Searched from path: !CUSTOM_PATH!
    echo.
    echo Examples:
    echo   cd C:\projects\my-project
    echo   %~nx0
    echo.
    echo   cd C:\projects\my-project\src
    echo   %~nx0
    echo.
    echo   REM Or specify a custom path:
    echo   %~nx0 "C:\projects\my-project"
    echo.
    pause
    exit /b 1
)

REM Create hooks directory if it doesn't exist
set "HOOKS_DIR=!GIT_DIR!\hooks"
if not exist "!HOOKS_DIR!" (
    echo Creating hooks directory: !HOOKS_DIR!
    mkdir "!HOOKS_DIR!" 2>nul
) else (
    if defined VERBOSE_FLAG echo Hooks directory already exists: !HOOKS_DIR!
)

REM Check if hook already exists
set "HOOK_PATH=!HOOKS_DIR!\prepare-commit-msg"
if exist "!HOOK_PATH!" (
    if defined FORCE_FLAG (
        echo Overwriting existing prepare-commit-msg hook...
    ) else (
        echo WARNING: prepare-commit-msg hook already exists!
        echo Use /force to overwrite it.
        echo.
        echo Existing hook location: !HOOK_PATH!
        echo.
        set /p "CONTINUE=Do you want to overwrite it? (y/N): "
        if /i not "!CONTINUE!"=="y" (
            echo Operation cancelled.
            pause
            exit /b 1
        )
    )
)

echo Creating prepare-commit-msg hook in: !HOOKS_DIR!

REM Copy the prepare-commit-msg file
set "SCRIPT_DIR=%~dp0"
set "SOURCE_HOOK_PATH=!SCRIPT_DIR!prepare-commit-msg"

if not exist "!SOURCE_HOOK_PATH!" (
    echo ERROR: prepare-commit-msg file not found at: !SOURCE_HOOK_PATH!
    echo Please ensure the prepare-commit-msg file is in the same directory as this script.
    pause
    exit /b 1
)

if defined VERBOSE_FLAG (
    echo Copying prepare-commit-msg from: !SOURCE_HOOK_PATH!
    echo To: !HOOK_PATH!
)

REM Copy the hook file
copy "!SOURCE_HOOK_PATH!" "!HOOK_PATH!" >nul 2>&1

if defined VERBOSE_FLAG (
    echo.
    echo ========================================
    echo INSTALLATION SUMMARY
    echo ========================================
    echo Search Path: !SEARCH_PATH!
    echo Git Repository: !GIT_DIR!
    echo Hooks Directory: !HOOKS_DIR!
    echo Hook File: !HOOK_PATH!
    echo.
    echo Hook will automatically:
    echo   - Append epic IDs to commit messages for GL-{id}- branches (case-insensitive)
    echo   - Remove Git's default help text
    echo   - Work with git commit, git commit -m, and interactive commits
    echo.
)

echo Successfully created prepare-commit-msg hook in: !HOOKS_DIR!
echo.
echo Hook will automatically append epic IDs to commit messages for branches named GL-{id}-feature-name
echo.
echo TESTING:
echo   1. Create a branch: git checkout -b GL-123-test-feature
echo   2. Make a commit: git commit -m "Add new feature"
echo   3. Check result: git log --oneline -1
echo   4. Expected: "Add new feature - Epic GL-123"
echo   5. Test case-insensitive: git checkout -b gl-456-test (outputs GL-456)
echo   6. Test alphanumeric: git checkout -b Gl-aaa-feature (outputs GL-aaa)
echo.
echo Script completed successfully!
pause
exit /b 0

REM Function to find Git repository
:find_git_repository
set "START_PATH=%~1"
set "CURRENT_PATH=!START_PATH!"

REM Validate the starting path
if not exist "!CURRENT_PATH!" (
    echo ERROR: Specified path does not exist: !CURRENT_PATH!
    exit /b 1
)

if defined VERBOSE_FLAG echo Starting Git repository search from: !CURRENT_PATH!

REM Check current directory and subdirectories recursively
if defined VERBOSE_FLAG echo Searching current directory and subdirectories...
for /r "!CURRENT_PATH!" /d %%i in (.git) do (
    if exist "%%i" (
        if defined VERBOSE_FLAG echo Found .git folder at: %%i
        set "GIT_DIR=%%i"
        exit /b 0
    )
)

REM Check if current directory is .git
if exist "!CURRENT_PATH!\.git" (
    set "GIT_DIR=!CURRENT_PATH!\.git"
    if defined VERBOSE_FLAG echo Found .git folder at current location: !GIT_DIR!
    exit /b 0
)

REM Search parent directories
if defined VERBOSE_FLAG echo Searching parent directories for .git folder...

set "PARENT_PATH=!CURRENT_PATH!"
:search_parents
for %%i in ("!PARENT_PATH!\..") do set "PARENT_PATH=%%~fi"
if "!PARENT_PATH!"=="!CURRENT_PATH!" goto :not_found
if exist "!PARENT_PATH!\.git" (
    set "GIT_DIR=!PARENT_PATH!\.git"
    if defined VERBOSE_FLAG echo Found .git folder at: !GIT_DIR!
    exit /b 0
)
set "CURRENT_PATH=!PARENT_PATH!"
goto :search_parents

:not_found
exit /b 1

REM Show help function
:show_help
echo.
echo ========================================
echo Git Prepare-Commit-Msg Hook Generator
echo ========================================
echo.
echo This script automatically finds your Git repository and installs
echo a prepare-commit-msg hook that appends epic IDs to commit messages.
echo.
echo USAGE:
echo   %~nx0 [options]
echo.
echo OPTIONS:
echo   /help     Show this help message
echo   /verbose  Show detailed output during execution
echo   /force    Overwrite existing prepare-commit-msg hook
echo   /path     Specify custom starting path for Git repository search
echo.
echo EXAMPLES:
echo   %~nx0                           - Install hook from any directory in repo
echo   %~nx0 /verbose                 - Install with detailed output
echo   %~nx0 /force                   - Overwrite existing hook
echo   %~nx0 "C:\projects"           - Search from custom path
echo   %~nx0 "C:\projects" /verbose  - Search with verbose output
echo.
echo WHAT IT DOES:
echo   - Finds .git folder automatically (from current or specified path)
echo   - Searches recursively through subdirectories
echo   - Creates hooks directory if needed
echo   - Installs prepare-commit-msg hook
echo   - Appends "- Epic GL-123" to commits from GL-123-feature branches
echo   - Removes Git's default help text from commit messages
echo.
echo BRANCH NAMING CONVENTION:
echo   GL-123-feature-name    -^> Commit: "Your message - Epic GL-123"
echo   gl-456-bug-fix         -^> Commit: "Your message - Epic GL-456"
echo   Gl-aaa-feature         -^> Commit: "Your message - Epic GL-aaa"
echo   gL-1a1b-test           -^> Commit: "Your message - Epic GL-1a1b"
echo   main                   -^> Commit: "Your message" (no epic added)
echo.
pause
exit /b 0 