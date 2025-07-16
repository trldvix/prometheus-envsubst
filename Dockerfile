FROM prom/prometheus:latest as base

FROM alpine:3.18

# Install gettext for envsubst
RUN apk add --no-cache gettext

# Copy Prometheus binary and default config
COPY --from=base /bin/prometheus /bin/prometheus
COPY --from=base /etc/prometheus /etc/prometheus
RUN mkdir -p /prometheus && chown -R nobody:nogroup /etc/prometheus /prometheus

# Create entrypoint script with envsubst templating for both config files
RUN printf '%s\n' \
  '#!/bin/sh' \
  '' \
  '# Template prometheus.yml from prometheus.yml.template' \
  'envsubst < /etc/prometheus/prometheus.yml.template > /etc/prometheus/prometheus.yml' \
  '' \
  '# Template web.yml from web.yml.template' \
  'envsubst < /etc/prometheus/web.yml.template> /etc/prometheus/web.yml' \
  '' \
  '# Execute Prometheus with passed arguments' \
  'exec /bin/prometheus "$@"' \
  > /entrypoint.sh && chmod +x /entrypoint.sh

# Set working directory and entrypoint
WORKDIR /prometheus
ENTRYPOINT ["/entrypoint.sh"]
