# Git Prepare-Commit-Msg Hook Generator

Automatically installs a Git `prepare-commit-msg` hook that appends epic IDs to commit messages based on branch naming conventions.

## 🎯 What It Does

This tool automatically:

- **Finds your Git repository** from any subdirectory or custom path
- **Searches recursively** through directories to locate `.git` folders
- **Creates the hooks directory** if it doesn't exist
- **Installs a prepare-commit-msg hook** that:
  - Appends `- Epic GL-{id}` to commit messages from branches named `GL-{id}-feature-name`
  - Removes Git's default help text from commit messages
  - Works with `git commit`, `git commit -m`, and interactive commits

## 📁 Files

- `create_prepare_commit_mgs.ps1` - PowerShell script (with custom path support)
- `README.md` - This guide

## 🚀 Quick Start

```powershell
# From any directory in your Git repository
.\create_prepare_commit_mgs.ps1

# Search from custom path
.\create_prepare_commit_mgs.ps1 -Path "C:\projects\my-project"

# With options
.\create_prepare_commit_mgs.ps1 -Help
.\create_prepare_commit_mgs.ps1 -Verbose
.\create_prepare_commit_mgs.ps1 -Force
```

## 📋 Command Line Options

| Option      | PowerShell | Description                                            |
| ----------- | ---------- | ------------------------------------------------------ |
| Help        | `-Help`    | Show detailed help and usage information               |
| Verbose     | `-Verbose` | Show detailed output during installation               |
| Force       | `-Force`   | Overwrite existing hook without prompting              |
| Custom Path | `-Path`    | Specify custom starting path for Git repository search |

## 🏷️ Branch Naming Convention

The hook automatically detects branches following the pattern `GL-{number}-feature-name` and appends the epic ID to commit messages.

| Branch Name           | Commit Message           | Result                                   |
| --------------------- | ------------------------ | ---------------------------------------- |
| `GL-123-feature-name` | `"Add new feature"`      | `"Add new feature - Epic GL-123"`        |
| `GL-456-bug-fix`      | `"Fix critical bug"`     | `"Fix critical bug - Epic GL-456"`       |
| `main`                | `"Update documentation"` | `"Update documentation"` (no epic added) |
| `develop`             | `"Merge feature branch"` | `"Merge feature branch"` (no epic added) |

## 🧪 Testing the Hook

After installation, test the hook with these commands:

```bash
# 1. Create a test branch with epic ID
git checkout -b GL-123-test-feature

# 2. Make some changes and commit
echo "test" > test.txt
git add test.txt
git commit -m "Add test file"

# 3. Check the commit message
git log --oneline -1
# Expected: "Add test file - Epic GL-123"

# 4. Test on main branch (should not add epic)
git checkout main
echo "another test" > test2.txt
git add test2.txt
git commit -m "Add another test file"
git log --oneline -1
# Expected: "Add another test file" (no epic added)
```

## 📖 Detailed Usage Examples

### Basic Installation

```powershell
# Navigate to your project
cd C:\projects\my-project

# Run the script from any subdirectory
.\create_prepare_commit_mgs.ps1
```

### From Subdirectories

```powershell
# Works from any subdirectory within the Git repository
cd C:\projects\my-project\src\components\ui
..\..\..\..\scripts\create_prepare_commit_mgs.ps1
```

### Custom Path Search

```powershell
# Search from a specific directory
.\create_prepare_commit_mgs.ps1 -Path "C:\projects"

# Search from a specific project
.\create_prepare_commit_mgs.ps1 -Path "C:\projects\my-project"

# Search with verbose output
.\create_prepare_commit_mgs.ps1 -Path "C:\projects" -Verbose

# Search from custom path and force overwrite
.\create_prepare_commit_mgs.ps1 -Path "C:\projects" -Force

# Search from custom path with all options
.\create_prepare_commit_mgs.ps1 -Path "C:\projects" -Verbose -Force
```

### Verbose Installation

```powershell
# See detailed output during installation
.\create_prepare_commit_mgs.ps1 -Verbose

# See detailed output with custom path
.\create_prepare_commit_mgs.ps1 -Path "C:\projects" -Verbose
```

### Force Overwrite

```powershell
# Overwrite existing hook without prompting
.\create_prepare_commit_mgs.ps1 -Force

# Overwrite existing hook from custom path
.\create_prepare_commit_mgs.ps1 -Path "C:\projects" -Force
```

## 🔧 How It Works

### 1. Git Repository Detection

The script automatically finds your `.git` folder by:

- **Current directory search**: Starting from current or specified path
- **Recursive subdirectory search**: Searching through all subdirectories
- **Parent directory search**: Searching up the directory tree if needed
- **Path validation**: Verifying custom paths exist before searching

### 2. Hook Installation

- Creates the `hooks` directory if it doesn't exist
- Generates the `prepare-commit-msg` hook script
- Sets appropriate file permissions
- Provides clear feedback on success or failure

