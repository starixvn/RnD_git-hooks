# Git Prepare-Commit-Msg Hook Generator

Automatically installs a Git `prepare-commit-msg` hook that appends epic IDs to commit messages based on branch naming conventions.

## 🎯 What It Does

This tool automatically:

- **Finds your Git repository** from any subdirectory or custom path
- **Searches recursively** through directories to locate `.git` folders
- **Excludes node_modules** directories to avoid false positives
- **Creates the hooks directory** if it doesn't exist
- **Installs a prepare-commit-msg hook** that:
  - Appends `- Epic GL-{id}` to commit messages from branches named `GL-{id}-feature-name`
  - Removes Git's default help text from commit messages
  - Works with `git commit`, `git commit -m`, and interactive commits
- **Supports global installation** for system-wide hook management

## 📁 Files

- `create_prepare_commit_mgs.bat` - Batch file version (Windows command prompt)
- `prepare-commit-msg` - The Git hook script that gets installed
- `README.md` - This guide

## 🚀 Quick Start

```batch
# From any directory in your Git repository
create_prepare_commit_mgs.bat

# Install globally (recommended)
create_prepare_commit_mgs.bat /global

# Search from custom path
create_prepare_commit_mgs.bat "C:\projects\my-project"

# With options
create_prepare_commit_mgs.bat /verbose
create_prepare_commit_mgs.bat /global /verbose
```

## 📋 Command Line Options

| Option      | Batch File | Description                                              |
| ----------- | ---------- | -------------------------------------------------------- |
| Verbose     | `/verbose` | Show detailed output during installation                 |
| Global      | `/global`  | Install hook globally for all repositories (recommended) |
| Custom Path | First arg  | Specify custom starting path for Git repository search   |

**Note**: The script always overwrites existing hooks without prompting.

## 🌍 Global Installation (Recommended)

The script now supports global installation, which is the recommended approach:

```batch
# Install globally for all repositories
create_prepare_commit_mgs.bat /global

# Install globally with verbose output
create_prepare_commit_mgs.bat /global /verbose
```

### Benefits of Global Installation:

✅ **One-time setup** - Install once, works everywhere  
✅ **No need to copy to each repository**  
✅ **Automatic for new repositories**  
✅ **Easier maintenance** - update one file, affects all repos  
✅ **Consistent behavior** across all your Git repositories

### How Global Installation Works:

1. **Creates global hooks directory** at `%USERPROFILE%\.git\hooks`
2. **Copies the prepare-commit-msg hook** to the global location
3. **Sets Git's global hooks path** using `git config --global core.hooksPath`
4. **Applies to ALL repositories** on your system automatically

### Testing Global Installation:

After installing globally, test it in any repository:

```bash
git checkout -b GL-123-test-feature
git commit -m "Add new feature"
git log --oneline -1
# Expected: "Add new feature - Epic GL-123"
```

## 🏷️ Branch Naming Convention

The hook automatically detects branches following the pattern `GL-{id}-feature-name` and appends the epic ID to commit messages. The prefix is case-insensitive (accepts GL, gl, Gl, gL) but always outputs "GL" in uppercase. Supports alphanumeric IDs.

| Branch Name           | Commit Message           | Result                                   |
| --------------------- | ------------------------ | ---------------------------------------- |
| `GL-123-feature-name` | `"Add new feature"`      | `"Add new feature - Epic GL-123"`        |
| `gl-456-bug-fix`      | `"Fix critical bug"`     | `"Fix critical bug - Epic GL-456"`       |
| `Gl-aaa-feature`      | `"Add new feature"`      | `"Add new feature - Epic GL-aaa"`        |
| `gL-1a1b-test`        | `"Test feature"`         | `"Test feature - Epic GL-1a1b"`          |
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

# 4. Test case-insensitive branch naming
git checkout -b gl-456-bug-fix
echo "bug fix" > fix.txt
git add fix.txt
git commit -m "Fix critical bug"
git log --oneline -1
# Expected: "Fix critical bug - Epic GL-456"

# 5. Test alphanumeric IDs
git checkout -b Gl-aaa-feature
echo "feature" > feature.txt
git add feature.txt
git commit -m "Add new feature"
git log --oneline -1
# Expected: "Add new feature - Epic GL-aaa"

# 6. Test on main branch (should not add epic)
git checkout main
echo "another test" > test2.txt
git add test2.txt
git commit -m "Add another test file"
git log --oneline -1
# Expected: "Add another test file" (no epic added)
```

## 📖 Detailed Usage Examples

### Global Installation (Recommended)

```batch
# Install globally for all repositories
create_prepare_commit_mgs.bat /global

