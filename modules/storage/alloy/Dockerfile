FROM grafana/alloy:latest

# Copy the Alloy configuration file
COPY config.alloy /etc/alloy/config.alloy

# Copy the MaxMind database into the container
COPY GeoLite2-City.mmdb /etc/alloy/GeoLite2-City.mmdb

# Run Alloy
CMD ["run", "--server.http.listen-addr=0.0.0.0:12345", "--stability.level=experimental", "/etc/alloy/config.alloy"]