---
title: KubernetesAPIServerDown
weight: 20
---

# KubernetesAPIServerDown

## Problem

The `KubernetesAPIServerDown` alert is triggered when all Kubernetes API servers have not
been reachable by the monitoring system for more than 15 minutes.

## Impact

This is a critical alert. The Kubernetes API is not responding. The
cluster may be partially or completely non-functional.

Applications that do not use the Kubernetes API directly will continue to work. Modifying Kubernetes resources is not possible.
in the cluster.

Services that use the Kubernetes API directly start to behave incorrectly.

## Diagnosis

Check the status of the API server targets in the Prometheus user interface.

Then check if the API is also unresponsive for you:

```shell
$ kubectl cluster-info
```

If you can still reach the API server, there may be a network problem between the
Prometheus instances and the API server pods. Check the status of the API server
pods.

```shell
$ kubectl -n kube-system get pods
$ kubectl -n kube-system logs -l 'component=kube-apiserver'
```

- Check the network on the node.
- Check the firewall on the node.
- Check the Kube proxy logs.
- Check NetworkPolicies if prometheus/kubeApi has not been filtered out.


## Resolution steps

If you can still reach the API server intermittently, you can handle this
like any other failed deployment. If not, you may need to refer
refer to the disaster recovery documentation.
