# sshmx - SSH Session Manager for tmux

`sshmx` is a lightweight Bash utility that helps you manage and launch SSH sessions inside [`tmux`](https://github.com/tmux/tmux).  
It integrates with your existing `~/.ssh/config` or lets you add/remove sessions interactively, and provides a handy **tmux key binding** (`Ctrl+b C-s`) to quickly open SSH connections in popup windows.

---

## ✨ Features
- **Interactive SSH session selector** using [fzf](https://github.com/junegunn/fzf)
- **Automatic JSON session store** (`~/.ssh/sessions.json`)
- **Import from `~/.ssh/config`** or create sessions manually
- **tmux integration**:
  - New SSH sessions open in dedicated `tmux` windows
  - Popup window shortcut (`Ctrl+b C-s`) to run `sshmx`
- **Jump host (ProxyJump) support**
- **Password and private key support** (passwords require `sshpass`)
- **Optional colored output** with [chromaterm](https://github.com/hSaria/Chromaterm)
- **Self-installing** script – just run once and it sets itself up

---

## 📦 Requirements
- [tmux](https://github.com/tmux/tmux)
- [fzf](https://github.com/junegunn/fzf)
- [jq](https://github.com/stedolan/jq)
- [sshpass](https://linux.die.net/man/1/sshpass) *(optional, for password auth)*
- [chromaterm](https://github.com/hSaria/Chromaterm) *(optional, for colored output)*

---

## 🚀 Installation
Clone the repository and run the script with the `--install` flag:

```bash
git clone https://github.com/yourusername/sshmx.git
cd sshmx
./sshmx.sh --install
````

This will:

* Create a symlink to `~/.local/bin/sshmx`
* Add `Ctrl+b C-s` binding to your `~/.tmux.conf` (or create one if missing)
* Add bash completion for command flags
* Add `~/.local/bin` to your PATH (via `~/.bashrc`)

Reload tmux:

```bash
tmux source-file ~/.tmux.conf
```

---

## 🔑 Usage

| Command                        | Description                                                       |
| ------------------------------ | ----------------------------------------------------------------- |
| `sshmx`                        | Launch interactive session selector with `fzf`                    |
| `sshmx --add` / `sshmx -a`     | Add a new SSH session interactively                               |
| `sshmx --remove` / `sshmx -r`  | Remove one or more sessions interactively                         |
| `sshmx --install` / `sshmx -i` | Install script, create symlink, add tmux binding, bash completion |
| `sshmx --sync` / `sshmx -s`    | Sync `~/.ssh/sessions.json` with `~/.ssh/config`                  |

---

### First run

The script auto-generates a `sessions.json` file at `~/.ssh/sessions.json` by parsing your `~/.ssh/config`.
If no sessions are found, it creates a sample entry.

---

### Launch SSH sessions

```bash
sshmx
```

* Prompts you with an `fzf` selector of available sessions
* Selected hosts open as **new windows** in your tmux session
* If run outside tmux, a new session named `sshmx` is created

---

### Add a new session

```bash
sshmx --add
```

or

```bash
sshmx -a
```

Prompts for hostname, user, port, key, etc., and appends to `sessions.json`.

---

### Remove sessions

```bash
sshmx --remove
```

or

```bash
sshmx -r
```

Lets you multi-select sessions to delete using `fzf`.
A backup of `sessions.json` is automatically created.

---

### Sync sessions from `~/.ssh/config`

```bash
sshmx --sync
```

or

```bash
sshmx -s
```

Imports any missing hosts from your `~/.ssh/config` into `~/.ssh/sessions.json`.

---

## 🖥️ Example Workflow

1. Press `Ctrl+b C-s` inside tmux
2. `fzf` shows your saved sessions
3. Select one or more hosts
4. New tmux windows open, each running SSH into the chosen host(s)

---

## 📂 Files

* `~/.ssh/sessions.json` → Stores your SSH sessions
* `~/.ssh-session-manager.log` → Log file with parsing/debug info
* `~/.tmux.conf` → Key binding automatically added here
* `~/.local/bin/sshmx` → Symlink to the script for global usage

---

## ⚠️ Security Notes

* Passwords are stored in plain text if you choose to use them
  → **highly recommended** to use SSH keys instead
* Temporary configs for jump hosts are auto-cleaned after use

---

## 🛠️ Roadmap / Ideas

* [ ] Encrypted session store
* [x] On-demand sync with `~/.ssh/config` (`-s / --sync`)
* [x] Advanced UI with [fzf preview](https://github.com/junegunn/fzf#preview-window)
* [x] Grouped sessions (connect to multiple related servers at once)
* [ ] Multiplex commands (run the same command across selected hosts)
* [x] Export/import session configs (share with teammates)

---

## 🤝 Contributing

Pull requests are welcome!
If you find a bug or want a feature, open an [issue](../../issues).

---

## 📜 License

MIT License © 2025 mrbooshehri