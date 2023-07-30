

variable "project" {
	type = string
	description = "GCP project name to deploy wiki assets"
}


variable "postgres_username" {
	type = string
	description = "Superuser name for Postgres"
	sensitive = true
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


variable "allowed_user_emails" {
	type = list(string)
	description = "List of allowed users for app"
}