# Install globally with verbose output
create_prepare_commit_mgs.bat /global /verbose
```

### Basic Installation

```batch
# Navigate to your project
cd C:\projects\my-project

# Run the script from any subdirectory
create_prepare_commit_mgs.bat
```

### From Subdirectories

```batch
# Works from any subdirectory within the Git repository
cd C:\projects\my-project\src\components\ui
..\..\..\..\scripts\create_prepare_commit_mgs.bat
```

### Custom Path Search

```batch
# Search from a specific directory
create_prepare_commit_mgs.bat "C:\projects"

# Search from a specific project
create_prepare_commit_mgs.bat "C:\projects\my-project"

# Search with verbose output
create_prepare_commit_mgs.bat "C:\projects" /verbose

# Search from custom path
create_prepare_commit_mgs.bat "C:\projects"

# Search from custom path with verbose
create_prepare_commit_mgs.bat "C:\projects" /verbose
```

### Verbose Installation

```batch
# See detailed output during installation
create_prepare_commit_mgs.bat /verbose

# See detailed output with custom path
create_prepare_commit_mgs.bat "C:\projects" /verbose

# See detailed output with global installation
create_prepare_commit_mgs.bat /global /verbose
```

### Default Overwrite Behavior

```batch
# The script always overwrites existing hooks without prompting
create_prepare_commit_mgs.bat

# Overwrite existing hook from custom path
create_prepare_commit_mgs.bat "C:\projects"
```

## 🔧 How It Works

### 1. Git Repository Detection

The script automatically finds your `.git` folder by:

- **Current directory search**: Starting from current or specified path
- **Recursive subdirectory search**: Searching through all subdirectories
- **Parent directory search**: Searching up the directory tree if needed
- **Path validation**: Verifying custom paths exist before searching
- **node_modules exclusion**: Automatically skips `.git` folders inside `node_modules` directories

### 2. Hook Installation

- Creates the `hooks` directory if it doesn't exist
- Copies the `prepare-commit-msg` hook script from the script directory
- Sets appropriate file permissions
- Provides clear feedback on success or failure
- **Improved error handling**: Continues processing other repositories if one fails

### 3. Global Installation

When using `/global`:

- Detects or creates Git's global hooks directory
- Copies the hook to the global location
- Sets `git config --global core.hooksPath`
- Applies to all repositories on the system

### 4. Hook Functionality

The installed hook:

- Extracts the current branch name using `git rev-parse --abbrev-ref HEAD`
- Checks if the branch matches the pattern `GL-{alphanumeric}-` (case-insensitive)
- Extracts the epic ID using regex
- Appends `- Epic GL-{id}` to the first line of the commit message
- Removes Git's default help text using Perl

## 📝 Hook Content

The `prepare-commit-msg` file contains this functionality:

```bash
#!/bin/sh
# Get the current branch name
git_branch=$(git rev-parse --abbrev-ref HEAD)

# Prepare the text to append
append_text=""
# Case-insensitive match for GL/gl/Gl/gL followed by alphanumeric ID
if echo "$git_branch" | grep -Eiq '^[Gg][Ll]-[a-zA-Z0-9]+-'; then
  # Extract the ID (alphanumeric characters after GL- and before the next -)
  epic_id=$(echo "$git_branch" | sed -n 's/^[Gg][Ll]-\([a-zA-Z0-9]\+\)-.*/\1/p')
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

### "prepare-commit-msg file not found" Error

**Problem**: Script can't find the `prepare-commit-msg` file.

**Solutions**:

1. Ensure the `prepare-commit-msg` file is in the same directory as the batch file
2. Check that the file name is exactly `prepare-commit-msg` (no extension)
3. Verify the file exists and is readable
4. Run the script from the directory containing both files

### "No .git folder found" Error

**Problem**: Script can't find your Git repository.

**Solutions**:

1. Make sure you're running the script from within a Git repository
2. Check that the `.git` folder exists in your project root
3. Try running `git status` to verify you're in a Git repository
4. Use custom path parameter to specify a custom search location
5. Use `/verbose` to see detailed search information

### "Specified path does not exist" Error

**Problem**: Custom path provided doesn't exist.

**Solutions**:

1. Verify the path exists and is accessible
2. Check for typos in the path
3. Use absolute paths for better reliability
4. Ensure you have read permissions for the specified directory

### "Failed to create global hooks directory" Error

**Problem**: Global installation failed due to permissions or path issues.

