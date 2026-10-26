# VimSetUp

A simple Vim setup for Kali Linux, Debian, and Ubuntu with mouse support, Windows-style keyboard shortcuts, and code completion for Python, Bash, C/C++, and C#.

## Features

- **Mouse support:** Use the mouse to navigate and select text.
- **Windows-style shortcuts:** Copy, cut, paste, select all, and undo using familiar keyboard shortcuts.
- **Easy editing:** Delete selected text with Backspace.
- **Code completion:** Use [coc.nvim](https://github.com/neoclide/coc.nvim) to provide code suggestions and language-server features.
- **Language support:** Python, Bash, C/C++, and C#.
- **Automated installation:** Install required packages and configure Vim using one script.
- **Safer updates:** Back up an existing Vim configuration before replacing it and record installation activity in a log.

## Requirements

- Kali Linux, Debian, or Ubuntu.
- An internet connection.
- A user account with `sudo` privileges for installing system packages.
- A compatible version of Node.js for coc.nvim.
- The .NET SDK if you want C# autocomplete.

## Installation

### Option 1: Clone the repository (recommended)

Open a terminal and run:

```bash
git clone https://github.com/bgerard578/VimSetUp.git
cd VimSetUp
chmod +x install-vim-setup.sh
./install-vim-setup.sh
```

Follow any prompts and review the messages displayed by the installer.

**Important:** Run the installer as your normal user. Do not run it with `sudo`; the script will request elevated privileges when needed.

### Option 2: Download the files manually

1. Open the [VimSetUp repository](https://github.com/bgerard578/VimSetUp).
2. Download `install-vim-setup.sh` and `vimrc` using GitHub's Raw view.
3. Save both files in the same directory, keeping their exact filenames.
4. Open a terminal in that directory and run:

```bash
chmod +x install-vim-setup.sh
./install-vim-setup.sh
```

The file named `vimrc` does not need a leading dot. The installer copies it to `~/.vimrc`.

## What the installer does

The installer attempts to:

1. Copy `vimrc` to `~/.vimrc`.
2. Back up an existing `~/.vimrc` before replacing it.
3. Install missing system dependencies, including Vim, Git, Node.js/npm, Python, C/C++ tools, and shell linting/formatting tools.
4. Install coc.nvim if it is not already installed.
5. Install or check the coc.nvim extensions for Python, Bash, and C/C++.
6. Install `csharp-ls` version `0.5.4` if the .NET tooling is available.
7. Add the .NET global tools directory to `PATH` in `~/.bashrc` if necessary.
8. Record installation activity in `~/vim-setup-install.log`.

The installer is designed to continue after recoverable errors. This means that it may finish even if a component fails to install. Read any warnings carefully.

### Node.js requirement

Current coc.nvim versions require a compatible Node.js installation. This setup checks the installed version and warns if it may be too old; it does not automatically upgrade Node.js.

Check your version with:

```bash
node --version
```

If the version is too old, install a compatible Node.js version and rerun the installer.

## Configure C# autocomplete

C# requires an additional one-time configuration step.

### 1. Check the .NET SDK

Run:

```bash
dotnet --version
```

If the command is unavailable, install a compatible .NET SDK before continuing. The VimSetUp installer does not install the .NET SDK itself.

### 2. Configure coc.nvim

Open Vim:

```bash
vim
```

Inside Vim, run:

```vim
:CocConfig
```

Add the following configuration:

```json
{
  "languageserver": {
    "csharp-ls": {
      "command": "csharp-ls",
      "filetypes": ["cs"],
      "rootPatterns": ["*.csproj", ".git"]
    }
  }
}
```

If your configuration already contains settings, merge the `csharp-ls` entry into the existing JSON rather than replacing everything. Ensure the JSON syntax is valid.

This setup uses the generic `csharp-ls` language-server configuration. Avoid configuring a second C# language server for the same files.

Save the configuration and restart Vim.

## Verify the installation

Open Vim:

```bash
vim
```

Run these commands inside Vim:

```vim
:CocInfo
:CocList extensions
:CocList services
```

Check that coc.nvim starts successfully and that the expected language extensions are installed.

## Test autocomplete

### Python

Open a Python file:

```bash
vim test.py
```

Type Python code and check whether suggestions appear.

### Bash

Open a shell script:

```bash
vim test.sh
```

Type a function name or variable and check for language suggestions.

Note: `coc-sh` provides shell-language features inside Vim. Tab completion at the normal terminal prompt is a separate shell feature.

### C and C++

Open a C or C++ source file:

```bash
vim test.c
```

For the best results, use a project with appropriate compilation settings so that `clangd` can identify the required headers and compiler options.

### C#

Create a small .NET console project:

```bash
mkdir -p ~/CSharpTest
cd ~/CSharpTest
dotnet new console
vim Program.cs
```

Inside `Program.cs`, type `Console.` and wait for suggestions. You can also press `Ctrl+Space` to request completion manually.

C# autocomplete depends on the .NET SDK, `csharp-ls`, valid coc.nvim configuration, and a working language-server connection.

## Keyboard shortcuts

The following shortcuts are configured in the supplied `vimrc`.

| Shortcut | Action |
|---|---|
| `Ctrl+C` | Copy selected text in Visual mode |
| `Ctrl+X` | Cut selected text in Visual mode |
| `Ctrl+V` | Paste text |
| `Ctrl+A` | Select all text |
| `Ctrl+Z` | Undo |
| `Backspace` | Delete selected text in Visual mode |
| `Del` | Delete selected text in Visual mode, if configured |

Clipboard behavior can depend on your terminal, Vim build, and clipboard provider. Some terminal environments may require additional configuration.

## Troubleshooting

### Autocomplete is not working

Check the Node.js version:

```bash
node --version
```

Then open Vim and run:

```vim
:CocInfo
:CocList extensions
:CocList services
```

If an extension failed to install, run this inside Vim:

```vim
:CocInstall coc-pyright coc-sh coc-clangd
```

Restart Vim and check again.

### C# autocomplete is not working

Check the .NET SDK:

```bash
dotnet --version
```

Check the language server:

```bash
csharp-ls --version
```

If the `csharp-ls` command cannot be found, verify that the .NET global tools directory is on your `PATH`:

```bash
export PATH="$PATH:$HOME/.dotnet/tools"
```

To make this change persistent for Bash, add the line to `~/.bashrc` if it is not already there, then reload it:

```bash
source ~/.bashrc
```

Also verify the JSON in `:CocConfig` and make sure you are opening a `.cs` file inside a real .NET project.

### Check the installation log

The installer records its activity here:

```bash
cat ~/vim-setup-install.log
```

Review any `[WARN]` messages for components that need attention.

### Restore the previous Vim configuration

If the new configuration causes problems, list available backups:

```bash
ls -lt ~/.vimrc.backup.*
```

Restore the appropriate backup by copying its exact filename, for example:

```bash
cp ~/.vimrc.backup.YYYYMMDD-HHMMSS ~/.vimrc
```

Replace the example filename with the actual backup filename.

## Notes and limitations

- This setup is intended for Kali Linux, Debian, and Ubuntu.
- The installer requires an internet connection to download dependencies and extensions.
- The installer does not automatically upgrade an incompatible Node.js installation.
- The installer does not install the .NET SDK.
- C# autocomplete requires a separate coc.nvim configuration step.
- Existing coc.nvim configuration settings should be preserved when adding C# support.
- The installer attempts to continue after recoverable failures, so a successful script exit does not guarantee that every language server is working.
- Installation behavior may vary depending on the operating system, existing packages, and network connectivity.

## Repository

[https://github.com/bgerard578/VimSetUp](https://github.com/bgerard578/VimSetUp)

## Disclaimer

This project is provided as-is. Review scripts before running them, especially when they install packages or modify configuration files. Test the setup in a virtual machine before deploying it to a system you rely on.
