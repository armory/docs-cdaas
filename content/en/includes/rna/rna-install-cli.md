>You do not need to create Client Credentials for this option. The CLI does that for you.

**{{% heading "prereq" %}}**

If you haven't already, install the CLI and make sure you are connected to your cluster.

* [Install the CLI]({{< ref "cli" >}}).
* Set your `kubectl` [context](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-set-context-em-) to connect to the cluster where you want to deploy the RNA.

   ```bash
   kubectl config use-context <NAME>
   ```

**Steps**

1. Log in using the CLI.

   ```shell
   armory login
   ``` 

1. Install the RNA in your cluster.

   ```shell
   armory agent create
   ```

   Follow the prompts to provide information. You choose your cluster and provide an **agent identifier** (cluster name) for the RNA during the installation process.