{{/* Generate basic labels */}}
{{- define "kubernetes-operations.labels" }}
{{- $path := index . 0 -}}
{{- $root := index . 1 -}}
app.kubernetes.io/version: {{ $root.Chart.Version }}
app.kubernetes.io/part-of: {{ $root.Release.Name }}
{{- if $root.Values.global.commonLabels}}
{{ toYaml $root.Values.global.commonLabels }}
{{- end }}
{{- end }}

{{- define "kubernetes-operations.ruleSelectorLabels" }}
{{- $path := index . 0 -}}
{{- $root := index . 1 -}}
plugin: {{ $root.Release.Name }}
{{- if $root.Values.prometheusRules.ruleSelectors }}
{{- range $i, $target := $root.Values.prometheusRules.ruleSelectors }}
{{ $target.name | required (printf "$.Values.prometheusRules.ruleSelector.[%v].name missing" $i) }}: {{ tpl ($target.value | required (printf "$.Values.prometheusRules.ruleSelector.[%v].value missing" $i)) $root }}
{{- end }}
{{- end }}
{{- end }}

{{- define "kubernetes-operations.additionalRuleLabels" }}
{{- if .Values.prometheusRules.additionalRuleLabels }}
{{- toYaml .Values.prometheusRules.additionalRuleLabels }}
{{- end }}
{{- if .Values.global.commonLabels }}
{{ tpl (toYaml .Values.global.commonLabels) . }}
{{- end }}
{{- end }}

{{/*
Optionally append a kube_pod_labels join to pod-level alert expressions.
Enriches alerts with configurable labels from kube_pod_labels.
Enable via .Values.prometheusRules.kubeLabels (list of label names, e.g. [label_app, label_team, label_environment])
*/}}
{{- define "kubernetes-operations.kubePodLabelsJoin" -}}
{{- if .Values.prometheusRules.kubeLabels }}
      * on(pod, namespace) group_left({{ join ", " .Values.prometheusRules.kubeLabels }})
        kube_pod_labels
{{- end -}}
{{- end -}}

{{/*
Optionally append a kube_deployment_labels join to deployment-level alert expressions.
Enriches alerts with configurable labels from kube_deployment_labels.
Enable via .Values.prometheusRules.kubeLabels (list of label names, e.g. [label_app, label_team, label_environment])
*/}}
{{- define "kubernetes-operations.kubeDeploymentLabelsJoin" -}}
{{- if .Values.prometheusRules.kubeLabels }}
      * on(namespace, deployment) group_left({{ join ", " .Values.prometheusRules.kubeLabels }})
        kube_deployment_labels
{{- end -}}
{{- end -}}

{{- define "kubernetes-operations.persesDashboardSelectorLabels" }}
{{- $path := index . 0 -}}
{{- $root := index . 1 -}}
plugin: {{ $root.Release.Name }}
{{- if $root.Values.dashboards.persesSelectors }}
{{- range $i, $target := $root.Values.dashboards.persesSelectors }}
{{ $target.name | required (printf "$.Values.dashboards.persesSelectors.[%v].name missing" $i) }}: {{ tpl ($target.value | required (printf "$.Values.dashboards.persesSelectors.[%v].value missing" $i)) $ }}
{{- end }}
{{- end }}
{{- end }}
