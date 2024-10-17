groups:
- name: kubernetes-apiserver
  rules:
{{- if not (.Values.prometheusRules.disabled.KubernetesApiServerDown | default false) }}
  - alert: KubernetesApiServerDown
    expr: absent(up{job="apiserver"}) or up{job=~".*apiserver"} == 0
    for: {{ dig "KubernetesApiServerDown" "for" "15m" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubernetesApiServerDown" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesApiServerDown.md
      {{ include "kubernetes-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: Kubernetes API server has disappeared from Prometheus target discovery.
      summary: Target disappeared from Prometheus target discovery.
{{- end }}

{{- if not (.Values.prometheusRules.disabled.KubernetesApiServerLatency | default false) }}
  - alert: KubernetesApiServerLatency
    expr: |
      histogram_quantile(
        0.99, sum(
          rate(
            apiserver_request_duration_seconds_bucket{verb!~"CONNECT|WATCHLIST|WATCH|LIST",subresource!="log"}[5m]
            )
          ) by (resource, le)
        )
      / 1e6 > 2
    for: {{ dig "KubernetesApiServerDown" "for" "30m" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubernetesApiServerLatency" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesApiServerLatency.md
      {{ include "kubernetes-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: ApiServerLatency for `{{`{{ $labels.resource }}`}}` is higher then usual for the past {{ dig "KubernetesApiServerDown" "for" "30m" .Values.prometheusRules }} minutes. Inspect apiserver logs for the root cause.
      summary: ApiServerLatency is unusually high.
{{- end }}

{{- if not (.Values.prometheusRules.disabled.KubeAggregatedAPIDown | default false) }}
  - alert: KubeAggregatedAPIDown
    expr: |
      (
        1 - max by (name, namespace)
        (
          avg_over_time(
            aggregator_unavailable_apiservice{job="apiserver"}[10m]
            )
          )
        )
      * 100 < 85
    for: {{ dig "KubeAggregatedAPIDown" "for" "5m" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubeAggregatedAPIDown" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubeAggregatedAPIDown.md
      {{ include "kubernetes-operations.additionalRuleLabels" . | nindent 6 }}
    annotations:
      description: Kubernetes aggregated API `{{`{{ $labels.namespace }}`}}/{{`{{ $labels.name }}`}}` has been only `{{`{{ $value | humanizePercentage }}`}}` available over the last {{ dig "KubeAggregatedAPIDown" "for" "5m" .Values.prometheusRules }} . Run `kubectl get apiservice | grep -v Local` and confirm the services of aggregated APIs have active endpoints.
      summary: Kubernetes aggregated API is down.
{{- end }}
