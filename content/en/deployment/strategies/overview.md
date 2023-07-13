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

