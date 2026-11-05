FROM mcr.microsoft.com/devcontainers/python:3.12-bookworm

COPY --from=ghcr.io/astral-sh/uv:0.10.9 /uv /uvx /usr/local/bin/

RUN uv venv --python /usr/local/bin/python /opt/venv \
    && chown -R vscode:vscode /opt/venv

ENV VIRTUAL_ENV=/opt/venv \
    UV_PROJECT_ENVIRONMENT=/opt/venv \
    UV_LINK_MODE=copy \
    PATH=/opt/venv/bin:${PATH}

USER vscode