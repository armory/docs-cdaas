1. Create a YAML file.

1. Customize your deployment file by setting the following minimum set of parameters:

   - `application`: The name of your app.
   - `targets.<deploymentName>`: A descriptive name for your deployment. Armory recommends using the environment name.
   - `targets.<deploymentName>.account`: This is the name of your RNA. If you installed the RNA manually, it is the value that you assigned to the `agentIdentifier` parameter.
  
  LAMBDA STUFF

1. (Optional) Ensure there are no YAML issues with your deployment file.

   Since a hidden tab in your YAML can cause your deployment to fail, it's a good idea to validate the structure and syntax in your deployment file. There are several online linters, IDE-based linters, and command line linters such as `yamllint` that you can use to validate your deployment file.

> You can view detailed configuration options in the {{< linkWithTitle "reference/deployment/config-file/_index.md" >}} section.
