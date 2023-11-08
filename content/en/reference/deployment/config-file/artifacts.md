---
title: Artifacts (AWS Lambda)
description: >
  Declare your AWS Lambda artifacts (functionName, path, type).
---


## Artifacts

This section defines the artifacts you are deploying. By default, the artifacts reach all targets, but you can specify certain targets if needed.

```yaml
artifacts:
  - functionName: <function-name>
    path: <path-to-function>  # S3 bucket
    type: zipFile
```

- `functionName`: 
- `path`: The S3 path to your function archive? 

does cdaas support lambda container images uploaded to amazon ecr?

- `type`: ?  AWS also supports 






