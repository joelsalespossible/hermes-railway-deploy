# Stage 1: Get everything from the official Hermes image
FROM nousresearch/hermes-agent:latest AS builder

# Stage 2: Fresh image WITHOUT the VOLUME directive
FROM debian:13.4

# Copy the entire Hermes installation
COPY --from=builder /opt/hermes /opt/hermes
COPY --from=builder /usr/local /usr/local
COPY --from=builder /usr/bin/python3 /usr/bin/python3
COPY --from=builder /usr/lib/python3 /usr/lib/python3
COPY --from=builder /usr/lib/python3.13 /usr/lib/python3.13
COPY --from=builder /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu
COPY --from=builder /usr/bin/node /usr/bin/node
COPY --from=builder /usr/bin/npx /usr/bin/npx
COPY --from=builder /usr/bin/npm /usr/bin/npm
COPY --from=builder /usr/lib/node_modules /usr/lib/node_modules
COPY --from=builder /usr/bin/ffmpeg /usr/bin/ffmpeg
COPY --from=builder /usr/bin/rg /usr/bin/rg

# Install minimal runtime deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/hermes
ENV HERMES_HOME=/opt/data
ENV PATH="/opt/hermes/venv/bin:/usr/local/bin:${PATH}"

RUN chmod +x /opt/hermes/docker/entrypoint.sh
ENTRYPOINT [ "/opt/hermes/docker/entrypoint.sh" ]
