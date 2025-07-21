# PowerShell script to create prepare-commit-mgs-main with inline content
#
# USAGE EXAMPLES:
#   .\create_prepare_commit_mgs.ps1                    - Run from any directory within Git repo
#   .\create_prepare_commit_mgs.ps1 -Path "C:\projects" - Search from custom path
#   .\create_prepare_commit_mgs.ps1 -Help              - Show this help
#   .\create_prepare_commit_mgs.ps1 -Verbose           - Show detailed output
#   .\create_prepare_commit_mgs.ps1 -Force             - Overwrite existing hook
#
# EXAMPLES:
#   cd C:\projects\my-project
#   ..\scripts\create_prepare_commit_mgs.ps1
#
#   cd C:\projects\my-project\src\components
#   ..\..\..\..\scripts\create_prepare_commit_mgs.ps1
#
#   cd C:\git\game-client-main\.git\hooks
#   .\create_prepare_commit_mgs.ps1
#
#   # Search from custom path
#   .\create_prepare_commit_mgs.ps1 -Path "C:\projects\my-project"
#   .\create_prepare_commit_mgs.ps1 -Path "C:\projects" -Verbose

param(
    [switch]$Help,
    [switch]$Verbose,
    [switch]$Force,
    [string]$Path
)

# Show help if requested
if ($Help) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Git Prepare-Commit-Msg Hook Generator" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This script automatically finds your Git repository and installs" -ForegroundColor White
    Write-Host "a prepare-commit-msg hook that appends epic IDs to commit messages." -ForegroundColor White
    Write-Host ""
    Write-Host "USAGE:" -ForegroundColor Yellow
    Write-Host "  .\$($MyInvocation.MyCommand.Name) [options]" -ForegroundColor White
    Write-Host ""
    Write-Host "OPTIONS:" -ForegroundColor Yellow
    Write-Host "  -Help     Show this help message" -ForegroundColor White
    Write-Host "  -Verbose  Show detailed output during execution" -ForegroundColor White
    Write-Host "  -Force    Overwrite existing prepare-commit-msg hook" -ForegroundColor White
    Write-Host "  -Path     Specify custom starting path for Git repository search" -ForegroundColor White
    Write-Host ""
    Write-Host "EXAMPLES:" -ForegroundColor Yellow
    Write-Host "  .\$($MyInvocation.MyCommand.Name)                           - Install hook from any directory in repo" -ForegroundColor White
    Write-Host "  .\$($MyInvocation.MyCommand.Name) -Verbose                 - Install with detailed output" -ForegroundColor White
    Write-Host "  .\$($MyInvocation.MyCommand.Name) -Force                   - Overwrite existing hook" -ForegroundColor White
    Write-Host "  .\$($MyInvocation.MyCommand.Name) -Path 'C:\projects'      - Search from custom path" -ForegroundColor White
    Write-Host "  .\$($MyInvocation.MyCommand.Name) -Path 'C:\projects' -Verbose - Search with verbose output" -ForegroundColor White
    Write-Host ""
    Write-Host "WHAT IT DOES:" -ForegroundColor Yellow
    Write-Host "  - Finds .git folder automatically (from current or specified path)" -ForegroundColor White
    Write-Host "  - Searches recursively through subdirectories" -ForegroundColor White
    Write-Host "  - Creates hooks directory if needed" -ForegroundColor White
    Write-Host "  - Installs prepare-commit-msg hook" -ForegroundColor White
    Write-Host "  - Appends '- Epic GL-123' to commits from GL-123-feature branches" -ForegroundColor White
    Write-Host "  - Removes Git's default help text from commit messages" -ForegroundColor White
    Write-Host ""
    Write-Host "BRANCH NAMING CONVENTION:" -ForegroundColor Yellow
    Write-Host "  GL-123-feature-name    -> Commit: 'Your message - Epic GL-123'" -ForegroundColor White
    Write-Host "  GL-456-bug-fix         -> Commit: 'Your message - Epic GL-456'" -ForegroundColor White
    Write-Host "  main                   -> Commit: 'Your message' (no epic added)" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to continue"
    exit 0
}

# Function to find Git repository
function Find-GitRepository {
    param([string]$StartPath = $PWD.Path)
    
    $currentPath = $StartPath
    
    # Validate the starting path
    if (-not (Test-Path $currentPath)) {
        Write-Host "ERROR: Specified path does not exist: $currentPath" -ForegroundColor Red
        return $null
    }
    
    if ($Verbose) { 
        Write-Host "Starting Git repository search from: $currentPath" -ForegroundColor Cyan 
    }
    
    # Check current directory and subdirectories recursively
    if ($Verbose) { Write-Host "Searching current directory and subdirectories..." -ForegroundColor Yellow }
    $gitDir = Get-ChildItem -Path $currentPath -Name ".git" -Directory -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($gitDir) {
        $fullPath = Join-Path $currentPath $gitDir
        if ($Verbose) { Write-Host "Found .git folder at: $fullPath" -ForegroundColor Green }
        return $fullPath
    }
    
    # Check if current directory is .git
    if (Test-Path (Join-Path $currentPath ".git")) {
        $gitPath = Join-Path $currentPath ".git"
        if ($Verbose) { Write-Host "Found .git folder at current location: $gitPath" -ForegroundColor Green }
        return $gitPath
    }
    
    # Search parent directories
    if ($Verbose) { Write-Host "Searching parent directories for .git folder..." -ForegroundColor Yellow }
    
    $parentPath = Split-Path -Parent $currentPath
    while ($parentPath -and $parentPath -ne (Split-Path -Parent $parentPath)) {
        $gitPath = Join-Path $parentPath ".git"
        if (Test-Path $gitPath) {
            if ($Verbose) { Write-Host "Found .git folder at: $gitPath" -ForegroundColor Green }
            return $gitPath
        }
        $parentPath = Split-Path -Parent $parentPath
    }
    
    return $null
}

