// Create a list of secrets to grant access to
locals {
  teams_default_channel = {
    for channel, secret in var.default_channel :
  channel => secret if channel == "teams" }
  secrets = merge(var.secret_list, local.teams_default_channel)
}

// Archive source code
data "archive_file" "source" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/transfer-job-notitication.zip"
}

// Create service account 
module "service_account_cf" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "3.0.1"
  project_id = var.project_id
  prefix     = "svc"
  names      = [var.sa_cf]
}

// Grant access to Secret Manager
resource "google_secret_manager_secret_iam_member" "member" {
  for_each  = toset(flatten(values(local.secrets)))
  project   = var.project_id
  secret_id = each.key
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${module.service_account_cf.email}"

  depends_on = [
    module.service_account_cf
  ]
}

// Create bucket for source code
module "cf-teams-notification" {
  source                      = "app.terraform.io/aa/gcp-cloud-storage/google"
  version                     = "0.0.3"
  project_id                  = var.project_id
  name                        = "${var.project_name}-cf-teams-notification"
  location                    = "US"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = false
  labels                      = var.labels
}

// Add source code zip to bucket
resource "google_storage_bucket_object" "zip" {
  bucket       = module.cf-teams-notification.bucket.name
  content_type = "application/zip"
  name         = "src-${data.archive_file.source.output_md5}.zip"
  source       = data.archive_file.source.output_path
}

// Create Pub/Sub topic if it doesn't exist
module "teams-notification-pubsub" {
  create_topic = var.create_topic
  source       = "terraform-google-modules/pubsub/google"
  version      = "3.0.0"

  project_id   = var.project_id
  topic        = var.topic_name
  topic_labels = var.labels
}

// Create Cloud Function
resource "google_cloudfunctions_function" "notify" {
  name                          = "teams-notify"
  project                       = var.project_id
  region                        = var.region
  description                   = "Send storage transfer job notifications to Teams"
  runtime                       = var.runtime
  max_instances                 = var.max_instances
  timeout                       = var.timeout_s
  entry_point                   = var.entry_point
  ingress_settings              = var.ingress_settings
  vpc_connector_egress_settings = "ALL_TRAFFIC"
  vpc_connector                 = var.vpc_connector
  available_memory_mb           = var.available_memory_mb
  source_archive_bucket         = module.cf-teams-notification.bucket.name
  source_archive_object         = google_storage_bucket_object.zip.name
  labels                        = var.labels
  service_account_email         = module.service_account_cf.email

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = "projects/${var.project_id}/topics/${var.topic_name}"

    failure_policy {
      retry = var.event_trigger_failure_policy_retry
    }
  }

  environment_variables = {
    DEFAULT_CHANNEL = jsonencode(var.default_channel),
    SECRET_LIST     = jsonencode(var.secret_list),
    EMAIL_LIST      = jsonencode(var.email_list),
    GCP_PROJECT     = var.project_id,
    SMTP_HOST       = var.smtp_host,
    SMTP_PORT       = var.smtp_port,
    SENDER_ADDRESS  = var.sender_notification_email
  }
}

// Alert on cloud function errors
resource "google_monitoring_alert_policy" "error" {
  count = length(var.notification_channels) > 0 ? 1 : 0

  project      = var.project_id
  display_name = "Error happened in function teams-notify"
  enabled      = true
  combiner     = "OR"
  conditions {
    display_name = "Error happened in function ${google_cloudfunctions_function.notify.name}"
    condition_monitoring_query_language {
      query    = <<-EOF
        fetch cloud_function
        | metric 'cloudfunctions.googleapis.com/function/execution_count'
        | filter
            (resource.function_name == '${google_cloudfunctions_function.notify.name}')
            && (metric.status != 'ok')
        | align rate(5m)
        | every 5m
        | condition val() > 0 '1/s'
      EOF
      duration = "0s"
    }
  }
  notification_channels = var.notification_channels
  documentation {
    content = "There was an error executing Teams transfer job notification cloud function ${google_cloudfunctions_function.notify.name}, check logs for details"
  }
}
