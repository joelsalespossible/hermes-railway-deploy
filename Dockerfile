FROM nousresearch/hermes-agent:latest

# Railway doesn't allow VOLUME directive - use Railway volumes instead
# The base image VOLUME is overridden by this layer

ENV HERMES_HOME=/opt/data

ENTRYPOINT [ "/opt/hermes/docker/entrypoint.sh" ]
