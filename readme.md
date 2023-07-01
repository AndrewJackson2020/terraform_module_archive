
change_permissions_on_ssh_keys
```
chmod 400 ~/.ssh/id_rsa
```

```
gcloud compute instances start instance-from-template `
    --zone=us-central1-a `
    --project=skilful-alpha-358420

gcloud compute start-iap-tunnel instance-from-template 3389 `
    --local-host-port=localhost:8080 `
    --zone=us-central1-a `
    --project=skilful-alpha-358420
```

```
# Should fail
bq ls

# Log in via federated identity 
gcloud auth login --cred-file=workload_identity_pool_config.json
gcloud config set project skilful-alpha-358420

# Should succeed
bq ls
```

```
gcloud auth application-default login
terraform init -upgrade
terraform apply
```

```
terraform destroy
```

```
terraform apply -target=module.module-1.aws_instance.ec2_example 
```