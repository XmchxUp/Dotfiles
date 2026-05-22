# Xmchx's Dotfiles

这个仓库现在支持自动化安装、同步和 macOS 一键初始化。

## 包含内容

- `gitconfig` -> `~/.gitconfig`
- `zshrc` -> `~/.zshrc`
- `tmux.conf` -> `~/.tmux.conf`
- `alacritty.toml` / `alacritty.windows.toml` -> Alacritty 用户配置
- `ghostty/config.ghostty` -> Ghostty 用户配置
- `Vscode/settings.json` -> VS Code 用户配置
- `Vscode/keybindings.json.mac` / `Vscode/keybindings.json.windows` -> VS Code 平台快捷键

## 快速开始

macOS 一键完成工具、shell、插件和配置：

```bash
make setup
```

默认以软链接方式安装，已有同名配置会先自动备份到 `~/.dotfiles-backup/<timestamp>/`。

```bash
make install
```

只预览将要发生的动作：

```bash
make dry-run
```

如果你不想用软链接，改为复制文件：

```bash
make install-copy
```

## 可选：只安装常用工具与 shell 生态

macOS 下可以使用 Homebrew 一次性安装常用工具，并自动完成：

- `oh-my-zsh`
- `zsh-autosuggestions`
- `zsh-syntax-highlighting`
- `tmux` 插件管理器 `tpm`
- `tmux-resurrect`
- `tmux-continuum`

命令：

```bash
make tools
```

当前 `Brewfile` 包含：

- `uv`
- `zoxide`
- `eza`
- `bat`
- `tealdeer`
- `git-lfs`
- `gnupg`
- `neovim`
- `nvm`
- `tmux`
- `zsh`
- `fzf`
- `alacritty`
- `ghostty`
- `visual-studio-code`

## 同步本机配置回仓库

如果你已经在本机改过配置，可以把当前用户目录里的配置同步回仓库：

```bash
make sync
```

## 平台说明

- macOS: 安装 `gitconfig`、Alacritty、VS Code `settings.json`、macOS 版 `keybindings.json`
- macOS: 额外安装 `~/.zshrc`、`~/.tmux.conf`、`~/.config/ghostty/config.ghostty`
- Windows: 安装 `gitconfig`、Windows 版 Alacritty、VS Code `settings.json`、Windows 版 `keybindings.json`
- Linux: 安装 `gitconfig`、`~/.zshrc`、`~/.tmux.conf`、Alacritty、Ghostty、VS Code `settings.json`

Linux 当前没有单独的 VS Code 快捷键文件，所以不会覆盖 `keybindings.json`。

## 注意事项

- 当前 `gitconfig` 含个人 `signingkey`。新机器如果还没导入对应 GPG key，提交签名会失败。
- `alacritty.windows.toml` 默认使用 `wsl.exe` 启动 `Ubuntu-22.04`，如果你的发行版名称不同，需要自行调整。
- `tmux.conf` 参考了你给的 `theniceboy/.config/.tmux.conf` 思路，但去掉了它仓库里那些本地脚本依赖，避免装完直接报错。
