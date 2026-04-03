FROM debian:13.4

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential nodejs npm python3 python3-pip python3-venv \
        ripgrep ffmpeg gcc python3-dev libffi-dev git curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Clone and install Hermes
RUN git clone --depth 1 https://github.com/NousResearch/hermes-agent.git /opt/hermes

WORKDIR /opt/hermes

# Install Python and Node dependencies
RUN pip install --no-cache-dir -e ".[all]" --break-system-packages && \
    npm install --prefer-offline --no-audit && \
    npm cache clean --force

# Setup entrypoint
RUN chmod +x /opt/hermes/docker/entrypoint.sh

ENV HERMES_HOME=/opt/data

ENTRYPOINT [ "/opt/hermes/docker/entrypoint.sh" ]
