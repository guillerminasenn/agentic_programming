# Portable Minimal Dev Container

A general-purpose Linux development environment with Python 3.12, Git, SSH and
uv 0.10.9. Python uses `/opt/venv`, already on `PATH`. There are no application
dependencies, automatic package installs, GUI libraries, C++ toolchain additions
or persistent environment volumes. Add project-specific requirements only when
needed. No `pyproject.toml` or `uv.lock` is required to build this container.

## Host Prerequisites

Install VS Code, its **Dev Containers** extension, and a compatible container
engine accessible from VS Code, such as Docker. For a WSL-hosted checkout, also
install the **WSL** extension. Host Python and uv are not required; the container
image provides both. The Windows/WSLc setup below is an alternative to Docker.

### Windows and WSL Containers

In PowerShell, check:

```powershell
wsl --version
wslc version
```

Use WSL 3.0 or later (the reference setup used 3.0.3). If WSL is missing, run
`wsl --install --no-distribution` and restart Windows if requested. If WSL is
outdated, `wslc` is missing or the versions differ, run `wsl --update` and recheck
in a new terminal. Docker Desktop is not required. A separate Ubuntu distribution
is not needed for a direct Windows launch, but **is needed for the WSL-side
wrapper and for checkouts stored in WSL**. If necessary, install one with
`wsl --install -d Ubuntu` and complete its user setup.

In Windows VS Code, open **Preferences: Open User Settings (JSON)** and merge:

```json
{
  "dev.containers.dockerPath": "wslc",
  "dev.containers.executeInWSL": false,
  "dev.containers.mountWaylandSocket": false
}
```

These are host user settings, not `devcontainer.json` properties. When launching
with `code .` from WSL, check that conflicting remote/workspace settings do not
override them and that `wslc` resolves to the wrapper in that WSL environment.
Other platforms need a compatible container engine accessible from VS Code.

### WSLc Launch-Hang Workaround

In the tested WSL launch, VS Code's `NODE_PATH` enabled a simulated-terminal path
that made container creation hang. A WSL-side wrapper forces `run` and `build`
through ordinary pipes. It is a workaround, not an upstream fix, and is only
needed for the affected WSLc launch route.

In your **host WSL distribution, not inside a dev container**, create
`/tmp/wslc-wrapper` in an editor with this content:

```bash
#!/bin/bash
set -o pipefail
case "${1-}" in
  run|build)
    "/mnt/c/Program Files/WSL/wslc.exe" "$@" </dev/null 2>&1 | cat
    ;;
  *)
    exec "/mnt/c/Program Files/WSL/wslc.exe" "$@"
    ;;
esac
```

Verify the executable path matches your installation. Review/back up any existing
`/usr/local/bin/wslc` before replacing it. Then, in the host WSL terminal:

```sh
sudo install -m 755 /tmp/wslc-wrapper /usr/local/bin/wslc
hash -r
command -v wslc
wslc version
```

`command -v wslc` should report `/usr/local/bin/wslc`. Keep the Windows VS Code
user settings above, including `executeInWSL: false` and `dockerPath: "wslc"`,
as in the validated setup; launch the checkout with `code .` from WSL.

Normal VS Code opening was validated with the wrapper. Its build branch and
interactive commands were not separately validated. It closes stdin and merges
stdout/stderr for `run`/`build`, which can affect prompts and interactive use.
It does not fix slash-prefixed container-name inspection; use a container ID
when investigating with `wslc inspect`. The exact terminal deadlock is unproven.

### WSL-Hosted Repositories: Disable UID Adjustment

When starting VS Code from WSL for a repository stored in WSL and using WSLc,
keep this in `.devcontainer/devcontainer.json`:

```json
"updateRemoteUserUID": false
```

It is already set in this configuration. Otherwise, Dev Containers can attempt a UID
adjustment using an option WSLc does not support. This is a **separate** issue
from the launch hang; the wrapper alone does not fix it. Rebuild after changing
the configuration. This is not a universal recommendation for
Docker on Linux: disabling UID matching can leave bind-mount permission issues
when the host user's UID differs from the container user's UID. Check that you
can edit the workspace as `vscode`; do not compensate by running as root or making
the checkout world-writable.

## Open Directly in VS Code

On the **host**, open the repository root, not the `.devcontainer/` subfolder:

```sh
code .
```

Choose **Dev Containers: Reopen in Container** from the Command Palette. VS Code
reads `.devcontainer/devcontainer.json` and builds the image using the included
Dockerfile. If replacing an existing configuration, use **Dev Containers: Rebuild
Container** instead. No setup script or project package installation is required.

In the container terminal, check:

```sh
whoami
python --version
uv --version
python -c "import sys; print(sys.executable)"
touch .devcontainer-write-check && rm .devcontainer-write-check
```

Expect `vscode`, Python 3.12, uv 0.10.9, `/opt/venv/bin/python`, and a successful
workspace write. `.devcontainer/` is deliberately mounted read-only inside the
container; edit its files on the host. The rest of the workspace is writable.

