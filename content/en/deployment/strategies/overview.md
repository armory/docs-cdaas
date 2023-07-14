---
title: Deployment Strategies Overview
linktitle: Overview
weight: 1
description: >
  Learn about blue/green and canary deployment strategies, which you can use when you deploy your apps to Kubernetes using Armory CD-as-a-Service. 
categories: ["Deployment Strategies", "Features", "Concepts"]
tags: ["Canary", "Blue/Green"]
---

## What is a deployment Strategy

A deployment strategy is the procedure that CD-as-a-Service uses to deploy your changes to a deployment target. 

Different strategies prioritize different benefits such as speed, ability to rollback, and minimizing risk to a small subset of users. 

Armory CD-as-a-Service offers two different deployment strategies that can be customized depending on your needs and priorities. 

## The Canary Deployment Strategy

A canary deployment strategy is one where your new changes are introduced to a small subset of your users while the 
majority remain on the known stable version.

This allows you to monitor the new version while impacting the smallest possible number of users if a problem should arise. 

### Steps Available in a Canary Deployment Strategy

The following steps are available as part of a canary deployment. Detailed documentation on the configuration and usage of each step is available on our [canary strategy guide]({{< ref "deployment/strategies/canary" >}})

- setWeight - Allows you to specify the amount of traffic being directed to the new version
- pause - Allows you to pause the strategy for a set period of time or until an authorized user approves continuing
- analysis - Leverages the CD-as-a-Service Automated Canary Analysis feature to perform metrics analysis to allow you to decide to continue or rollback in an automated fashion
- runWebhook - Leverages your existing tooling to run external jobs such as api tests and database migrations. Deployments can be automatically continued, paused or rolled back pending the result of the external job. 

### Example Canary Deployment Strategy
A canary strategy is often implemented with steps that may look something like this.

1. You identify the amount of traffic you would like to expose to the new version
2. The new version is deployed to the target and the specified amount of traffic is routed to the new version
3. You monitor the new version for issues. With tools like CD-as-a-Service's Automated Canary Analysis you can automate this monitoring if desired. 
4. Once you have gained confidence in the new version you can increase the percentage of traffic being directed to the new version or roll back traffic to the known stable version
5. Repeat steps 3 and 4 until 100% of your traffic is being directed to the new version or you have decided to roll back. 

### Benefits of a Canary Deployment Strategy
The primary benefit of a canary deployment strategy is risk mitigation. By exposing a small subset of users
to your new changes you can identify and address potential issues while reducing the risk of a widespread disruption. 

In addition, a canary deployment strategy allows you to provide a better user experience by validating new features with a 
smaller user base. This approach helps limit negative impacts on the wider user-base while allowing you to solicit feedback
earlier in the deployment process. 

## The Blue-Green Deployment Strategy
The Blue-Green Deployment Strategy is one where you deploy and maintain two identical production environments throughout 
the execution of the deployment. In this strategy you will maintain a 'blue' and a 'green' production environment. The 'blue'
environment will contain your latest known stable version of your application (usually the version you are replacing with
the new version) while the 'green' environment contains the changes you are currently deploying. 

Once the 'green' environment is deployed traffic continues to flow exclusively to the 'blue' environment allowing you to 
validate and test the changes in your 'green' environment. This can be done via manual testing, automated testing or any
other validation method you may use. 

After validating your changes in the 'green' environment traffic will begin being routed to the 'green' environment which
becomes the active environment. 

Once traffic is being routed to the 'green' environment you can specify conditions that should be met (additional testing,
automated canary analysis, manual approval, or a set period of time) after which the 'blue' environment will be shut down. 

### Steps available during the Blue-Green Deployment Strategy

During a blue-green deployment you can specify the following steps as conditions that must be met prior to routing traffic
to the 'green' environment and before shutting down the 'blue' environment: 

Details on each of these steps and their usage can be found in the [blue-green strategy guide]({{<ref "deployment/strategies/blue-green">}})

- pause - Allows you to wait a specified period of time or wait for an authorized user to issue an approval prior to continuing with the deployment
- analysis - Uses CD-as-a-Service's Automated Canary Analysis feature to analyze the metrics in the 'green' environment and automatically judge if a deployment should continue
- exposeServices - Allows you to expose the 'green' environment as a dark deployment using a url generated by CD-as-a-Service. This allows you to access the 'green' environment directly for testing without needing to expose it to your users. More information can be found in the [reference documentation for the CD-as-a-Service Preview Service]({{<ref "reference/deployment/config-preview-link">}})
- runWebhook - Allows you to execute tests and scripts using your existing tooling, paired with `exposeServices` you can leverage this step to execute automated tests against the 'green' environment.  

### Benefits of the Blue-Green Deployment Strategy
The blue-green deployment strategy gives you the benefits of running tests against a full copy of your production environment 
prior to any traffic being routed to the new version. This allows for zero-downtime deployments and reduced risk when exposing
users to new versions of your application. 

In addition, because the blue-green strategy maintains the 'blue' environment until the shutdown conditions are met it 
gives you the ability to instantly roll back to a known stable version should any issues be detected during the deployment. 

## When to use each strategy

Both the canary and blue-green strategies have trade-offs that can help you determine which strategy is best for your use case. 

### When to use the Canary strategy

Canary is best for use cases where you want to minimize risk by exposing your changes to a small percentage of users and 
monitor prior to exposing the changes to the majority user base. This allows you to ensure stability and performance of 
the new version before creating a widespread impact. This minimizes the impact of potential issues on user.

### When to use the Blue-Green strategy

Blue-Green deployments are great when you want the ability to rapidly rollback if issues are detected. Given that both 
the 'blue' and 'green' environments are running in parallel you have the ability to instantly shift traffic from one to
the other. 

In addition, the blue-green strategy can give you increased confidence by allowing to your test your changes in the 
'green' environment as a dark deployment before users are exposed to the changes minimizing any potential impacts. This 
can be accomplished using the [CD-as-a-Service Preview Service]({{<ref "reference/deployment/config-preview-link">}})

### Summary

If you need to prioritize rapid rollback or running tests in production with no risk of impact to users blue-green is 
probably the strategy that makes the most sense for your use case. 

Conversely, if you need to prioritize minimizing the impact of issues to the smallest percentage of traffic while rolling out
changes in a controlled manner the canary strategy is likely the strategy that will work best for you. 