{{/* Generate basic labels */}}
{{- define "kubernetes-operations.labels" }}
{{- $path := index . 0 -}}
{{- $root := index . 1 -}}
app.kubernetes.io/version: {{ $root.Chart.Version }}
app.kubernetes.io/part-of: cloudoperators.io/kubernetes-operations
{{- if $root.Values.commonLabels}}
{{ toYaml $root.Values.commonLabels }}
{{- end }}
{{- end }}

{{- define "kubernetes-operations.ruleSelectorLabels" }}
{{- $path := index . 0 -}}
{{- $root := index . 1 -}}
plugin: {{ $root.Release.Name }}
{{- if $root.Values.prometheusRules.ruleSelectors }}
{{- range $i, $target := $root.Values.prometheusRules.ruleSelectors }}
{{ $target.name | required (printf "$.Values.prometheusRules.ruleSelector.[%v].name missing" $i) }}: {{ tpl ($target.value | required (printf "$.Values.prometheusRules.ruleSelector.[%v].value missing" $i)) $ }}
{{- end }}
{{- end }}
{{- end }}

{{- define "kubernetes-operations.dashboardSelectorLabels" }}
{{- $path := index . 0 -}}
{{- $root := index . 1 -}}
plugin: {{ $root.Release.Name }}
{{- if $root.Values.dashboards.plutonoSelectors }}
{{- range $i, $target := $root.Values.dashboards.plutonoSelectors }}
{{ $target.name | required (printf "$.Values.dashboards.plutonoSelectors.[%v].name missing" $i) }}: {{ tpl ($target.value | required (printf "$.Values.dashboards.plutonoSelectors.[%v].value missing" $i)) $ }}
{{- end }}
{{- end }}
{{- end }}
