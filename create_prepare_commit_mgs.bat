@echo off
setlocal enabledelayedexpansion

REM Batch script to create prepare-commit-msg hook with inline content
REM
REM USAGE EXAMPLES:
REM   create_prepare_commit_mgs.bat                    - Run from any directory within Git repo
REM   create_prepare_commit_mgs.bat "C:\projects"     - Search from custom path
REM   create_prepare_commit_mgs.bat /verbose           - Show detailed output
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
set "CUSTOM_PATH="

REM Parse command line arguments
:parse_args
if "%~1"=="" goto :end_parse
REM if /i "%~1"=="-help" set "HELP_FLAG=1"
REM if /i "%~1"=="--help" set "HELP_FLAG=1"
REM if /i "%~1"=="/help" set "HELP_FLAG=1"
if /i "%~1"=="-verbose" set "VERBOSE_FLAG=1"
if /i "%~1"=="--verbose" set "VERBOSE_FLAG=1"
if /i "%~1"=="/verbose" set "VERBOSE_FLAG=1"
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
if not "%~1"=="-verbose" if not "%~1"=="--verbose" if not "%~1"=="/verbose" (
    if not "%~1"=="-path" if not "%~1"=="--path" if not "%~1"=="/path" (
        if not defined CUSTOM_PATH set "CUSTOM_PATH=%~1"
    )
)
shift
goto :parse_args
:end_parse

REM Show help if requested
REM if defined HELP_FLAG goto :show_help

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

REM Find all Git repositories
call :find_all_git_repositories "!SEARCH_PATH!"
if errorlevel 1 (
    echo ERROR: No .git folders found!
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

REM Install hook in all found repositories
set "INSTALLED_COUNT=0"
for %%i in (!GIT_DIRS!) do (
    set "GIT_DIR=%%i"
    set "HOOKS_DIR=!GIT_DIR!\hooks"
    
    if defined VERBOSE_FLAG echo Processing repository: !GIT_DIR!
    
    REM Create hooks directory if it doesn't exist
    if not exist "!HOOKS_DIR!" (
        echo Creating hooks directory: !HOOKS_DIR!
        mkdir "!HOOKS_DIR!" 2>nul
    ) else (
        if defined VERBOSE_FLAG echo Hooks directory already exists: !HOOKS_DIR!
    )
    
    REM Check if hook already exists
    set "HOOK_PATH=!HOOKS_DIR!\prepare-commit-msg"
    if exist "!HOOK_PATH!" (
        echo Overwriting existing prepare-commit-msg hook in: !HOOKS_DIR!
    ) else (
        echo Installing prepare-commit-msg hook in: !HOOKS_DIR!
    )
    
    REM Copy the prepare-commit-msg file
    set "SCRIPT_DIR=%~dp0"
    if defined VERBOSE_FLAG echo Script directory: "!SCRIPT_DIR!"
    set "SOURCE_HOOK_PATH=!SCRIPT_DIR!prepare-commit-msg"
    if defined VERBOSE_FLAG echo Source hook path: "!SOURCE_HOOK_PATH!"
    
    REM Alternative method to get script directory if %~dp0 fails
    if not exist "!SOURCE_HOOK_PATH!" (
        set "SCRIPT_DIR=%CD%\"
        set "SOURCE_HOOK_PATH=!SCRIPT_DIR!prepare-commit-msg"
        if defined VERBOSE_FLAG echo Alternative script directory: "!SCRIPT_DIR!"
        if defined VERBOSE_FLAG echo Alternative source hook path: "!SOURCE_HOOK_PATH!"
    )
    
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
    
    REM Copy the hook file and show status
    echo Copying prepare-commit-msg hook...
    copy "!SOURCE_HOOK_PATH!" "!HOOK_PATH!" >nul 2>&1
    if errorlevel 1 (
        echo ERROR: Failed to copy prepare-commit-msg hook to: !HOOK_PATH!
        echo Please check file permissions and try again.
        pause
        exit /b 1
    ) else (
        echo Successfully copied prepare-commit-msg hook to: !HOOK_PATH!
    )
    
    set /a "INSTALLED_COUNT+=1"
    echo Successfully installed hook in: !HOOKS_DIR!
    echo.
)

if defined VERBOSE_FLAG (
    echo.
    echo ========================================
    echo INSTALLATION SUMMARY
    echo ========================================
    echo Search Path: !SEARCH_PATH!
    echo Total Repositories Found: !INSTALLED_COUNT!
    echo.
    echo Hook will automatically:
    echo   - Append epic IDs to commit messages for GL-{id}- branches (case-insensitive)
    echo   - Remove Git's default help text
    echo   - Work with git commit, git commit -m, and interactive commits
    echo.
)

echo Successfully installed prepare-commit-msg hook in !INSTALLED_COUNT! repositories!
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

REM Function to find all Git repositories
:find_all_git_repositories
set "START_PATH=%~1"
set "CURRENT_PATH=!START_PATH!"
set "GIT_DIRS="
set "FOUND_COUNT=0"

REM Validate the starting path
if not exist "!CURRENT_PATH!" (
    echo ERROR: Specified path does not exist: !CURRENT_PATH!
    exit /b 1
)

if defined VERBOSE_FLAG echo Starting Git repository search from: !CURRENT_PATH!

REM Check current directory and subdirectories recursively
if defined VERBOSE_FLAG echo Searching current directory and subdirectories...
for /f "delims=" %%i in ('dir "!CURRENT_PATH!" /s /b /ad ^| findstr "\\\.git$"') do (
    if exist "%%i" (
        if defined VERBOSE_FLAG echo Found .git folder at: %%i
        if defined GIT_DIRS (
            set "GIT_DIRS=!GIT_DIRS! %%i"
        ) else (
            set "GIT_DIRS=%%i"
        )
        set /a "FOUND_COUNT+=1"
    )
)

REM Check if current directory is .git
if exist "!CURRENT_PATH!\.git" (
    if defined VERBOSE_FLAG echo Found .git folder at current location: !CURRENT_PATH!\.git
    if defined GIT_DIRS (
        set "GIT_DIRS=!CURRENT_PATH!\.git !GIT_DIRS!"
    ) else (
        set "GIT_DIRS=!CURRENT_PATH!\.git"
    )
    set /a "FOUND_COUNT+=1"
)

REM Search parent directories
if defined VERBOSE_FLAG echo Searching parent directories for .git folder...

set "PARENT_PATH=!CURRENT_PATH!"
:search_parents
for %%i in ("!PARENT_PATH!\..") do set "PARENT_PATH=%%~fi"
if "!PARENT_PATH!"=="!CURRENT_PATH!" goto :check_results
if exist "!PARENT_PATH!\.git" (
    if defined VERBOSE_FLAG echo Found .git folder at: !PARENT_PATH!\.git
    if defined GIT_DIRS (
        set "GIT_DIRS=!PARENT_PATH!\.git !GIT_DIRS!"
    ) else (
        set "GIT_DIRS=!PARENT_PATH!\.git"
    )
    set /a "FOUND_COUNT+=1"
)
set "CURRENT_PATH=!PARENT_PATH!"
goto :search_parents

:check_results
if !FOUND_COUNT! gtr 0 (
    if defined VERBOSE_FLAG echo Found !FOUND_COUNT! Git repositories
    exit /b 0
) else (
    exit /b 1
)

 