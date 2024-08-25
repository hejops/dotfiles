# dotfiles

- Window manager: [`dwm`](https://github.com/hejops/dwm)
- Terminal emulator: ~~[`kitty`](./dot_config/kitty)~~, [`wezterm`](./dot_config/wezterm)
- Text editor: [`neovim`](./dot_config/nvim)
- File manager: [`ranger`](./dot_config/ranger), [`lf`](./dot_config/lf/lfrc)
- Web browser: [`firefox`](./.mozilla/firefox) + [`tridactyl`](./dot_config/tridactyl)
- Font: [Source Code Pro](https://github.com/adobe-fonts/source-code-pro)
- Colorscheme: [`citruszest`](https://github.com/zootedb0t/citruszest.nvim)

## Installation

<https://www.chezmoi.io/quick-start/#using-chezmoi-across-multiple-machines>

```sh
chezmoi init --apply hejops

# alternatively
chezmoi init https://github.com/hejops/dotfiles.git
chezmoi apply -v
# chezmoi update -v
```
