| Variable                 | Annotation                          | Environment variable      | Notes                                                                       |
|--------------------------|-------------------------------------|---------------------------|-----------------------------------------------------------------------------|
| accountName              | -                                   | -                         | The name of the account (or agentIdentifier) used to execute the deployment |
| applicationName          | `deploy.armory.io/application`      | `ARMORY_APPLICATION_NAME` | Added as annotation resources and as environment variables on  pods.<sup><b>1</b></sup>       |
| deploymentId             | `deploy.armory.io/deployment-id`    | `ARMORY_DEPLOYMENT_ID`    | Added as annotation resources and as environment variables on  pods.<sup><b>1</b></sup>  |
| endTimeEpochMillis       | -                                   | -                         | Exact end time of the current query interval in epoch milliseconds format   |
| endTimeEpochSeconds      | -                                   | -                         | Exact end time of the current query interval in epoch seconds format        |
| endTimeIso8601           | -                                   | -                         | Exact end time of the current query interval in ISO 8601 format             |
| environmentName          | `deploy.armory.io/environment`      | `ARMORY_ENVIRONMENT_NAME` | Added as annotation resources and as environment variables on  pods.<sup><b>1</b></sup>   |
| intervalMillis           | -                                   | -                         | Length of the current query interval in milliseconds                        |
| intervalSeconds          | -                                   | -                         | Length of the current query interval in seconds                             |
| namespace                | -                                   | -                         | The namespace resources are being deployed to                               |
| preview.`<service name>` | -                                   | -                         | URL to the `Service` resource exposed via `exposeServices` step.<sup><b>2</b></sup>        |
| promQlStepInterval       | -                                   | -                         | Used to aggregate PromQL functions to a single value                        |
| replicaSetName           | `deploy.armory.io/replica-set-name` | `ARMORY_REPLICA_SET_NAME` | Added as annotation resources and as environment variables on  pods.<sup><b>1</b></sup>   |
| startTimeEpochMillis     | -                                   | -                         | Exact start time of the current query interval in epoch milliseconds format |
| startTimeEpochSeconds    | -                                   | -                         | Exact start time of the current query interval in epoch seconds format      |
| startTimeIso8601         | -                                   | -                         | Exact start time of the current query interval in ISO 8601 format           |

**1**: If you are using a metrics implementation like [Micrometer](https://micrometer.io/), make sure to configure it to report these metrics to your metrics provider. 

**2**: Service preview links are scoped to the strategy and `afterDeployment` constraints section. Do consider adjusting preview link's TTL property, otherwise you may end up serving links which have already expired.   

If your deployment strategy contains an `exposeServices` step, all exposed service preview links are available as part of the `armory.preview` sub-context. For example, if you create service preview for service `my-http-service` you could access it using `armory.preview.my-http-service`.