# Main script execution
if ($Verbose) {
    Write-Host "Running in verbose mode..." -ForegroundColor Cyan
    Write-Host "Current directory: $($PWD.Path)" -ForegroundColor White
    if ($Path) {
        Write-Host "Custom search path: $Path" -ForegroundColor White
    }
    Write-Host ""
}

Write-Host "Searching for .git folder..." -ForegroundColor Yellow

# Determine the starting path for search
$searchPath = if ($Path) { $Path } else { $PWD.Path }

# Find Git repository
$gitDir = Find-GitRepository -StartPath $searchPath

if (-not $gitDir) {
    Write-Host "ERROR: No .git folder found!" -ForegroundColor Red
    Write-Host "Please run this script from within a Git repository or its subdirectories." -ForegroundColor White
    if ($Path) {
        Write-Host "Searched from path: $Path" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  cd C:\projects\my-project" -ForegroundColor White
    Write-Host "  .\$($MyInvocation.MyCommand.Name)" -ForegroundColor White
    Write-Host ""
    Write-Host "  cd C:\projects\my-project\src" -ForegroundColor White
    Write-Host "  .\$($MyInvocation.MyCommand.Name)" -ForegroundColor White
    Write-Host ""
    Write-Host "  # Or specify a custom path:" -ForegroundColor Yellow
    Write-Host "  .\$($MyInvocation.MyCommand.Name) -Path 'C:\projects\my-project'" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to continue"
    exit 1
}

# Create hooks directory if it doesn't exist
$hooksDir = Join-Path $gitDir "hooks"
if (-not (Test-Path $hooksDir)) {
    Write-Host "Creating hooks directory: $hooksDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null
}
else {
    if ($Verbose) { Write-Host "Hooks directory already exists: $hooksDir" -ForegroundColor Green }
}

# Check if hook already exists
$hookPath = Join-Path $hooksDir "prepare-commit-msg"
if (Test-Path $hookPath) {
    if ($Force) {
        Write-Host "Overwriting existing prepare-commit-msg hook..." -ForegroundColor Yellow
    }
    else {
        Write-Host "WARNING: prepare-commit-msg hook already exists!" -ForegroundColor Red
        Write-Host "Use -Force to overwrite it." -ForegroundColor White
        Write-Host ""
        Write-Host "Existing hook location: $hookPath" -ForegroundColor White
        Write-Host ""
        $continue = Read-Host "Do you want to overwrite it? (y/N)"
        if ($continue -notmatch '^[Yy]$') {
            Write-Host "Operation cancelled." -ForegroundColor Yellow
            Read-Host "Press Enter to continue"
            exit 1
        }
    }
}

Write-Host "Creating prepare-commit-msg hook in: $hooksDir" -ForegroundColor Yellow

# Copy the prepare-commit-msg file
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceHookPath = Join-Path $scriptDir "prepare-commit-msg"

if (-not (Test-Path $sourceHookPath)) {
    Write-Host "ERROR: prepare-commit-msg file not found at: $sourceHookPath" -ForegroundColor Red
    Write-Host "Please ensure the prepare-commit-msg file is in the same directory as this script." -ForegroundColor White
    Read-Host "Press Enter to continue"
    exit 1
}

if ($Verbose) {
    Write-Host "Copying prepare-commit-msg from: $sourceHookPath" -ForegroundColor Yellow
    Write-Host "To: $hookPath" -ForegroundColor Yellow
}

# Copy the hook file
Copy-Item -Path $sourceHookPath -Destination $hookPath -Force

# Make the hook executable (for Unix-like systems)
Write-Host "Making hook executable..." -ForegroundColor Yellow
try {
    # Set executable permission (works on Unix-like systems)
    if ($IsLinux -or $IsMacOS) {
        chmod +x $hookPath
    }
    else {
        # On Windows, try to set executable attribute
        attrib +x $hookPath 2>$null
    }
}
catch {
    if ($Verbose) { Write-Host "Note: Could not set executable permissions (this is normal on Windows)" -ForegroundColor Yellow }
}

if ($Verbose) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "INSTALLATION SUMMARY" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Search Path: $searchPath" -ForegroundColor White
    Write-Host "Git Repository: $gitDir" -ForegroundColor White
    Write-Host "Hooks Directory: $hooksDir" -ForegroundColor White
    Write-Host "Hook File: $hookPath" -ForegroundColor White
    Write-Host ""
    Write-Host "Hook will automatically:" -ForegroundColor Yellow
    Write-Host "  - Append epic IDs to commit messages for GL-{number}- branches" -ForegroundColor White
    Write-Host "  - Remove Git's default help text" -ForegroundColor White
    Write-Host "  - Work with git commit, git commit -m, and interactive commits" -ForegroundColor White
    Write-Host ""
}

Write-Host "Successfully created prepare-commit-msg hook in: $hooksDir" -ForegroundColor Green
Write-Host ""
Write-Host "Hook will automatically append epic IDs to commit messages for branches named GL-{number}-feature-name" -ForegroundColor White
Write-Host ""
Write-Host "TESTING:" -ForegroundColor Yellow
Write-Host "  1. Create a branch: git checkout -b GL-123-test-feature" -ForegroundColor White
Write-Host "  2. Make a commit: git commit -m 'Add new feature'" -ForegroundColor White
Write-Host "  3. Check result: git log --oneline -1" -ForegroundColor White
Write-Host "  4. Expected: 'Add new feature - Epic GL-123'" -ForegroundColor White
Write-Host ""
Write-Host "Script completed successfully!" -ForegroundColor Green
Read-Host "Press Enter to continue" 