# Dotfiles Repository Instructions

## Scope

- These instructions apply only to this dotfiles repository.
- `common/AGENTS.md` is the source for the user-level `$HOME/AGENTS.md`; keep cross-project rules there.

## Repository Conventions

- Manage home-directory configuration through dotstate: `common/` for every machine, `<profile>/` (`macos`, `linux`) for one, each linked path listed in `.dotstate-profiles.toml`.
- Keep generated state, secrets, caches, and installed third-party content out of version control and the dotstate manifest.
- Preserve compatibility with macOS, Linux, and GitHub Codespaces where existing scripts support them.
- Reuse the existing shell helpers, output style, and test patterns in `install.sh` and `test.sh`.

## Changes and Validation

- Make focused changes and do not modify unrelated user configuration.
- Update `README.md` and `test.sh` when installation behavior changes.
- Run the narrowest relevant checks, then `./test.sh` for installation or linking changes.
- If an existing check fails before the change, distinguish it clearly from new failures.

## Safety

- Never commit credentials or machine-specific secrets.
- Never overwrite unmanaged home-directory files without backing them up.
- Test dotstate and installer behavior against temporary homes instead of the real home directory.
