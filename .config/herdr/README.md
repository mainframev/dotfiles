# herdr

Hotkeys for [`config.toml`](config.toml). The prefix is `ctrl+s`. Every key below is pressed after the prefix unless marked otherwise.

## Conventions

| Modifier | Scope |
|---|---|
| `<k>` | current tab/pane, most frequent actions |
| `ctrl+<k>` | workspace/worktree |
| `shift+<k>` | bigger or destructive variant of the plain key |

- Plugins get one home letter each, with variants on `shift`/`ctrl` of that letter.
- Avoid `ctrl+s` (pressing the prefix twice sends a literal `ctrl+s`) and `ctrl+i`/`m`/`[`/`h` (legacy terminals send them as tab/enter/esc/backspace).
- Run `herdr config check` after changing keys. herdr silently disables conflicting bindings.

## General

| Key | Action |
|---|---|
| `?` | help |
| `s` | settings |
| `d` | detach |
| `shift+r` | reload config |
| `o` | open notification target |
| `g` | goto |
| `b` | toggle sidebar |
| `e` | edit scrollback |
| `ctrl+v` (no prefix) | remote image paste |

## Workspaces

| Key | Action |
|---|---|
| `w` | workspace picker |
| `ctrl+c` | new workspace |
| `ctrl+r` | rename workspace |
| `ctrl+[` / `ctrl+]` | previous / next workspace |
| `ctrl+1..9` | switch to workspace |
| `ctrl+x` | close workspace |
| `ctrl+g` | open worktree (built-in) |
| `up` / `down` (navigate mode) | move between workspaces |

## Tabs

| Key | Action |
|---|---|
| `c` | new tab |
| `r` | rename tab |
| `[` / `]` | previous / next tab |
| `1..9` | switch to tab |
| `x` | close tab |

## Panes

| Key | Action |
|---|---|
| `h` `j` `k` `l` | focus left / down / up / right |
| `tab` / `shift+tab` | cycle next / previous |
| `shift+v` | split vertical |
| `shift+h` | split horizontal |
| `z` | zoom |
| `shift+p` | rename pane |
| `shift+x` | close pane |
| `h` `j` `k` `l` (navigate mode) | move between panes |

## Plugins

### Worktrunk (`g`)

| Key | Action |
|---|---|
| `shift+g` | switch / create worktree |
| `shift+d` | remove worktree |

### herdr-nvim (`n`)

| Key | Action |
|---|---|
| `n` | toggle nvim sidebar |
| `shift+n` | open file from agent output |

### Annotate (`a`, `m`)

| Key | Action |
|---|---|
| `a` | annotate selection |
| `shift+a` | copy annotations as context |
| `ctrl+a` | copy annotations as context and archive |
| `ctrl+v` | paste annotations into agent prompt and archive |
| `m` | manage annotations |
| `shift+m` | send annotations to agent and archive |

### Annotate review via plannotator (`f`)

| Key | Action |
|---|---|
| `f` | review documents in this folder |
| `shift+f` | review agent's last reply |
| `ctrl+f` | review agent's newest reply |

### Plugin manager (`p`)

| Key | Action |
|---|---|
| `p` | open plugin manager |
