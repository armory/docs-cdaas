---
title: Armory Continuous Deployment-as-a-Service Docs
linkTitle: Documentation
type: "docs"
cascade:
- _target:
    path: "/**"
    kind: "page"
  type: "docs"
- _target:
    path: "/**"
    kind: "section"
  type: "docs"
- _target:
    path: "/**"
    kind: "section"
  type: "home"
no_list: true
description: >
  Armory CD-as-a-Service is a declarative deployment experience that represents how engineers actually want their software deployed. Easily integrate with the tools you already use via a flexible CLI and custom webhooks. 
---

## What CD-as-a-Service is

Modern software delivery requires sophisticated control of delivery speed and traffic management, as well as integration with external tools and verification processes. Software is rarely deployed to a single environment. Most workflows require promotion from one environment or region to another after meeting constraints such as test executions, manual approvals, CI workflows, and canary analysis. **CD-as-a-Service is a centralized control plane that encapsulates those features and enables deployment to multiple Kubernetes clusters using a secure Kubernetes agent architecture.** CD-as-a-Service supports multi-environment, multi-region app deployments with promotion constraints and advanced deployment strategies, such as canary and blue/green.

## Why you should use CD-as-a-Service

* **Native Kubernetes resources:** You create your Kubernetes manifests how you want - manually or by using a tool like Helm or Kustomize.
* **Logicless Kubernetes agents in your clusters:** CD-as-a-Service's _Remote Network Agents (RNAs)_ act as simple network relays and provide the CD-as-a-Service control plane with Kubernetes ServiceAccount-based credentials. You don't need to open any ports to grant CD-as-a-Service deployment access to your Kubernetes clusters.
* **Centralized business logic:** Deployment logic is encapsulated in the control plane. You get new features immediately without having to worry about edge maintenance -- no Remote Network Agent upgrade campaigns within your organization, no need to manage [Custom Resource Definitions (CRDs)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/#customresourcedefinitions).  
* **Declarative deployment:** You define your software delivery requirements, traffic shaping, canary analysis, webhooks, and manual approvals in a [declarative deployment configuration file]({{< ref "deployment/overview.md" >}}).
* **Integration with your existing SDLC:** You build and publish your containers where and how you want, whether you use Docker Hub or a private registry that is only accessible in your network.

{{< include "cdaas-explained-how.md" >}}
