
variable "project_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "labels" {
  description = "Project labels."
  type        = map(string)
  default     = {}
}

variable "vpc_connector" {
  description = "VPC serverless connector"
  type        = string
}

variable "available_memory_mb" {
  type        = number
  default     = 256
  description = "The amount of memory in megabytes allotted for the function to use."
}

variable "entry_point" {
  type        = string
  description = "The name of a method in the function source which will be invoked when the function is executed."
  default     = "main"
}

variable "runtime" {
  type        = string
  description = "The runtime in which the function will be executed."
  default     = "python39"
}

variable "timeout_s" {
  type        = number
  default     = 120
  description = "The amount of time in seconds allotted for the execution of the function."
}

variable "max_instances" {
  type        = number
  default     = 3
  description = "The default maximum number of parallel executions of the notification function."
}

variable "topic_name" {
  type        = string
  description = "Topic to subscribe to"
}

variable "create_topic" {
  type        = bool
  description = "Set to true if module should create the Pub/Sub topic"
}

variable "ingress_settings" {
  type        = string
  default     = "ALLOW_ALL"
  description = "The ingress settings for the function. Allowed values are ALLOW_ALL, ALLOW_INTERNAL_AND_GCLB and ALLOW_INTERNAL_ONLY. Changes to this field will recreate the cloud function."
}

variable "event_trigger_failure_policy_retry" {
  type        = bool
  default     = false
  description = "A toggle to determine if the function should be retried on failure."
}

variable "sa_cf" {
  description = "Service account to run notification cloud function"
  type        = string
  default     = "cf-teams-notification"
}

variable "notification_channels" {
  description = "List of notification channels for alerts"
  type        = list(string)
  default     = []
}

variable "default_channel" {
  type        = map(list(string))
  description = "Default notifications channel to send all notifications in case no job definition is found in secret_list or email_list variable. Specify at least one."
}

variable "secret_list" {
  type        = map(list(string))
  description = "List of secret keys of webhook urls for each transfer job. At least default channel should be set."
  default     = {}
}

variable "email_list" {
  type        = map(list(string))
  description = "A map of Job names as keys and a list of emails as values to send notifications"
  default     = {}
}

variable "smtp_host" {
  description = "SMTP Sever address"
  type        = string
  default     = "smtphost.aa.com"
}

variable "smtp_port" {
  description = "SMTP Sever port"
  type        = number
  default     = 25
}

variable "sender_notification_email" {
  description = "Email address of the sender"
  type        = string
  default     = "storage-transfer-notifications@aa.com"
}