### 3. Hook Functionality

The installed hook:

- Extracts the current branch name using `git rev-parse --abbrev-ref HEAD`
- Checks if the branch matches the pattern `GL-{number}-`
- Extracts the epic ID using regex
- Appends `- Epic GL-{id}` to the first line of the commit message
- Removes Git's default help text using Perl

## 📝 Generated Hook Content

The script generates a `prepare-commit-msg` hook with this functionality:

```bash
#!/bin/sh
# Get the current branch name
git_branch=$(git rev-parse --abbrev-ref HEAD)

# Prepare the text to append
append_text=""
if echo "$git_branch" | grep -Eq '^GL-[0-9]+-'; then
  epic_id=$(echo "$git_branch" | sed -n 's/^GL-\([0-9]\+\)-.*/\1/p')
  if [ -n "$epic_id" ]; then
    append_text="- Epic GL-$epic_id"
  fi
fi

if [ -n "$append_text" ]; then
  # Append to the end of the first line (commit title)
  sed -i "1s/$/ $append_text/" "$COMMIT_MSG_FILE"
fi

# Remove Git's default help text
/usr/bin/perl -i.bak -ne 'print unless(m/^. Please enter the commit message/..m/^#$/)' "$COMMIT_MSG_FILE"
```

## 🚨 Troubleshooting

### "No .git folder found" Error

**Problem**: Script can't find your Git repository.

**Solutions**:

1. Make sure you're running the script from within a Git repository
2. Check that the `.git` folder exists in your project root
3. Try running `git status` to verify you're in a Git repository
4. Use `-Path` parameter to specify a custom search location
5. Use `-Verbose` to see detailed search information

### "Specified path does not exist" Error

**Problem**: Custom path provided with `-Path` doesn't exist.

**Solutions**:

1. Verify the path exists and is accessible
2. Check for typos in the path
3. Use absolute paths for better reliability
4. Ensure you have read permissions for the specified directory

### "Hook already exists" Warning

**Problem**: A `prepare-commit-msg` hook already exists.

**Solutions**:

1. Use `-Force` to overwrite
2. Manually backup and remove the existing hook first
3. Review the existing hook to avoid conflicts

### Hook Not Working

**Problem**: Epic IDs are not being appended to commit messages.

**Solutions**:

1. Verify the hook is executable: `ls -la .git/hooks/prepare-commit-msg`
2. Check branch naming follows the pattern: `GL-{number}-feature-name`
3. Test with verbose mode to see detailed output
4. Check Git version compatibility (works with Git 1.7+)

## 🔄 Updating the Hook

To update an existing hook:

```powershell
# Basic update
.\create_prepare_commit_mgs.ps1 -Force

# Update with custom path
.\create_prepare_commit_mgs.ps1 -Path "C:\projects\my-project" -Force
```

## 🗂️ File Locations

After installation, the hook will be located at:

```
{your-project}/.git/hooks/prepare-commit-msg
```

## 📋 Requirements

- **Git**: Version 1.7 or higher
- **PowerShell**: PowerShell 3.0 or higher
- **Windows**: Windows 7 or higher
- **Unix-like systems**: Compatible with WSL, Git Bash, etc.

## 🆕 Features

### Custom Path Support

The PowerShell script supports searching from custom paths:

```powershell
# Search from any directory without changing current location
.\create_prepare_commit_mgs.ps1 -Path "D:\git3\game-clients\wild-west-client"

# Search with verbose output
.\create_prepare_commit_mgs.ps1 -Path "C:\projects" -Verbose

# Search and force overwrite
.\create_prepare_commit_mgs.ps1 -Path "C:\projects" -Force
```

**Benefits**:

- ✅ **Flexible**: Search from any directory without changing current location
- ✅ **Recursive**: Searches through all subdirectories from the specified path
- ✅ **Error Handling**: Validates custom paths and provides clear error messages
- ✅ **Verbose Support**: Shows detailed search information when using custom paths

## 🤝 Contributing

To contribute to this project:

1. Fork the repository
2. Create a feature branch: `git checkout -b GL-123-new-feature`
3. Make your changes
4. Commit with a descriptive message: `git commit -m "Add new feature - Epic GL-123"`
5. Push to your fork: `git push origin GL-123-new-feature`
6. Create a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🆘 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Run the script with verbose mode for detailed output
3. Verify your Git repository structure
4. Check that your branch naming follows the convention
5. Try using the `-Path` parameter for custom search locations

## 🔗 Related Tools

- [Git Hooks Documentation](https://git-scm.com/docs/githooks)
- [Prepare-Commit-Msg Hook Guide](https://git-scm.com/docs/githooks#_prepare_commit_msg)
- [Git Branch Naming Conventions](https://nvie.com/posts/a-successful-git-branching-model/)

---

**Happy committing! 🚀**
