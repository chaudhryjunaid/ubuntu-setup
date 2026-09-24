# ubuntu-setup

Rebuilds my Ubuntu dev machine after a reinstall: apps, dev toolchains and dotfiles, in a fixed order, with no menus. Everything is plain bash, and every step is safe to re-run.

The app set is taken from what is actually installed on the reference machine (Ubuntu 26.04 "resolute"). Dotfiles come from [rcfiles](https://github.com/chaudhryjunaid/rcfiles). Work repos are never cloned.

## Fresh machine

```sh
sudo apt install -y git
git clone https://github.com/chaudhryjunaid/ubuntu-setup ~/setup/ubuntu-setup
~/setup/ubuntu-setup/setup.sh
```

It asks for sudo once. After that it only prompts for things it can't know: git identity, where your private fonts are, and optional SSH key, `gh`, and Tailscale logins. Log out and back in when it finishes.

```sh
./setup.sh --from 40   # resume after a failure
./setup.sh --only 70   # re-run one step
```

## Steps

| Step | What it does |
|---|---|
| `10-apt-base` | Ubuntu-archive packages (`packages/apt.txt`), plus Intel GPU drivers when an Intel GPU is present |
| `20-apt-repos` | Third-party apt repos and keys, copied verbatim from `apt/files/` (mirrors `/`) |
| `30-apt-repo-apps` | Chrome, Slack, Docker, Sublime, TablePlus, Dropbox, Tailscale, gh, ChatGPT, Claude (`packages/apt-repo.txt`) |
| `40-debs` | MongoDB Compass/mongosh/database-tools and Obsidian from release downloads (`packages/debs.txt`) |
| `50-snaps` | OnlyOffice, Foliate |
| `60-flatpak` | Gear Lever |
| `70-manual-installs` | Claude Code, SmartGit (`/opt/smartgit`), Zed, Bruno AppImage, Google Cloud SDK |
| `80-toolchains` | fnm + Node 26, uv, rustup, Go, Java |
| `85-fonts` | private fonts, copied from a folder you give it |
| `88-groups-services` | docker/libvirt/kvm groups; docker, libvirtd and tailscaled services |
| `90-dotfiles` | clone rcfiles and run its `install.sh`: antidote, bob + Neovim, tree-sitter, Nerd Fonts, zsh as login shell, dotfile links, git identity |
| `95-post` | optional logins, then the list of manual sign-ins |

Package lists are in the order things were installed on the reference machine.

## Keeping it in sync

After installing or removing something on the reference machine:

```sh
bin/inventory.sh
```

It lists what's installed but not in `packages/*.txt` (`+`), what's listed but missing (`-`), and any apt repo file that differs from `apt/files/`. Update the lists by hand so the order is kept. For a new third-party repo, copy its `.list`/`.sources` file and keyring into `apt/files/` at the same path.

Pinned versions to bump occasionally: `SMARTGIT_VERSION` in `steps/70-manual-installs.sh`, the mongodb-database-tools URL in `packages/debs.txt`, and `NODE_VERSION` in `steps/80-toolchains.sh`. The apt repo files name the `resolute` release, so update them when moving to a new Ubuntu release.
