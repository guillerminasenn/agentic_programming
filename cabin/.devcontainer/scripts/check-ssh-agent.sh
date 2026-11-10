#!/usr/bin/env bash
if ! command -v ssh-add >/dev/null; then
  echo "SSH agent: ssh-add not found; add openssh-client to the Dockerfile and rebuild." >&2
  exit 0
fi

ssh-add -l >/dev/null 2>&1
case $? in
  0) echo "SSH agent: using the host's keys. Programs in the container can use them" \
          "to sign in to git servers while VS Code is connected." ;;
  1) echo "SSH agent: reachable but has no keys. Load a key on the host with ssh-add." >&2 ;;
  2) echo "SSH agent: not reachable. Start the SSH agent on the host (Windows or WSL)," \
          "then reopen VS Code from there. HTTPS remotes don't need it." >&2 ;;
  *) echo "SSH agent: 'ssh-add -l' failed in an unexpected way." >&2 ;;
esac
exit 0