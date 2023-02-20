# Week 0 — Billing and Architecture

## Recreating the Conceptual Diagram

[Lucid Chart link](https://lucid.app/lucidchart/43284478-4650-4cce-908b-328f5692f038/edit?beaconFlowId=ED15A221B8888F08&invitationId=inv_a5df00dc-abfa-4114-93c9-6b2c8c3ae1fd&page=0_0#)

## Recreating the Logical Diagram

[Lucid Chart link](https://lucid.app/lucidchart/43284478-4650-4cce-908b-328f5692f038/edit?beaconFlowId=ED15A221B8888F08&invitationId=inv_a5df00dc-abfa-4114-93c9-6b2c8c3ae1fd&page=UJ4xvlc_nFDf#)

## Getting the AWS CLI Working

Installed AWS CLI using my GitPod environment

### Install AWS CLI

- Followed the [Youtube video](https://www.youtube.com/watch?v=OdUnNuKylHg&list=PLBfufR7vyJJ7k25byhRXJldB5AiwgNnWv&index=1) and [AWS documentation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

- Added the following task to my .gitpod.yml file to ensure awscli is always installed 

```sh
tasks:
  - name: aws-cli
    env:
      AWS_CLI_AUTO_PROMPT: on-partial
    init: |
      cd /workspace
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
      cd $THEIA_WORKSPACE_ROOT
```

### Set up a virtual mfa device for root account
<img width="725" alt="Screenshot 2023-02-17 at 13 48 59" src="https://user-images.githubusercontent.com/22412589/219671824-653d3107-be0f-40a4-a3e9-464f011d47d4.png">

### Created a new Admin user with virtual MFA, console and CLI access
<img width="1386" alt="Screenshot 2023-02-17 at 13 26 20" src="https://user-images.githubusercontent.com/22412589/219665121-8d9416ea-d9a2-48d9-be5d-94c36061582e.png">



### Created budget using the template provided and set 3 alerts
<img width="1405" alt="Screenshot 2023-02-16 at 22 10 22" src="https://user-images.githubusercontent.com/22412589/219663433-fb4a0a25-6ddb-4935-b420-912190e7ac41.png">


<img width="1410" alt="Screenshot 2023-02-17 at 13 53 26" src="https://user-images.githubusercontent.com/22412589/219674181-ab3337cc-40de-434e-9850-61ca8f29d324.png">

### Created CloudWatch Alarm
<img width="1504" alt="Screenshot 2023-02-16 at 22 21 03" src="https://user-images.githubusercontent.com/22412589/219663425-b7b92021-a227-4475-aab1-5c971740ed6c.png">

### Used awscli to create budgets using the new user credentials

```
aws budgets create-budget \
--account-id $AWS_ACCOUNT_ID \
--budget file://aws/json/budget.json \
--notifications-with-subscribers file://aws/json/budget-notifications-with-subscribers.json
```


### Created sns topic and subscription using the console and cli
```
aws sns subscribe \
--topic-arn="arn:aws:sns:us-east-1:855232278175:billing-alarm" \
--protocol=email \
--notification-endpoint=kay**@yahoo.com
aws cloudwatch put-metric-alarm --cli-input-json file://aws/json/alarm_config.json
```
<img width="1397" alt="Screenshot 2023-02-16 at 22 15 51" src="https://user-images.githubusercontent.com/22412589/219663429-078e4c71-3c6a-4c08-8d4a-6dfaa7ae6c62.png">
<img width="1402" alt="Screenshot 2023-02-16 at 22 15 19" src="https://user-images.githubusercontent.com/22412589/219663432-e2341603-b5ba-464d-b95a-d2a14adc3cc7.png">

### Homework Challenges
- Used EventBridge to send sns notification when there is a health service issue following this [aws guide](https://docs.aws.amazon.com/health/latest/ug/cloudwatch-events-health.html#creating-event-bridge-events-rule-for-aws-health)
 <img width="1439" alt="Screenshot 2023-02-17 at 15 39 17" src="https://user-images.githubusercontent.com/22412589/219699055-d646d7f4-cf45-4638-8722-28ab42936e5f.png">

- Researched AWS Service Limits/Quota
  It is used to guarantee the availability of AWS resources and prevent accidental provisioning of more resources than needed. They are AWS Region specific and aren't charged when increased. You are only if you launch or use AWS resources or services.
  The downside to Servive quota is the response time which takes about 24-48 hours and this can affect developers that work on project that have time contraints. A way to fix this is to create a cloudwatch alarm that notifies you and sends an sns when alarm is in `ALARM state`, `OK state`, or `INSUFFICIENT_DATA` state when you are close to a quota value threshold, so you can request an increase well ahead of time.

- Used Cloudwatch alarm for notification when you are close to a quota value threshold following this [guide](https://docs.aws.amazon.com/servicequotas/latest/userguide/configure-cloudwatch.html)
  <img width="1510" alt="Screenshot 2023-02-17 at 16 11 27" src="https://user-images.githubusercontent.com/22412589/219705996-01b4ec1a-e599-4bb4-9960-31d70661b6d6.png">

- Requested Dynamodb service quota increase by going to `Service Quotas` -> `select service of choice` -> `choose Quota name` -> `write a quota value greater than current quota`

  I chose to increase Dynamodb maximum number of tables from `2500` to `2700` in `us-east-1`
![Screenshot 2023-02-17 at 16 00 18](https://user-images.githubusercontent.com/22412589/219703526-be179d9e-cd3e-43b1-b82a-bb03b638f938.png)
![Screenshot 2023-02-17 at 16 00 38](https://user-images.githubusercontent.com/22412589/219703592-2bf82bf4-ce89-43bb-88c8-e2bff9f7a64b.png)
Limit Increase request was approved
![Screenshot 2023-02-20 at 09 26 00](https://user-images.githubusercontent.com/22412589/220065687-05ff4f3d-8c6e-40da-9412-d91ab1cf9915.png)

  


### Challenges
- My new user couldn’t access the budget using the console due to permission issue but I could create budget using the console.
Fixed it by logging in as a root user account and following this [aws documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_billing.html?icmpid=docs_iam_console#tutorial-billing-step1)
<img width="1561" alt="Screenshot 2023-02-16 at 22 03 43" src="https://user-images.githubusercontent.com/22412589/219663435-99722291-6724-4bab-b7f3-a092b7e83165.png">

- Gitpod wasn’t pushing my changes to GitHub, fixed it by giving gitpod the permission to read, write my public repos.

### Helpful Commannds

- `aws --cli-auto-prompt`; for aws command autocompletion
- `aws sts get-caller-identity`; checks what user is logged in. 
- `env | grep`; search function to confirm that you exported correctly
- `gp env AWS_ACCESS_KEY_ID=""`; to ensure Gitpod saves credentials for when pur workspace is relaunched
