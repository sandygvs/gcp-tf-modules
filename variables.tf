variable "host_project_id" {
  type        = string
  description = "Host Project ID"
}

variable "project_id" {
  type        = string
  description = "The project ID to manage the notebook"
}

variable "project_number" {
  type        = string
  description = "Project Number"
}

variable "project_name" {
  type        = string
  description = "Project Name"
}

variable "region" {
  type        = string
  description = "Region to deploy the notebook instance"
  default     = "us-east4"
}
variable "vertexai_nb_zone" {
  type        = string
  description = "Zone to deploy the notebook instance within a given region"
  default     = "us-east4-a"
}

variable "random_name_enabled" {
  type        = bool
  description = "Set random suffix at the end of the notebook instance name"
  default     = true
}

variable "vertexai_machine_type" {
  type        = string
  description = "Notebook instance machine type which defines the VM kind"
  default     = "n1-standard-2"
}

variable "vertexai_instance_owners" {
  type        = list(string)
  description = "List of instance owners" // Currently supports only one owner
  default     = []
}

variable "vertexai_svc_account" {
  type        = string
  description = "service account for the notebook instance"
  default     = "vertexai"
}

variable "nb_create_mode" {
  type        = string
  description = "Set the notebook instance creation mode. Possible values are 'instance' and 'container'"
  default     = "instance"
}

variable "accelerator_config_type" {
  type        = string
  description = "The hardware accelerator type used on this instance"
  default     = "NVIDIA_TESLA_P4"
}

variable "accelerator_config_core" {
  type        = number
  description = "Count of cores of this accelerator"
  default     = 1
}

variable "enable_integrity_monitoring" {
  type        = bool
  description = "Defines whether the instance has integrity monitoring enabled"
  default     = true
}

variable "enable_secure_boot" {
  type        = bool
  description = "Defines whether the instance has Secure Boot enabled"
  default     = false
}

variable "enable_vtpm" {
  type        = bool
  description = "Defines whether the instance has the vTPM enabled"
  default     = true
}

variable "container_image_repository" {
  type        = string
  description = "The path to the container image repository"
  default     = "gcr.io/deeplearning-platform-release/tf-cpu.2-8"
}

variable "container_image_tag" {
  type        = string
  description = "The tag of the container image"
  default     = "latest"
}

variable "vm_image_project" {
  type        = string
  description = "The name of the Google Cloud project that this VM image belongs to"
  default     = "deeplearning-platform-release"
}

variable "vm_image_family" {
  type        = string
  description = "VM image family to find the image"
  default     = "tf-ent-latest-cpu"
}

variable "gpu_driver_enabled" {
  type        = bool
  description = "Whether the end user authorizes Google Cloud to install GPU driver on this instance"
  default     = false
}

variable "boot_disk_type" {
  type        = string
  description = "Boot disk types for notebook instances"
  default     = "PD_STANDARD"
}

variable "boot_disk_size_gb" {
  type        = number
  description = "The size of the boot disk in GB attached to notebook instance"
  default     = 100
}

variable "no_remove_data_disk" {
  type        = bool
  description = "Data disk will not be auto deleted on instance deletion"
  default     = false
}

variable "no_public_ip" {
  type        = bool
  description = "Whether public IP is disabled for notbook instance"
  default     = true
}

variable "no_proxy_access" {
  type        = bool
  description = "Whether notbook instance is deregistered with proxy"
  default     = false
}

variable "vpc_network_name" {
  type        = string
  description = "Name of the VPC for notebook instance"
}

variable "subnetwork_self_link" {
  type        = string
  description = "Name of the subnet for notebook instance"
}

variable "vertexai_labels" {
  description = "Project labels."
  type        = map(string)
  default     = {}
}

variable "vertexai_network_tags" {
  type        = list(string)
  description = "network tags for notebook instance"
  default     = []
}

variable "vertexai_metadata" {
  description = "Custom metadata for the notebook instance"
  type        = map(string)
  default     = {}
}

variable "google_vertexai_api" {
  description = "Vertex AI API to be enabled."
  type        = list(string)
  default     = ["aiplatform.googleapis.com", "notebooks.googleapis.com"]
}

variable "vertexai_api_disable_dependent_services" {
  description = "Flag for disabling API Dependencies Services"
  type        = bool
  default     = false
}

variable "vertexai_api_disable_on_destroy" {
  description = "Flag for disabling API on Destroy Services"
  type        = bool
  default     = false
}

variable "service_account_name" {
  type        = string
  description = "Vertexai Service Account Name"
  default     = "vertexai"
}

variable "post_startup_script" {
  type        = string
  description = "Path to a Bash script that automatically runs after a notebook instance fully boots up. The path must be a URL or Cloud Storage path (gs://path-to-file/file-name)."
  default     = ""
}

variable "custom_gpu_driver_path" {
  type        = string
  description = "Specify a custom Cloud Storage path where the GPU driver is stored. If not specified, we'll automatically choose from official GPU drivers"
  default     = ""
}

variable "kms_key" {
  type        = string
  description = "The KMS key used to encrypt the disks, only applicable if diskEncryption is CMEK. Format: projects/{project_id}/locations/{location}/keyRings/{key_ring_id}/cryptoKeys/{key_id}"
  default     = ""
}

variable "instance_names" {
  type        = any
  description = "List of notebook instance to create"
  default = {
    nb1 = {
      nb_create_mode        = "instance"
      vertexai_machine_type = "n1-standard-2"
      vertexai_nb_zone      = "us-east4-a"
      gpu_driver_enabled    = false
      vertexai_labels       = {}
      vertexai_network_tags = []
      vertexai_metadata     = {}
    }
  }
}
