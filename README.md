# dotfiles

Shell setup utilities.

## Installation

Run:

`./install`

## Notes

- Dotfiles are symlinked into `$HOME` via GNU Stow.
- Current stow packages include `agents/`, `git-common/`, and `zsh/`.
- Linux also stows `vscode-user/` to `~/.config/Code/User/settings.json`.

## VS Code extensions

- Add extension IDs to `vscode/extensions.txt` (one per line).
- Run `./install` to apply the list with `code` (or `code-insiders` if available).
- Lines beginning with `#` are ignored.

## Editor settings and Peacock profiles

- Edit `vscode-user/.config/Code/User/settings.json` for personal global settings.
- Apply with `bash ./stow.sh` (or run `./install`).
- This does not modify tracked per-repo `.vscode/settings.json` files.
- Peacock profile presets live in `zsh/.zsh/peacock/profiles/*.json`.
- Each profile JSON should define `workbench.colorCustomizations`; `peacock.remoteColor` is optional.
- Run `peacock-list` to show available profile names.
- Run `peacock-apply <profile-name>` to apply a profile.
- Run `peacock` to pick a random profile and apply it.
- Profile colors merge into `workbench.colorCustomizations` without removing unrelated keys.
- `peacock-apply` updates detected settings files for VS Code/Cursor local and remote sessions.
- Set `PEACOCK_SETTINGS_FILE` to target a single settings path explicitly.
- `./install` applies one random Peacock profile after dotfiles are stowed.

## Zsh aliases

- Add shared aliases to `zsh/.zsh/aliases.zsh`.
- Add grouped alias files under `zsh/.zsh/aliases.d/*.zsh`.
- Run `./install` (or `bash ./stow.sh`) to link updates into `$HOME`.

## Lint helpers

- `lint-changed`: alias for eslint+prettier on uncommitted `*.ts`/`*.tsx` files.
- `lint-changed-origin-main`: alias for eslint+prettier on files changed in `origin/main...HEAD`.