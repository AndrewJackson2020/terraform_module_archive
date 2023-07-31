

variable "project" {
	type = string
	description = "GCP project name to deploy wiki assets"
}


variable "postgres_username" {
	type = string
	description = "Superuser name for Postgres"
	sensitive = true
}


variable "pomerium_client_secret" {
	type = string
	description = "Client secret to use in pomerium Google OAuth"
	sensitive = true
}


variable "pomerium_client_id" {
	type = string
	description = "Client ID to use in pomerium Google OAuth"
}


variable "postgres_password" {
	type = string
	description = "Superuser password for Postgres"
	sensitive = true
}


variable "namespace" {
	type = string
	description = "String to append to namespace to ensure uniqueness"
}


variable "domain_name" {
	type = string
	description = "GCP project name to deploy wiki assets"
}


variable "auth_url" {
	type = string
	description = "URL to access auth"
}

variable "allowed_user_emails" {
	type = list(string)
	description = "List of allowed users for app"
}



