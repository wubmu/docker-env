# Prometheus & Grafana

This directory contains a Docker Compose setup for Prometheus and Grafana.

## Services

### Prometheus
- Port: 9090
- Configuration: `prometheus.yml`
- Data persistence: `prometheus_data` volume

### Grafana
- Port: 3000
- Default username: admin
- Default password: admin
- Data persistence: `grafana_data` volume
- Pre-configured Prometheus data source

## Quick Start

1. Navigate to this directory:
   ```bash
   cd docker-env/prometheus-grafana
   ```

2. Start the services:
   ```bash
   docker-compose up -d
   ```

3. Access the services:
   - Prometheus: http://localhost:9090
   - Grafana: http://localhost:3000

## Configuration

### Prometheus
Edit `prometheus.yml` to configure scrape jobs and retention policies.

### Grafana
Dashboards and datasources are automatically provisioned from the `grafana/provisioning` directory.

## Cleanup

To stop and remove the services:
```bash
docker-compose down
```

To remove volumes (including data):
```bash
docker-compose down -v
```