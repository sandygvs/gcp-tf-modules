resource "random_id" "name" {
  count       = var.random_name_enabled ? 1 : 0
  byte_length = 4
}
resource "google_project_service" "vertexai_api" {
  for_each = toset(var.google_vertexai_api)
  project  = var.project_id
  service  = each.value

  disable_on_destroy         = var.vertexai_api_disable_on_destroy
  disable_dependent_services = var.vertexai_api_disable_dependent_services
}

## Vertex AI Notebook service accounts
module "vertexai_service_account" {
  source       = "terraform-google-modules/service-accounts/google"
  version      = "4.1.1"
  project_id   = var.project_id
  display_name = "svc-${var.service_account_name}"
  prefix       = "svc"
  names        = [var.service_account_name]
}

resource "google_service_account_iam_member" "sa_iam_member" {
  service_account_id = module.vertexai_service_account.service_account.id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${module.vertexai_service_account.email}"
  depends_on = [
    module.vertexai_service_account
  ]
}

resource "google_project_iam_member" "network_access_aiplatform_sa" {
  project = var.host_project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:service-${var.project_number}@gcp-sa-aiplatform.iam.gserviceaccount.com"
  depends_on = [
    google_project_service.vertexai_api
  ]
}

resource "google_project_iam_member" "network_access_notebooks_sa" {
  project = var.host_project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:service-${var.project_number}@gcp-sa-notebooks.iam.gserviceaccount.com"

  depends_on = [
    google_project_service.vertexai_api
  ]

}

## Vertex AI Notebook Instance ##

resource "google_notebooks_instance" "vertexai_instance" {
  for_each = var.instance_names

  ## Required Attributes
  name         = var.random_name_enabled ? "${var.project_name}-nb-${random_id.name[0].hex}-${each.key}" : "${var.project_name}-nb-${each.key}"
  location     = lookup(each.value, "vertexai_nb_zone", var.vertexai_nb_zone)
  project      = var.project_id
  machine_type = lookup(each.value, "vertexai_machine_type", var.vertexai_machine_type)

  ## Optional Attributes

  dynamic "vm_image" {
    for_each = lookup(each.value, "nb_create_mode", var.nb_create_mode) == "instance" ? [1] : []
    content {
      project      = lookup(each.value, "vm_image_project", var.vm_image_project)
      image_family = lookup(each.value, "vm_image_family", var.vm_image_family)
    }
  }

  dynamic "container_image" {
    for_each = lookup(each.value, "nb_create_mode", var.nb_create_mode) == "container" ? [1] : []
    content {
      repository = lookup(each.value, "container_image_repository", var.container_image_repository)
      tag        = lookup(each.value, "container_image_tag", var.container_image_tag)
    }
  }

  instance_owners = var.vertexai_instance_owners
  service_account = module.vertexai_service_account.email

  install_gpu_driver  = lookup(each.value, "gpu_driver_enabled", var.gpu_driver_enabled)
  boot_disk_size_gb   = lookup(each.value, "boot_disk_size_gb", var.boot_disk_size_gb)
  boot_disk_type      = lookup(each.value, "boot_disk_type", var.boot_disk_type)
  no_remove_data_disk = lookup(each.value, "no_remove_data_disk", var.no_remove_data_disk)
  no_public_ip        = lookup(each.value, "no_public_ip", var.no_public_ip)
  no_proxy_access     = lookup(each.value, "no_proxy_access", var.no_proxy_access)
  dynamic "accelerator_config" {
    for_each = lookup(each.value, "gpu_driver_enabled", var.gpu_driver_enabled) ? [1] : []
    content {
      type       = lookup(each.value, "accelerator_config_type", var.accelerator_config_type)
      core_count = lookup(each.value, "accelerator_config_core", var.accelerator_config_core)
    }
  }

  shielded_instance_config {
    enable_integrity_monitoring = var.enable_integrity_monitoring
    enable_secure_boot          = var.enable_secure_boot
    enable_vtpm                 = var.enable_vtpm
  }

  network = var.vpc_network_name
  subnet  = var.subnetwork_self_link

  labels                 = lookup(each.value, "vertexai_labels", var.vertexai_labels)
  tags                   = lookup(each.value, "vertexai_network_tags", var.vertexai_network_tags)
  metadata               = lookup(each.value, "vertexai_metadata", var.vertexai_metadata)
  post_startup_script    = lookup(each.value, "post_startup_script", var.post_startup_script)
  custom_gpu_driver_path = lookup(each.value, "custom_gpu_driver_path", var.custom_gpu_driver_path)
  kms_key                = lookup(each.value, "kms_key", var.kms_key)

  depends_on = [
    google_project_iam_member.network_access_aiplatform_sa,
    google_service_account_iam_member.sa_iam_member
  ]

}

#############################################
# Create start stop scheduler for notebooks #
#############################################

# Custom role for notebooks' start stop actions
resource "google_project_iam_custom_role" "notebooks_start_stop" {
  project     = var.project_id
  role_id     = "NotebookStartStopRole"
  title       = "Notebooks start stop"
  description = "Custom role for Vertex notebooks start stop actions"
  permissions = ["notebooks.instances.stop", "notebooks.instances.start"]
}

# Service Account for Cloud Scheduler
resource "google_service_account" "svc_nbscheduler" {
  account_id   = "svc-nbscheduler"
  display_name = "A service account for scheduling to stop start times of Vertex notebooks"
  project      = var.project_id
}

# IAM member for Cloud Scheduler Service Account
resource "google_project_iam_member" "cloud_scheduler_iam" {
  project = var.project_id
  role    = google_project_iam_custom_role.notebooks_start_stop.id
  member  = "serviceAccount:svc-nbscheduler@${var.project_id}.iam.gserviceaccount.com"

}

# Cloud Scheduler job for starting instance
locals {
  stop_scheduler_map = { for nb_name, inst in var.instance_names : nb_name => [inst.stop_schedule, inst.time_zone] if contains(keys(inst), "stop_schedule") }
}
resource "google_cloud_scheduler_job" "cloud_function_cronjob" {
  for_each    = local.stop_scheduler_map
  project     = var.project_id
  name        = "scheduler-${each.key}"
  region      = var.region
  time_zone   = each.value[1]
  description = "CronJob for stop Notebooks"
  schedule    = each.value[0]
  http_target {
    http_method = "POST"
    uri         = "https://notebooks.googleapis.com/v1/${google_notebooks_instance.vertexai_instance[each.key].id}:stop"
    oauth_token {
      service_account_email = google_service_account.svc_nbscheduler.email
    }
    headers = {
      Content-Type = "application/json"
    }
  }
}

# Cloud Scheduler job for stopping instance
locals {
  start_scheduler_map = { for nb_name, inst in var.instance_names : nb_name => [inst.start_schedule, inst.time_zone] if contains(keys(inst), "start_schedule") }
}

resource "google_cloud_scheduler_job" "cloud_function_start_cronjob" {
  for_each    = local.start_scheduler_map
  project     = var.project_id
  name        = "start-scheduler-${each.key}"
  region      = var.region
  time_zone   = each.value[1]
  description = "CronJob for start Notebooks"
  schedule    = each.value[0]
  http_target {
    http_method = "POST"
    uri         = "https://notebooks.googleapis.com/v1/${google_notebooks_instance.vertexai_instance[each.key].id}:start"
    oauth_token {
      service_account_email = google_service_account.svc_nbscheduler.email
    }
    headers = {
      Content-Type = "application/json"
    }
  }
}
