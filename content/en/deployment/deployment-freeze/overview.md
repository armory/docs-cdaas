---
title: How to Freeze Deployments
linkTitle: Freeze Deployments
weight: 10
description: >
  Freeze your individual deployments or deployments by account.
---

<!-- put images in this folder -->

## Overview of freezing deployments

CD-as-a-Service enables blocking the release of some or all applications to some or all accounts. In case of a bad change being shipped out, you  can block further deployments of specific applications to specific accounts. You have the flexibility to make sweeping changes like disabling deployments of all applications to all environments, or you could perform precision blocking, such as 2 applications on 1 production account.  You block and unblock deployments from within the CD-as-a-Service UI, thereby removing the need to actually maintain this configuration on your own. 

### Key features

* **Pause Deployments**: You can initiate a temporary deployment block for selected applications to selected accounts, ensuring that no updates are deployed during critical periods using the UI. 
* **Block Accounts**: You can choose to block deployments to specific accounts so that they can continue to deploy without having to write a custom deploy file. 
* **View Change History**: You can easily view the history of who made a change to block or unblock deployments, as well as what the change was.

