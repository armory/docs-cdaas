---
title: Deployment Strategies Overview
linktitle: Overview
weight: 1
description: >
  Learn about blue/green and canary deployment strategies for deploying your apps to Kubernetes using Armory CD-as-a-Service. Compare features to decide which strategy fits your use case. 
categories: ["Deployment Strategies", "Features", "Concepts"]
tags: ["Canary", "Blue/Green"]
---

## What is a deployment strategy?

A deployment strategy is the procedure that CD-as-a-Service uses to deploy your changes to a deployment target. Different strategies prioritize different benefits such as speed, ability to rollback, and minimizing risk to a small subset of users.  CD-as-a-Service offers two different deployment strategies that you can customize to meet your needs and priorities: [canary](#canary-deployment-strategy) and [blue/green](#bluegreen-deployment-strategy).

## Canary deployment strategy

In a canary deployment strategy, you introduce new changes to a small subset of your users while the  majority remain on the known stable version. You can then monitor the new version while impacting the smallest possible number of users if a problem should arise. 

### Canary steps

CD-as-a-Service provides the following steps as part of a canary deployment: 

- `setWeight`: You specify the amount of traffic being directed to the new version.
- `pause`: You can pause the strategy for a set period of time or until an authorized user approves continuing deployment.
- `analysis`: Use the CD-as-a-Service Automated Canary Analysis feature to perform metrics analysis on your deployment. Based on the results of the queries, the deployment can automatically continue or roll back.
- `runWebhook`: Leverage your existing tooling to run external jobs such as API tests and database migrations. Deployments can automatically continue, pause, or roll back based on the result of the external job. 

### Example deployment process in a canary strategy

Engineers often implement a canary strategy with steps that may look something like this:

1. You identify the amount of traffic you would like to expose to the new version.
1. The system deploys the new version to the target and routes the specified amount of traffic to the new version.
1. You monitor the new version for issues. You can automate this by using CD-as-a-Service's Automated Canary Analysis feature. 
1. Once you have gained confidence in the new version, you can increase the percentage of traffic directed to the new version or roll back traffic to the known stable version.
1. Repeat monitoring and analysis until 100% of your traffic is directed to the new version or you have decided to roll back. 

### Benefits 

The primary benefit of a canary deployment strategy is risk mitigation. By exposing a small subset of users to your new changes, you can identify and address potential issues while reducing the risk of a widespread disruption. 

In addition to risk mitigation, a canary deployment strategy provides a better user experience by validating new features with a smaller user base. This approach helps limit negative impacts on the wider user base while allowing you to solicit feedback earlier in the deployment process. 

## Blue/Green deployment strategy

In a blue/green deployment strategy, you deploy and maintain two identical production environments throughout the execution of the deployment. You maintain _blue_ and _green_ production environments. The _blue_ environment contains the latest known stable version of your app (usually the version you are replacing with the new version) while the _green_ environment contains the changes you are currently deploying. 

Once you deploy to the green environment, traffic continues to flow exclusively to the blue environment, allowing you to validate and test the changes in your green environment. You can do this via manual testing, automated testing, or any other validation method you may use. 

After validating your changes in the green environment, a blue/green strategy routes traffic to the green environment, which then becomes the active environment. 

Once traffic routes to the green environment, you can specify conditions that should be met (additional testing, automated canary analysis, manual approval, or a set period of time) after which the blue environment is shut down. 

### Blue/Green steps

You can specify the following steps as conditions that must be met prior to routing traffic to the green environment and before shutting down the blue environment:

- `pause`: You can pause the strategy for a set period of time or until an authorized user approves continuing deployment.
- `analysis`: Use the CD-as-a-Service Automated Canary Analysis feature to perform metrics analysis on your deployment. Based on the results of the queries, the deployment can automatically continue or roll back.
- `exposeServices` - Expose the green environment as a dark deployment using a [preview link URL]({{<ref "reference/deployment/config-preview-link">}}) generated by CD-as-a-Service. You can then access the green environment directly for testing without needing to expose it to your users. 
- `runWebhook`: Leverage your existing tooling to run external jobs such as API tests and database migrations. Deployments can automatically continue, pause or roll back based on the result of the external job. Paired with `exposeServices`, this step can execute automated tests against the green environment.

### Example deployment process in a blue/green strategy

Engineers often implement a canary strategy with steps that may look something like this:

1. A new green environment running your changes is created without any traffic being routed to it.
1. You expose the green environment internally using the CD-as-a-Service [preview feature]({{<ref "reference/deployment/config-preview-link">}}). 
1. You execute your test plan against the green environment. 
1. Once your testing and approval requirements are met, traffic is shifted to the green environment.
1. You monitor the green environment until a set of requirements is fulfilled (such as manual approvals, canary analysis, or automated testing passes)
1. Once your requirements are fulfilled, the blue environment is shut down and the leaving only the new version running.

### Benefits

The blue/green deployment strategy gives you the benefit of running tests against a full copy of your production environment prior to any traffic being routed to the new version. This approach means zero downtime deployments and reduced risk when exposing users to new versions of your app. 

In addition, because the blue/green strategy maintains the blue environment until the shutdown conditions are met, blue/green gives you the ability to instantly roll back to a known stable version should you detect any issues during the deployment. 

## When to use each strategy

Both the canary and blue/green strategies have trade-offs that can help you determine which strategy is best for your use case. 

### When to use the canary strategy

Canary is best for use cases where you want to minimize risk by exposing your changes to a small percentage of users and monitor prior to exposing the changes to the majority user base. This allows you to ensure stability and performance of the new version before creating a widespread impact. This minimizes the impact of potential issues on user.

To use a canary strategy effectively, the performance of the canary version needs to be accurately measured. Additionally, it is necessary to determine if the performance of the canary falls within an acceptable range. For instance, a common metric used is the percentage of 5xx responses in the canary version. While integrating monitoring tools to conduct canary analysis is straightforward, finding the correct thresholds for health metrics can be challenging. A canary strategy is suited for you, if you are already aware of metrics and thresholds that determine the health of your application.

### When to use the blue/green strategy

Blue/Green deployments are great when you want the ability to rapidly roll back if issues are detected. Given that both the blue and green environments are running in parallel you have the ability to instantly shift traffic from one to the other. 

In addition, the blue/green strategy can give you increased confidence by allowing to your test your changes in the green environment as a dark deployment before users are exposed to the changes minimizing any potential impacts. You can accomplish this using the [CD-as-a-Service Preview Service]({{<ref "reference/deployment/config-preview-link">}}).

Blue/Green deployment strategy is basic, so it is easier to configure and use if you are just getting started with adopting advanced deployment strategies.

### Summary

If you need to prioritize rapid rollback or running tests in production with no risk of impact to users, blue/green is the strategy that makes the most sense for your use case. 

Conversely, if you need to prioritize minimizing the impact of issues to the smallest percentage of traffic while rolling out changes in a controlled manner, the canary strategy would work best for you. 

## {{% heading "nextSteps" %}}

* Learn how to deploy using a blue/green strategy: {{< linkWithTitle "deployment/strategies/blue-green.md" >}}.
* Learn how to deploy using a canary strategy: {{< linkWithTitle "deployment/strategies/canary.md" >}}.
