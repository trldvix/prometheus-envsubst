## About
This Docker image extends the official `prom/prometheus:latest` image by providing a way to template `prometheus.yml` and `web.yml` configuration files using environment variables.


## Usage

### 1. Prepare Configuration Templates

Create your` prometheus.yml.template` and `web.yml.template` files in your project directory. These files should contain placeholders for environment variables in the format `${YOUR_VARIABLE}`.

 Example `prometheus.yml.template`:

```yaml
scrape_configs:
  - job_name: 'prometheus'
    metrics_path: '/prometheus'
    scheme: 'http'
    scrape_interval: 15s
    static_configs:
      - targets: [ 'localhost:8080' ]
        labels:
          application: "app"
    basic_auth:
      username: ${APP_USERNAME}
      password: ${APP_PASSWORD}
```

Example `web.yml.template` (optional, if you need web configuration):
```yaml
global:
  basic_auth_users:
    admin: ${PROMETHEUS_PASSWORD}
```

### 2. Docker
Remember to mount your template files.
```shell
docker run -d \
  -p 9090:9090 \
  -v ./prometheus.yml.template:/etc/prometheus/prometheus.yml.template \
  -v ./web.yml.template:/etc/prometheus/web.yml.template \
  -e APP_USERNAME=admin \
  -e APP_PASSWORD=admin \
  -e PROMETHEUS_PASSWORD=admin \
  --name prometheus-envsubst \
  ghcr.io/trldvix/prometheus-envsubst:latest \
  --config.file=/etc/prometheus/prometheus.yml \
  --web.config.file=/etc/prometheus/web.yml
```

### 3. Docker Compose
```yaml
services:
  prometheus:
    image: ghcr.io/trldvix/prometheus-envsubst:latest
    #Get variables from the .env file
    env_file:
      - .env
    #Or import variables directly
    environment:
      APP_USERNAME=admin
      APP_PASSWORD=admin
      PROMETHEUS_PASSWORD=admin
    #Mount templates
    volumes:
      - ./prometheus/prometheus.yml.template:/etc/prometheus/prometheus.yml.template
      - ./prometheus/web.yml.template:/etc/prometheus/web.yml.template
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--web.config.file=/etc/prometheus/web.yml"
    ports:
      - '9090:9090'
```
