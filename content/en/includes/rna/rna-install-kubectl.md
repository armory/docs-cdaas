
**{{% heading "prereq" %}}**

* You have [Client Credentials]({{< ref "iam/manage-client-creds" >}}) (Client Secret and Client ID)
* You are connected to the Kubernetes cluster where you want to install the RNA.

**Install**

This script installs the RNA into Namespace `armory-rna` with Agent Identifier `sample-cluster`.

Replace `<client-secret>` and `<client-id>` with your Client Secret and Client ID.

```bash
kubectl create ns armory-rna; 
kubectl --namespace armory-rna create secret generic rna-client-credentials \
--type=string \
--from-literal=client-secret="<client-secret>" \
--from-literal=client-id="<client-id>";
kubectl apply -f "https://api.cloud.armory.io/kubernetes/agent/manifest?agentIdentifier=sample-cluster&namespace=armory-rna"
```
