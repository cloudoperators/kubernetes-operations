# kubernetes-operations

[![REUSE status](https://api.reuse.software/badge/github.com/cloudoperators/k8s-monitoring)](https://api.reuse.software/info/github.com/cloudoperators/k8s-monitoring)

## About this project

A set of Plutono dashboards and Prometheus alerting rules combined with playbooks to ensure effective operations of Kubernetes.

# Content

The content is structured as follows:

```
kubernetes-operations
    │
    ├── playbooks/              Step-by-step instructions for troubleshooting.
    │                           
    └── charts/
         │
         └── kubernetes-operations
              │
              ├── aggregations       Prometheus aggregation rules for kubernetes.
              │
              ├── alerts             Prometheus alerts for kubernetes.
              │
              ├── dashboards         Plutono dashboards for visualizing key metrics.
              │
              └── Chart.yaml         Helm chart manifest.
```

## Requirements and Setup

The content of the repository can be installed independently or as part of the [greenhouse-extensions](https://github.com/cloudoperators/greenhouse-extensions/tree/main/kube-monitoring).

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| dashboards.create | bool | `true` | Enables ConfigMap resources with dashboards to be created |
| dashboards.plutonoSelectors | list | `[{"name":"plutono-dashboard","value":"\"true\""}]` | Label selectors for the Plutono dashboards to be picked up by Plutono. |
| global.commonLabels | object | `{}` | Common labels to add to all resources # |
| prometheusRules.NodeInMaintenance | object | `{"label":"maintenance_state","value":"in-maintenance"}` | The label value pair that marks a Kubernetes node as 'in maintenance' |
| prometheusRules.additionalRuleAnnotations | object | `{}` | Additional annotations for PrometheusRule alerts |
| prometheusRules.additionalRuleLabels | string | `nil` | Additional labels for PrometheusRule alerts # This is useful for adding additional labels such as "support_group" or "service" for the routing of alerts to each rule |
| prometheusRules.annotations | object | `{}` |  |
| prometheusRules.create | bool | `true` | Enables PrometheusRule resources to be created |
| prometheusRules.disabled | object | `{}` | Disabled PrometheusRule alerts |
| prometheusRules.labels | object | `{}` | Labels for PrometheusRules |
| prometheusRules.ruleSelectors | string | `nil` | Label selectors for the Prometheus rules to be picked up by Prometheus. |

## Support, Feedback, Contributing

This project is open to feature requests/suggestions, bug reports etc. via [GitHub issues](https://github.com/cloudoperators/k8s-monitoring/issues). Contribution and feedback are encouraged and always welcome. For more information about how to contribute, the project structure, as well as additional contribution information, see our [Contribution Guidelines](CONTRIBUTING.md).

## Security / Disclosure
If you find any bug that may be a security problem, please follow our instructions at [in our security policy](https://github.com/cloudoperators/k8s-monitoring/security/policy) on how to report it. Please do not create GitHub issues for security-related doubts or problems.

## Code of Conduct

We as members, contributors, and leaders pledge to make participation in our community a harassment-free experience for everyone. By participating in this project, you agree to abide by its [Code of Conduct](https://github.com/cloudoperators/.github/blob/main/CODE_OF_CONDUCT.md) at all times.

## Licensing

Copyright 2024 SAP SE or an SAP affiliate company and k8s-monitoring contributors. Please see our [LICENSE](LICENSE) for copyright and license information. Detailed information including third-party components and their licensing/copyright information is available [via the REUSE tool](https://api.reuse.software/info/github.com/cloudoperators/k8s-monitoring).

# Contributing

If you are contributing to the `kubernetes-operations` chart, update the associated content and increment the version in the `Chart.yaml`. 

If you use this chart with the [kube-monitoring](https://github.com/cloudoperators/greenhouse-extensions/tree/main/kube-monitoring) Plugin from [Greenhouse](https://github.com/cloudoperators/greenhouse), update the version in the [Chart.yaml](https://github.com/cloudoperators/greenhouse-extensions/blob/main/kube-monitoring/charts/Chart.yaml) as well as the [plugindefinition](https://github.com/cloudoperators/greenhouse-extensions/blob/main/kube-monitoring/plugindefinition.yaml) versions of `kube-monitoring` so that the operations platform can perform the rollout.
