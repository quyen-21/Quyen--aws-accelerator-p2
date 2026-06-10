# Grafana Dashboard Config

## Minimum Required Panels

- **Request Rate**
- **Error Rate**
- **Latency P95**
- **CPU Usage**
- **Memory Usage**
- **Pod Restart Count**

## PromQL Queries

### Request Rate
```promql
sum(rate(http_requests_total[1m]))
```

### Error Rate
```promql
sum(rate(http_requests_total{status=~"5.."}[5m]))
```

### Latency P95
```promql
histogram_quantile(
  0.95,
  sum(
    rate(
      http_request_duration_seconds_bucket[5m]
    )
  ) by (le)
)
```

### CPU Usage
```promql
rate(container_cpu_usage_seconds_total[5m])
```

### Memory Usage
```promql
container_memory_usage_bytes
```

### Pod Restart Count
```promql
sum(changes(kube_pod_container_status_restarts_total[30m])) by (pod)
```
