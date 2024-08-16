groups:
- name: kubernetes-node
  rules:
  - alert: KubernetesNodeHostHighCPUUsage
    expr: 100 - (avg by (node) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 90
    for: {{ dig "KubernetesNodeHostHighCPUUsage" "for" "6h" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubernetesNodeHostHighCPUUsage" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesNodeHostHighCPUUsage.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: Node `{{`{{ $labels.node }}`}}`has more than `{{`{{ $value | humanizePercentage }}`}}` CPU load for {{ dig "NodeHostHighCPUUsage" "for" "6h" .Values.prometheusRules }}
      summary: High CPU load on node.

  - alert: KubernetesNodeKernelDeadlock
    expr: kube_node_status_condition{condition="KernelDeadlock", status="true"} == 1
    for: {{ dig "KubernetesNodeKernelDeadlock" "for" "96h" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubernetesNodeKernelDeadlock" "severity" "info" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesNodeKernelDeadlock.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      summary: Permanent kernel deadlock on `{{`{{ $labels.node }}`}}`. Please drain and reboot node.
      description: The kernel of the node has deadlocked.

  - alert: KubernetesNodeDiskPressure
    expr: kube_node_status_condition{condition="DiskPressure", status="true"} == 1
    for: {{ dig "KubernetesNodeDiskPressure" "for" "5m" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubernetesNodeDiskPressure" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesNodeDiskPressure.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: Node `{{`{{ $labels.node }}`}}` under pressure due to insufficient available disk space.
      summary: Insufficient disk space for the node.

  - alert: KubernetesNodeMemoryPressure
    expr: kube_node_status_condition{condition="MemoryPressure", status="true"} == 1
    for: {{ dig "KubernetesNodeMemoryPressure" "for" "5m" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubernetesNodeMemoryPressure" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesNodeMemoryPressure.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: Node `{{`{{ $labels.node }}`}}` under pressure due to insufficient available memory.
      summary: Insufficient memory for the node.

  - alert: KubernetesNodeHighDiskUsagePercentage
    expr: |
      (
        100
        -
        100
        *
        sum(
          node_filesystem_avail_bytes{device!~"/dev/mapper/usr|tmpfs|by-uuid",fstype=~"xfs|ext|ext4"} 
          /
          node_filesystem_size_bytes{device!~"/dev/mapper/usr|tmpfs|by-uuid",fstype=~"xfs|ext|ext4"}
          ) by (node, device)
       )
       > 85
    for: {{ dig "KubernetesNodeHighDiskUsagePercentage" "for" "5m" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubernetesNodeHighDiskUsagePercentage" "severity" "info" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesNodeHighDiskUsagePercentage.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: Node disk usage above 85%
      summary: "Disk usage on `{{`{{ $labels.node }}`}}` at `{{`{{ $value | humanizePercentage }}`}}`"

  - alert: KubernetesNodeHighNumberOfOpenConnections
    expr: node_netstat_Tcp_CurrEstab > 20000
    for: {{ dig "KubernetesNodeHighNumberOfOpenConnections" "for" "15m" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubernetesNodeHighNumberOfOpenConnections" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesNodeHighNumberOfOpenConnections.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: The node `{{`{{ $labels.node }}`}}` has more than 20000 active TCP connections. The maximum possible number is 32768 connections.
      summary: High number of open TCP connections on node.

  - alert: KubernetesNodeHighRiseOfOpenConnections
    expr: predict_linear(node_netstat_Tcp_CurrEstab[20m], 3600) > 32768
    for: {{ dig "KubernetesNodeHighRiseOfOpenConnections" "for" "15m" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubernetesNodeHighRiseOfOpenConnections" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesNodeHighRiseOfOpenConnections.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: The node `{{`{{ $labels.node }}`}}` will probably reach 32768 active TCP connections within the next hour.If this happens, it will no longer be able to accept new connections.
      summary: High number of open TCP connections on node.

  - alert: KubernetesNodeContainerOOMKilled
    expr: sum by (node) (changes(node_vmstat_oom_kill[24h])) > 3
    labels:
      severity: {{ dig "KubernetesNodeContainerOOMKilled" "severity" "info" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesNodeContainerOOMKilled.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: More than 3 pods on node `{{`{{ $labels.node }}`}}` terminated within 24 hours by the Out of Memory Manager (OOMkilled).
      summary: More than 3 OOM killed pods on a node within 24h.

  - alert: KubernetesNodeHighNumberOfThreads
    expr: node_processes_threads > 31000
    for: {{ dig "KubernetesNodeHighNumberOfThreads" "for" "15m" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubernetesNodeHighNumberOfThreads" "severity" "critical" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesNodeHighNumberOfThreads.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: High number of threads on `{{`{{ $labels.node }}`}}`. Forking problems are imminent.
      summary: Very high number of threads on node.

  - alert: KubernetesNodeReadOnlyRootFilesystem
    expr: sum by (node) (node_filesystem_readonly{mountpoint="/"}) > 0
    for: {{ dig "KubernetesNodeReadOnlyRootFilesystem" "for" "15m" .Values.prometheusRules }}
    labels:
      severity: {{ dig "KubernetesNodeReadOnlyRootFilesystem" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesNodeReadOnlyRootFilesystem.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: The node `{{`{{ $labels.node }}`}}` has a read-only root file system. This can lead to unpredictable problems. A restart of the node is recommended to resolve the problem.
      summary: Read-only root filesystem on node.

  - alert: KubernetesNodeRebootsTooFast
    expr: max by (node) (changes(node_boot_time_seconds[1h])) > 2
    labels:
      severity: {{ dig "KubernetesNodeRebootsTooFast" "severity" "warning" .Values.prometheusRules }}
      runbook_url: https://github.com/cloudoperators/kubernetes-operations/playbooks/KubernetesNodeRebootsTooFast.md
    {{- if .Values.prometheusRules.additionalRuleLabels }}
      {{- toYaml .Values.prometheusRules.additionalRuleLabels | nindent 6 }}
    {{- end }}
    annotations:
      description: The node `{{`{{ $labels.node }}`}}` rebooted `{{`{{ $value | humanize }}`}}` times in the past hour. It could be stuck in a reboot/panic loop.
      summary: Node rebooted multiple times.
