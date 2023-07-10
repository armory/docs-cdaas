---
---

{{< cardpane >}}
{{< card code=true header="CD-as-a-Service Deployment (deploy.yaml)" lang="yaml">}}
version: v1
kind: kubernetes
application: reviews
targets: 
  dev:
    account: dev
    namespace: istiodemo
		strategy: strategy1 
manifests:
  - path: manifests/reviews.yaml
  - path: manifests/istio-resources.yaml
strategies:
  strategy1:
    canary: 
      steps:
        - setWeight:
            weight: 10
        - pause:
            untilApproved: true
        - setWeight:
            weight: 90
        - pause:
            untilApproved: true
trafficManagement:
  - targets: ["dev"]
    istio:
    - virtualService: 
        name: reviews 
        httpRouteName: http-route-reviews
      destinationRule: 
        name: reviews 
        activeSubsetName: stable
        canarySubsetName: canary # does not exist yet
{{< /card >}}
{{< card code=true header="Istio Resources (istio-resources.yaml)" lang="yaml" >}}
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
    - reviews
  http:
  - route:
    - destination:
        host: reviews.istiodemo.svc.cluster.local
        subset: stable
    name: http-route-reviews
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews
spec:
  host: reviews.istiodemo.svc.cluster.local
  subsets:
  - name: stable
    labels:
      app: reviews
{{< /card >}}
{{< /cardpane >}}

**Mapping**
<br>

| Deployment Field (deploy.yaml)  | Deploy Line | Istio Resources Field (istio-resources.yaml) | Istio Line | 
|----------------------------------|-------------|----------------------------------------------|------------|
| virtualService.name              | 28          | VirtualService.metadata.name                 | 4          |
| virtualService.httpRouteName     | 29          | VirtualService.http.route.name               | 13         |
| destinationRule.name             | 31          | DestinationRule.metadata.name                | 18         |
| destinationRule.activeSubsetName | 32          | VirtualService.http.route.destination.subset | 12         |



<!--  top of file must have the two lines of --- followed by a blank line or Hugo throws a compile error due to the embedded Prism shortcode. -->
<!-- Do not "include" using the "%" version! -->
