groups:
- name: kubernetes-health
  rules:
  - alert: KubeStateMetricsScrapeFailed
    expr: up{job=~".*kube-state-metrics.*"} == 0 or absent(up{job=~".*kube-state-metrics.*"})
    for: {{ dig "KubeStateMetricsScrapeFailed" "for" "1h" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubeStateMetricsScrapeFailed" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubeStateMetricsScrapeFailed.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: Failed to scrape kube-state-metrics. Metrics on the cluster state might be outdated.
      summary: kube-state-metrics scrape failed.

  - alert: KubernetesManyNodesNotReady
    expr: count((kube_node_status_condition{condition="Ready",status="true"}) == 0) > 4
    for: {{ dig "KubernetesManyNodesNotReady" "for" "1h" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubernetesNodeManyNotReady" "severity" "critical" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesManyNodesNotReady.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: "`{{`{{ $value }}`}}` nodes are `NotReady` for more than an hour."
      summary: Many Nodes are NotReady.

  - alert: KubernetesNodeNotReady
    expr: sum by (node) (kube_node_status_condition{condition="Ready",status="true"} == 0)
    for: {{ dig "KubernetesNodeNotReady" "for" "1h" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubernetesNodeNotReady" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesNodeNotReady.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      summary: Node status is NotReady.
      description: Node `{{`{{ $labels.node }}`}}` is NotReady for more than an hour.

  - alert: KubernetesNodeReadinessFlapping
    expr: sum(changes(kube_node_status_condition{job=~".*kube-state-metrics.*",status="true",condition="Ready"}[15m])) by (node) > 2
    for: {{ dig "KubernetesNodeReadinessFlapping" "for" "1h" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubernetesNodeReadinessFlapping" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesNodeReadinessFlapping.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: Node `{{`{{ $labels.node }}`}}` is flapping between Ready and NotReady.
      summary: Node readiness status is flapping.

  - alert: KubernetesPodRestartingTooMuch
    expr: sum by(pod, namespace, container) (rate(kube_pod_container_status_restarts_total[15m])) > 0
    for: {{ dig "KubernetesPodRestartingTooMuch" "for" "1h" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubernetesPodRestartingTooMuch" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesPodRestartingTooMuch.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: Container `{{`{{ $labels.container }}`}}` of pod `{{`{{ $labels.namespace }}/{{ $labels.pod }}`}}` is restarting constantly.
      summary: Pod is in a restart loop.

  - alert: KubernetesTooManyOpenFiles
    expr: |
      100 * process_open_fds{job=~".*kubelet|.*apiserver"} / process_max_fds > 50
    for: {{ dig "KubernetesTooManyOpenFiles" "for" "10m" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubernetesTooManyOpenFiles" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesTooManyOpenFiles.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: "`{{`{{ $labels.job }}`}}` on `{{`{{ $labels.node }}`}}` is using `{{`{{ $value }}%`}}` of the available `file/socket` descriptors."
      summary: Too many open file descriptors.

  - alert: KubernetesDeploymentReplicasMismatch
    expr: |
      (
        kube_deployment_spec_replicas{job=~".*kube-state-metrics.*"}
          >
        kube_deployment_status_replicas_available{job=~".*kube-state-metrics.*"}
      ) and (
        changes(kube_deployment_status_replicas_updated{job=~".*kube-state-metrics.*"}[10m])
          ==
        0
      )
    for: {{ dig "KubernetesDeploymentReplicasMismatch" "for" "10m" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubernetesDeploymentReplicasMismatch" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesDeploymentReplicasMismatch.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: Deployment `{{`{{ $labels.namespace }}/{{ $labels.deployment }}`}}` has not matched the expected number of replicas for longer than 10 minutes.
      summary: Deployment has not matched the expected number of replicas.

  - alert: KubePodNotReady
    # alert on pods that are not ready but in the Running phase on a Ready node
    expr: |
      (
        (max by (namespace, pod, node, phase) (kube_pod_status_phase{phase="Running"}) 
          * on(pod) group_left(node) max by (node, pod) (kube_pod_info))
            * on(pod, node, namespace)
        (max by (namespace, pod, node, phase) (kube_pod_status_ready{condition="false"}) 
          * on(pod) group_left(node) max by (node, pod) (kube_pod_info))
            * on(node) group_left()
         sum by(node) (kube_node_status_condition{condition="Ready"})
           ==
         1
      )
    for: {{ dig "KubePodNotReady" "for" "30m" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubePodNotReady" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubePodNotReady.md 
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: Pod `{{`{{ $labels.namespace }}/{{ $labels.pod }}`}}` has been in a non-ready state for longer than {{ dig "KubePodNotReady" "for" "30m" .Values.prometheusRules }} minutes.
      summary: Pod has been in a non-ready state for more than {{ dig "KubePodNotReady" "for" "30m" .Values.prometheusRules }} minutes.

