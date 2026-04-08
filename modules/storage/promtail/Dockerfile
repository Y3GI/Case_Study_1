FROM grafana/promtail:latest
# Copy your Promtail config
COPY promtail-config.yml /etc/promtail/config.yml
# Copy the MaxMind database into the container
COPY GeoLite2-City.mmdb /etc/promtail/GeoLite2-City.mmdb