**Solutions**:

1. Run the script as administrator if needed
2. Check that `%USERPROFILE%` is accessible
3. Verify Git is properly installed
4. Try manual installation: `git config --global core.hooksPath "%USERPROFILE%\.git\hooks"`

### "Hook already exists" Information

**Note**: The script automatically overwrites existing `prepare-commit-msg` hooks without prompting.

**If you want to preserve existing hooks**:

1. Manually backup the existing hook first: `copy .git\hooks\prepare-commit-msg .git\hooks\prepare-commit-msg.backup`
2. Run the script to install the new hook
3. Review and merge any custom logic from your backup if needed

### Hook Not Working

**Problem**: Epic IDs are not being appended to commit messages.

**Solutions**:

1. Verify the hook is executable: `ls -la .git/hooks/prepare-commit-msg`
2. Check branch naming follows the pattern: `GL-{id}-feature-name` (case-insensitive, alphanumeric IDs)
3. Test with verbose mode to see detailed output
4. Check Git version compatibility (works with Git 1.7+)
5. For global installation, verify: `git config --global core.hooksPath`

## 🔄 Updating the Hook

To update an existing hook:

```batch
# Basic update (always overwrites existing hooks)
create_prepare_commit_mgs.bat

# Update with custom path
create_prepare_commit_mgs.bat "C:\projects\my-project"

# Update global installation
create_prepare_commit_mgs.bat /global
```

## 🗂️ File Locations

After installation, the hook will be located at:

```
# Per-repository installation
{your-project}/.git/hooks/prepare-commit-msg

# Global installation
%USERPROFILE%/.git/hooks/prepare-commit-msg
```

## 📋 Requirements

- **Git**: Version 1.7 or higher
- **Windows**: Windows 7 or higher
- **Batch File**: Windows Command Prompt (no additional requirements)
- **Unix-like systems**: Compatible with WSL, Git Bash, etc.
- **Files**: Both `create_prepare_commit_mgs.bat` and `prepare-commit-msg` must be in the same directory

## 🆕 Features

### Global Installation

The script now supports global installation for system-wide hook management:

```batch
# Install globally for all repositories
create_prepare_commit_mgs.bat /global

# Install globally with verbose output
create_prepare_commit_mgs.bat /global /verbose
```

**Benefits**:

- ✅ **One-time setup** - Install once, works everywhere
- ✅ **Automatic for new repositories** - No need to install per repository
- ✅ **Easier maintenance** - Update one file, affects all repos
- ✅ **Consistent behavior** - Same hook behavior across all repositories

### node_modules Exclusion

The script now automatically excludes `.git` folders found inside `node_modules` directories:

- **Prevents false positives** from npm packages that include Git metadata
- **Faster processing** by skipping irrelevant directories
- **Cleaner output** with fewer irrelevant results

### Improved Error Handling

Enhanced error handling with flag-based processing:

- **Continues processing** other repositories if one fails
- **Better error messages** with specific failure reasons
- **Graceful degradation** - partial success is better than complete failure
- **Verbose logging** for debugging installation issues

### Custom Path Support

The batch file supports searching from custom paths:

```batch
# Search from any directory without changing current location
create_prepare_commit_mgs.bat "D:\git3\game-clients\wild-west-client"

# Search with verbose output
create_prepare_commit_mgs.bat "C:\projects" /verbose

# Search and install (always overwrites existing hooks)
create_prepare_commit_mgs.bat "C:\projects"
```

**Benefits**:

- ✅ **Flexible**: Search from any directory without changing current location
- ✅ **Recursive**: Searches through all subdirectories from the specified path
- ✅ **Error Handling**: Validates custom paths and provides clear error messages
- ✅ **Verbose Support**: Shows detailed search information when using custom paths
- ✅ **Simple**: No additional requirements beyond Windows Command Prompt

### Multiple Repository Support

The script can find and install hooks in multiple Git repositories:

- Searches recursively through directories
- Finds all `.git` folders in the search path
- Installs the hook in each repository found
- Provides a count of installations completed
- **Improved reliability** - continues processing even if some repositories fail

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
5. Try using custom path parameter for custom search locations
6. For global installation issues, check Git's global configuration

## 🔗 Related Tools

- [Git Hooks Documentation](https://git-scm.com/docs/githooks)
- [Prepare-Commit-Msg Hook Guide](https://git-scm.com/docs/githooks#_prepare_commit_msg)
- [Git Branch Naming Conventions](https://nvie.com/posts/a-successful-git-branching-model/)

---

**Happy committing! 🚀**
