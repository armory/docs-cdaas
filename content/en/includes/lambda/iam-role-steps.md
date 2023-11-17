1. In your default browser, log in to your AWS Account. You must have permissions to configure IAM roles.
1. In your terminal, execute the following:

   ```bash
   armory aws create-role
   ```

   Type `Y` in the terminal to continue with Stack creation. This opens your browser to the CloudFormation page of your AWS Console. You complete the rest of this process in your browser.

1. Review the resources that CD-as-a-Service is creating in your AWS account. The default IAM Role name is **ArmoryRole**.
1. Click **Create** on the AWS CloudFormation page and wait for Stack creation to finish.
1. After the CloudFormation Stack creation finishes, locate the created role ARN in the **Outputs** section. You can find it under the key **RoleArnOutput**. Make note of the ARN since you use it in your deployment config file.