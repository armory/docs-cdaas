You need [Client Credentials]({{< ref "iam/manage-client-creds" >}}) (**Client Secret** and **Client ID**) so your RNA can communicate with CD-as-a-Service.

1. If you have access to multiple clusters, make sure you are connected to the cluster where you want to deploy the RNA. See the `kubectl` [context](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-set-context-em-) reference for instructions.

1. Install the RNA.

   Replace `<client-secret>` and `<client-id>` with your Client Credentials.

   ```bash
   kubectl create ns armory-rna; 
   kubectl --namespace armory-rna create secret generic rna-client-credentials \
   --type=string \
   --from-literal=client-secret="<client-secret>" \
   --from-literal=client-id="<client-id>";
   kubectl apply -f "https://api.cloud.armory.io/kubernetes/agent/manifest?agentIdentifier=sample-cluster&namespace=armory-rna"
   ```
