# VimSetUp
Adds mouse support, Windows hotkeys, and code prediction and auto complete to vim.

Vim Autocomplete Setup (Kali / Debian / Ubuntu)
This repository contains:
- vimrc — my Vim configuration (mouse support, Windows-style editing shortcuts, and coc.nvim key mappings).
- install-vim-setup.sh — an installer that copies vimrc to ~/.vimrc and installs/checks the dependencies.
The script is designed to be safe to rerun. It skips components that are already installed, backs up an existing ~/.vimrc before replacing it, logs activity to ~/vim-setup-install.log, and continues after recoverable installation failures.
1. Download both files
Download both install-vim-setup.sh and vimrc from this repository. Keep them in the same folder.

If using Git, clone the repository and enter its folder, for example:
git clone YOUR_REPOSITORY_URL
cd YOUR_REPOSITORY_FOLDER
Replace the two placeholders with the actual GitHub repository URL and folder name.

If downloading individual files from GitHub, use the Raw view for each file and save them with these exact names:
- install-vim-setup.sh
- vimrc (no leading dot yet)
2. Run the installer
From the folder containing both files:
chmod +x install-vim-setup.sh
./install-vim-setup.sh
Enter your password if sudo asks for it. Do not run the script with sudo; it should run as your normal user so it installs user-level files in the correct home directory.

The script will:
- Copy vimrc to ~/.vimrc. If ~/.vimrc already exists and differs, it first creates a timestamped backup.
- Install missing system packages for Vim, Git, Node.js/npm, C/C++ tools, shell linting/formatting, and Python.
- Clone coc.nvim if it is not already installed.
- Install/check coc-pyright, coc-sh, and coc-clangd.
- Install csharp-ls version 0.5.4 if a .NET SDK is available.
- Add $HOME/.dotnet/tools to ~/.bashrc if it is not already there.
Review any [WARN] messages at the end. The full log is at:
cat ~/vim-setup-install.log
Node.js requirement
Current coc.nvim requires Node.js 22.15.0 or newer. The installer checks the installed version and warns if it may be too old. If so, install a current supported Node.js version and rerun the installer. The script does not automatically replace an existing Node.js installation with a different major version.
3. Configure C# autocomplete (one-time step)
The installer installs csharp-ls but leaves the CocConfig file alone to avoid overwriting any existing settings.

Open Vim:
vim
Inside Vim, run:
:CocConfig
Add this configuration. If the file already has settings, merge the "languageserver" entry into the existing JSON instead of deleting other settings:
{
  "languageserver": {
    "csharp-ls": {
      "command": "csharp-ls",
      "filetypes": ["cs"],
      "rootPatterns": ["*.csproj", ".git"]
    }
  }
}
Save and close the file. If it already contains a languageserver object, add only the "csharp-ls" entry inside that object, using commas as valid JSON requires.

Avoid configuring two C# language servers at once. This setup uses the generic csharp-ls configuration above; it does not also install @yaegassy/coc-csharp-ls.
4. Restart and verify
Close all Vim windows and open Vim again. Check the extension installation:
:CocInfo
:CocList extensions
:CocList services
The extensions coc-pyright, coc-sh, and coc-clangd should be installed. The C# service should appear when opening a .cs file in a real C# project.
5. Test autocomplete
Python
Open a .py file and type part of a built-in or imported function name.
Bash
Open a .sh file and type a function or variable name. coc-sh provides shell-language features; normal terminal path completion is separate and uses Tab at the shell prompt.
C
Open a .c file. clangd works best when it can identify the project and its compile settings.
C#
Open a real .NET project, not just a standalone file:
mkdir -p ~/CSharpTest
cd ~/CSharpTest
dotnet new console
vim Program.cs
In Program.cs, type Console. and wait for suggestions. You can also press Ctrl+Space to request completion manually.
6. Troubleshooting
- Check node --version. It should be v22.15.0 or newer for current coc.nvim.
- Check csharp-ls --version.
- In Vim, run :CocInfo and :CocList services.
- Review ~/vim-setup-install.log.
- If an extension failed to install, run this inside Vim:
:CocInstall coc-pyright coc-sh coc-clangd
- If C# does not start, ensure ~/.dotnet/tools is in your PATH, the csharp-ls command works in the terminal, and the JSON in :CocConfig is valid.
Notes
- This setup is intended for Kali Linux, Debian, or Ubuntu.
- The script does not install a .NET SDK if none is present; install a compatible SDK first if you need C# autocomplete.
- It does not overwrite existing CocConfig settings.
- A rerun is supported and should not duplicate the PATH line or reinstall tools/extensions that are already present.
