---
title: Application and Kind Config
description: >
  Declare your app name and specify whether the deployment is to Kubernetes or AWS Lambda.
---


## Fields

```yaml
version: v1
kind: <kind>
application: <name>
```

- `kind`: `kubernetes` or `lambda`
- `application`: Provide a descriptive name for your Kubernetes app or Lambda function so that you can identify it when viewing the status of your deployment in the **Deployments UI** and other locations.
