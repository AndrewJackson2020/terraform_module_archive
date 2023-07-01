gcloud iam workload-identity-pools create-cred-config \
    "${google_iam_workload_identity_pool_provider_name}" \
    "--service-account=${google_service_account_email}" \
    --aws \
    --output-file=workload_identity_pool_config.json