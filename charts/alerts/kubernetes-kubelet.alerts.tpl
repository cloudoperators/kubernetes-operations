groups:
- name: kubernetes-kubelet
  rules:
  - alert: KubernetesManyKubeletsDown
    expr: |
     (
      count(up{job=~".*kubelet", metrics_path="/metrics"})
      -
      sum(up{job=~".*kubelet", metrics_path="/metrics"})
      ) > 4
    for: {{ dig "KubernetesManyKubeletsDown" "for" "10m" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubernetesManyKubeletsDown" "severity" "critical" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesManyKubeletsDown.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: Many Kubelets are DOWN.
      summary: More than 4 Kubelets are DOWN.

  - alert: KubeletDown
    expr: up{job=~".*kubelet", metrics_path="/metrics"} == 0 or absent(up{job=~".*kubelet", metrics_path="/metrics})
    for: {{ dig "KubeletDown" "for" "10m" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubeletDown" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubeletDown.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: Kublet on `{{`{{ $labels.node }}`}}` is DOWN.
      summary: A Kubelet is DOWN.

  - alert: KubeletTooManyPods
    expr: |
      count by (node) (
        (kube_pod_status_phase{phase="Running"} == 1)
          * on (instance, pod, namespace, cluster)
        group_left(node) topk by (instance, pod, namespace, cluster) (1, kube_pod_info)
      )
      /
      max by (cluster, node) (
        kube_node_status_capacity{resource="pods"} != 1
      ) > 0.95
    for: {{ dig "KubeletTooManyPods" "for" "1h" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubeletTooManyPods" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubeletTooManyPods.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: Kubelet `{{`{{ $labels.node }}`}}` is running at `{{`{{ $value | humanizePercentage }}`}}` of its Pod capacity.
      summary: Kubelet is running at capacity.

  - alert: KubeletFull
    expr: |
      count by (node) (
        (kube_pod_status_phase{phase="Running"} == 1)
          * on (instance, pod, namespace, cluster)
        group_left(node) topk by (instance, pod, namespace, cluster) (1, kube_pod_info)
      )
      /
      max by (cluster, node) (
        kube_node_status_capacity{resource="pods"} != 1
      ) == 1
    for: {{ dig "KubeletFull" "for" "1h" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubeletFull" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubeletFull.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: Kubelet is full, no more pods can be scheduled on `{{`{{ $labels.node }}`}}`.
      summary: Kubelet is full.

  - alert: KubeletHighNumberOfGoRoutines
    expr: go_goroutines{job=~".*kubelet"} > {{ dig "KubeletHighNumberOfGoRoutines" "threshold" "5000" .Values.prometheusRules }}
    for: {{ dig "KubeletHighNumberOfGoRoutines" "for" "5m" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubeletHighNumberOfGoRoutines" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubeletHighNumberOfGoRoutines.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: Kublet on `{{`{{ $labels.node }}`}}` might be unresponsive due to a high number of Go routines.
      summary: High number of Go routines.

  - alert: KubeletHighNumberOfGoRoutinesPredicted
    expr: abs(predict_linear(go_goroutines{job=~".*kubelet"}[1h], 2*3600)) > {{ dig "KubeletHighNumberOfGoRoutines" "threshold" "10000" .Values.prometheusRules }}
    for: {{ dig "KubeletHighNumberOfGoRoutinesPredicted" "for" "5m" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubeletHighNumberOfGoRoutinesPredicted" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubeletHighNumberOfGoRoutinesPredicted.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: Kublet on `{{`{{$labels.node}}`}}` might become unresponsive due to a high number of go routines within 2 hours.
      summary: Predicting high number of Go routines.

  - alert: KubeletManyRequestErrors
    expr: |
      (
      sum by (node) (
        rate(rest_client_requests_total{code=~"5.*", job="kubelet"}[5m])
        )
        /
      sum by (node) (
        rate(rest_client_requests_total{job="kubelet"}[5m])
        )
      ) * 100> 1
    for: {{ dig "KubeletManyRequestErrors" "for" "5m" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubeletManyRequestErrors" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubeletManyRequestErrors.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: "`{{`{{ $value | humanizePercentage }}`}}` of requests from kubelet on `{{`{{ $labels.node }}`}}` are erroneous."
      summary: Many HTTP 5xx responses for Kubelet requests.
