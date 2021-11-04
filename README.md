# Doppler Secrets Sync to AWS Elastic Beanstalk

A reference implementation of syncing secrets from Doppler to an Elastic Beanstalk environment.

It has two Doppler configs:

* `CI-CD`: Contains the AWS secrets and Service Token for the `Production` config
* `Production`: Contains the application secrets

## Requirements

- Docker
- Existing Elastic Beanstalk application
- AWS IAM Credentials with required Elastic Beanstalk permissions

## Set Up

First step is to build the Docker image that contains the `eb` and `doppler` CLI.

```sh
docker build -t doppleruniversity/elastic-beanstalk-sync .
```

Create and configure the test Project in Doppler:

```sh
doppler import
doppler setup --no-interactive
doppler configs tokens create aws-eb-prd --config prd --plain | doppler secrets set DOPPLER_PRD_SERVICE_TOKEN
doppler secrets delete API_KEY DEBUG -y
doppler secrets delete AWS_ACCESS_KEY_ID AWS_REGION AWS_SECRET_ACCESS_KEY DOPPLER_PRD_SERVICE_TOKEN --config prd -y
```

Set the required `AWS` secrets:

```sh
echo -en '\nAWS_ACCESS_KEY_ID:' && read -r AWS_ACCESS_KEY_ID
echo -en '\nAWS_SECRET_ACCESS_KEY: ' && read -r AWS_SECRET_ACCESS_KEY
echo -en '\nAWS_REGION: ' && read -r AWS_REGION
doppler secrets set \
    AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
    AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
    AWS_REGION="$AWS_REGION"
```

And finally, if you haven't already, create an Elastic Beanstalk application via the AWS console named `doppler-test`.

## Sync Secrets

The [doppler-secrets-sync](bin/doppler-secrets-sync) script contains the command to sync the Production config secrets to the `Doppler-test` Elastic Beanstalk environment.

```sh
source <(echo "eb setenv $(doppler secrets substitute <(echo '{{ range $n, $v := . }}{{$n}}={{tojson $v}} {{end}}') --no-read-env --token $DOPPLER_PRD_SERVICE_TOKEN)")
```

Simply run the container to sync the Production secrets:

```sh
docker run \
  --rm \
  -it \
  --env-file <(doppler secrets download --no-file --format docker) \
  doppleruniversity/elastic-beanstalk-sync
```
