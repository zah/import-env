# import-env


`import-env` is a tiny, dependency-free **Ruby** tool that lets you run *any* shell script, capture the environment variables it adds/changes/removes, and print a Bash snippet that reproduces those changes in the **current** shell.
Think of it as *direnv*’s “env diff” algorithm, but standalone and shell-agnostic.

---

## Installation

```bash
mkdir ~/.local/bin
curl -o ~/.local/bin/import-env https://raw.githubusercontent.com/zah/import-env/main/bin/import-env
chmod +x ~/.local/bin/import-env
```

Requires Ruby ≥ 2.3 (present on macOS and most Linux distros).

## Quick usage

```bash
# bring variables from setup-env.sh into the live shell
eval "$(import-env ./setup-env.sh --debug)"

# run a command with that environment, without touching the caller
bash -c "$(import-env ./java-env.fish); exec mvn test"
```

Inside a Bash script:

```bash
#!/usr/bin/env bash
set -euo pipefail
eval "$(envdiff ./bootstrap.zsh)"
# …PATH, JAVA_HOME, etc. are now set…
```

## Supported interpreters
`sh`, `bash`, `zsh`, `dash`, `ksh`, `fish`
If the script’s she-bang names anything else, `import-env` exits with status 2 and a clear message.

## Exit codes

| code | meaning                        |
|------|--------------------------------|
| 0    | diff printed successfully      |
| 1    | usage error / script not found |
| 2    | unsupported interpreter        |

## License
MIT © 2025 Zahary Karadjov
