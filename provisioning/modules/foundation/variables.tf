variable "project_id" {
  description = "The project ID where resources will be deployed to"
}

variable "project_number" {
  description = "The project number where resources will be deployed to"
}

variable "spanner_config" {
  description = "The geographic config for the Isidro operational database"
}

variable "memorystore_tier" {
  description = "The Cloud Memorystore (Redis) tier, for the instance that will be used to back asynchronous task queues"
}