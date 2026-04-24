FROM debian:13.4

ENV PYTHONUNBUFFERED=1
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/hermes/.playwright
ENV HERMES_HOME=/opt/data
ENV PATH="/opt/data/.local/bin:/opt/hermes/.venv/bin:${PATH}"

# Install system deps in one layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential nodejs npm python3 python3-venv python3-pip \
        ripgrep ffmpeg gcc python3-dev libffi-dev git curl ca-certificates \
        gosu && \
    rm -rf /var/lib/apt/lists/*

# Non-root user for runtime
RUN useradd -u 10000 -m -d /opt/data hermes

# Clone and install Hermes
RUN git clone --depth 1 https://github.com/NousResearch/hermes-agent.git /opt/hermes

WORKDIR /opt/hermes

# Install uv for fast dependency resolution
RUN pip install --break-system-packages uv

# Install Python deps with uv (avoids pip resolution-too-deep error)
RUN uv venv /opt/hermes/.venv && \
    uv pip install --no-cache-dir -e ".[all]" --python /opt/hermes/.venv/bin/python && \
    uv pip install --no-cache-dir playwright --python /opt/hermes/.venv/bin/python && \
    /opt/hermes/.venv/bin/playwright install --with-deps chromium --only-shell

# Install node deps
RUN npm install --prefer-offline --no-audit && \
    npm cache clean --force

# Entrypoint is in the cloned repo
RUN chmod +x /opt/hermes/docker/entrypoint.sh

ENTRYPOINT [ "/usr/bin/tini", "-g", "--", "/opt/hermes/docker/entrypoint.sh" ]
