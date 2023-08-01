The following network endpoints are used for communication into Armory CD-as-a-Service:

| DNS                       | Port | Protocol                                        | Description                                                                                                                                                                                                                                                                                                                                                   |
|---------------------------|------|-------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| agent-hub.cloud.armory.io | 443  | TLS enabled gRPC over HTTP/2<br>TLS version 1.2 | Remote Network Agent Hub connection; Agent Hub relays network traffic to privately networked resources such as Kubernetes APIs, Jenkins, or Prometheus, through Remote Network Agent (RNA) connections. Agent Hub does not require direct network access to the RNAs since they connect to Agent Hub through an encrypted, long-lived gRPC HTTP/2 connection. |
| api.cloud.armory.io       | 443  | HTTP over TLS (HTTPS)<br>TLS version 1.2        | Armory REST API; Clients connect to these APIs to interact with Armory CD-as-a-Service.    |
| auth.cloud.armory.io      | 443  | HTTP over TLS (HTTPS)<br>TLS version 1.2        | OIDC Service; The Open ID Connect (OIDC) service is used to authorize and authenticate machines and users. The Remote Network Agents, Armory Continuous Deployment (Spinnaker) plugin, and other services all authenticate against this endpoint. The service provides an identity token that can be passed to the Armory API and Agent Hub.                                   |
| console.cloud.armory.io   | 443  | HTTP over TLS (HTTPS)<br>TLS version 1.2        | Cloud Console; The browser-based UI for Armory CD-as-a-Service       |
| *.preview.cloud.armory.io | 443  | HTTP over TLS (HTTPS)<br>TLS version 1.2        | Preview Service; Creates a temporary public preview link to deployed services for testing; routes traffic to exposed services through Agent Hub plus Remote Network Agents.

All network traffic is encrypted while in transit.

Encryption in transit is over HTTPS using TLS encryption. When using Armory-provided software for both the client and server, these connections are secured by TLS 1.2. Certain APIs support older TLS versions for clients that do not support 1.2.

Encryption at rest uses AES256 encryption.
