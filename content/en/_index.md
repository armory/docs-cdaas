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
  A declarative developer experience that represents how engineers actually want their software deployed. Easily integrate with the tools you already use via a flexible CLI and custom web-hooks. No more need for custom scripts and duct-taped solutions.
---

## What Continuous Deployment-as-a-Service is
Armory Continuous Deployment-as-a-Service (CDaaS) is a centralized control plane that allows you to deploy to multiple Kubernetes clusters using our secure agent architecture. CDaaS enables multi-environment, multi-region application rollouts with promotion constraints and advanced deployment strategies, such as canary and blue/green.

## Why Armory CD-as-a-Service
Modern software delivery requires sophisticated control of delivery speed, traffic management, and integration with external tools and verification processes. 

Software Delivery is rarely a single environment. Most workflows require promotion from one environment or region to another after some set of constraints has been met, such as test executions, manual approvals, CI workflows, canary analysis, etc.

CDaaS uses centralized business logic, native Kubernetes resources and logic-less Remote Network Agents that act as simple network relays and provide the control plane with service account based Kubernetes credentials. This allows you to get new features immediately without having to worry about edge maintenance. No agent upgrade change campaigns within your organization, or need to manage [Custom Resource Definitions (CRDs)](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/#customresourcedefinitions).  

{{< include "cdaas-explained-how.md" >}}