## Mounts and Configuration Changes

The repository is mounted automatically. For additional data/results folders,
edit the `mounts` array in `.devcontainer/devcontainer.json` **on the host**. Keep
the existing read-only mount for `.devcontainer/` and add entries such as:

```json
"mounts": [
  "source=${localWorkspaceFolder}/.devcontainer,target=${containerWorkspaceFolder}/.devcontainer,type=bind,readonly",
  "source=C:/data,target=/data/dataset,type=bind,readonly",
  "source=C:/results,target=/data/results,type=bind"
]
```

For a WSL-hosted checkout, use paths visible to that WSL host and accepted by
WSLc, such as `/home/YOUR-USER/data`. On Linux or macOS, use the appropriate host
paths. `readonly` makes a mount read-only; omitting it makes the mount read-write.
Host folders must exist, source paths cannot contain commas, and container targets
must be absolute and unique.

The included `mounts.txt` is a legacy input for a generator that is not included
here. Editing it does not change mounts; edit `devcontainer.json` directly.

After changing the Dockerfile, mounts, or container configuration, choose
**Dev Containers: Rebuild Container**. The SSH attach-time check only reports
agent availability; it does not install packages or change configuration.

## Python Packages

Inside the container, Python and uv target `/opt/venv`; nothing needs activation.
For a project with `pyproject.toml` and a committed `uv.lock`:

```sh
uv sync --locked
```

Include the project's required extras/groups. Without a lockfile, `uv sync`
creates one. Without a project manifest, install standalone tools with:

```sh
uv pip install --python /opt/venv/bin/python <package>
```

The environment is in the container, not a persistent volume: reinstall packages
after rebuilding/replacing it. Keep project dependencies in a manifest and
lockfile, not only in interactive sessions. Windows needs its own `.venv`; never
reuse it in Linux. Change baseline Python/uv versions in the Dockerfile and rebuild.

## SSH Authentication

VS Code can forward your host SSH agent without copying private keys into the
container. Choose Windows or WSL to match where you launch VS Code. Reuse a
suitable existing key; if creating one, choose an unused filename and enter a
passphrase. Only register the `.pub` key with **GitHub > Settings > SSH and GPG
keys > New SSH key > Authentication Key**; authorize organization SSO if needed.

For **Windows**, enable OpenSSH Client in Optional features. In normal PowerShell:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.ssh" | Out-Null
ssh-keygen -t ed25519 -C "your-email@example.com Windows" -f "$env:USERPROFILE\.ssh\id_ed25519_github"
Get-Content "$env:USERPROFILE\.ssh\id_ed25519_github.pub"
```

Once, in administrator PowerShell:

```powershell
Set-Service -Name ssh-agent -StartupType Automatic
Start-Service -Name ssh-agent
```

Then in normal PowerShell:

```powershell
& "$env:WINDIR\System32\OpenSSH\ssh-add.exe" "$env:USERPROFILE\.ssh\id_ed25519_github"
& "$env:WINDIR\System32\OpenSSH\ssh-add.exe" -l
& "$env:WINDIR\System32\OpenSSH\ssh.exe" -T git@github.com
code C:\path\to\your-project
```

For **WSL**, run in the host distribution, not inside the dev container:

```sh
sudo apt-get update
sudo apt-get install openssh-client keychain
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t ed25519 -C "your-email@example.com WSL" -f ~/.ssh/id_ed25519_github_wsl
cat ~/.ssh/id_ed25519_github_wsl.pub
```

After registering the public key, load it and launch from that environment:

```sh
eval "$(keychain --eval --agents ssh "$HOME/.ssh/id_ed25519_github_wsl")"
ssh-add -l
ssh -T git@github.com
code /path/to/your-project
```

Optionally add the `eval` line once to `~/.bashrc`, after checking for conflicting
agent setup. You may need to unlock the key again after WSL shuts down. Verify
GitHub's host fingerprint against
[the published fingerprints](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints)
before accepting the first connection. Successful `ssh -T` reports authentication
but no shell access; exit code 1 is normal for that successful test.

Reconnect VS Code after loading the host key. Inside the container:

```sh
ssh-add -l
ssh -T git@github.com
git remote -v
git ls-remote origin HEAD
```

Use an SSH remote such as `git@github.com:OWNER/REPOSITORY.git`; HTTPS uses separate
credentials. If the agent is unavailable, check it on the host and relaunch from
there. Agent changes need a reconnect, not an image rebuild. No private-key mounts
or hard-coded socket paths are required.

**Security:** The container is not a security guarantee. Processes inside it,
including coding agents, can use forwarded credentials to request authentication
signatures and access mounted files and reachable services. Forwarding protects
the key file, not its use. Enable credentials only in trusted containers.

## Configuration Checks

After opening or rebuilding the container, run the environment checks above and
check SSH-agent forwarding:

```sh
bash .devcontainer/scripts/check-ssh-agent.sh
```

Verify configuration changes by rebuilding the container and checking the
environment, workspace permissions, and any added mounts.