# W9 Day C

## Objective

Implement Progressive Delivery

Tools:

- Argo Rollouts
- Prometheus
- Canary Deployment

Strategy:

20%
pause

50%
pause

100%

Analysis:

- Error Rate < 5%
- P95 Latency < 500ms

Abort Conditions:

- Error Rate > 5%
- P95 Latency > 500ms

Evidence:

- Successful rollout screenshot
- Aborted rollout screenshot
- AnalysisTemplate YAML
- Rollout YAML
