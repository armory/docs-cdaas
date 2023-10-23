---
---
{{< alert color="warning" title="Deployment Queue: Deployment Configuration Features Not Yet Available" >}}
@TODO I pulled these from the lambda docs based on a comment from Stephen - are these correct???
- Blue/green strategy
- Traffic Management
- Constraints
  - `dependsOn`
  - `beforeDeployment`
  - `afterDeployment`
- Steps
  - `analysis`
  - `setWeight` with any value other than `100`
  - `pause`
  - `exposeServices`
{{< /alert >}}