# Module terraform-google-gcp-transfer-notification

This module provides resources in order to send failed Storage Transfer Jobs notifications to Microsoft Teams. Following resources will be created:

- Storage bucket for the source code

- Pub/Sub topic if it doesn’t exist yet

- Cloud Function subscribed to Pub/Sub topic

- Service account for Cloud Function to access Secret Manager

- Monitoring Alert for the Cloud Function

## Usage

```
// Notifications module
module "teams-notification" {
  source                             = "app.terraform.io/aa/gcp-trasfer-notification/google"
  version                            = "0.0.1"
  project_id                         = local.project_id
  project_name                       = local.project_name
  region                             = var.region
  vpc_connector                      = var.vpc_connector
  labels                             = var.labels
  create_topic                       = true // False if topic already exists
  topic_name                         = "test-teams-notification"
  secret_list                        = var.secret_list
  default_channel                    = var.default_channel
  ingress_settings                   = var.ingress_settings
  event_trigger_failure_policy_retry = var.event_trigger_failure_policy_retry

  notification_channels              = [google_monitoring_notification_channel.email_notification_channel.id]
}
```

## Teams Incoming Webhook as secrets in Secret Manager

This module will send messages to one or more Teams channels. Since the URL’s are sensitive data they should be created in the Secret Manager as secrets. Module expects a default notification channel in case some job is not configured in terraform vars and a list of secrets as following::

### Default channel:

```
variable "default_channel" {
  type          = map(list(string))
  description   = "Default channel to send all notifications in case no job definition is found in secret_list variable"
  default       = {
    "default_channel" = ["default_channel_secret"],
  }
}
```

### Secret list

```
variable "secret_list" {
  type        = list(string)
  description = "List of secret keys of webhook urls"
  default     = ["secret_url1", "secret_url2"]
}
```

Webhook URLs creation is described [here](https://docs.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook)

## Pub/Sub topic

Module will create a new topic or will use an existing one, this setting is available when calling the module:

```
// Notifications module
module "teams-notification" {
  ....
  ....
  labels                             = var.labels
  create_topic                       = true // False if topic already exists
  topic_name                         = "test-teams-notification"
  ....
  }
```

The `create_topic` variable should be set as `true` if the module should created a new Pub/Sub topic or as `false` if already existing topic needs to be used.

## Alert notifications

Function will try to send the message to at least one Teams channel and will report any failed attempts. This alert will send notifications to the notification channel specified when calling the module:

```
// Notifications module
module "teams-notification" {
  source  = "app.terraform.io/aa/gcp-trasfer-notification/google"
  version = "0.0.1"
  ....
  ....
  notification_channels = [google_monitoring_notification_channel.email_notification_channel.id]
 }
```
