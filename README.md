# terraform-google-gcp-vertex-ai

GCP Vertex AI Notebook

# Vertex AI Notebook Terraform Module

This Module is to provision the vertex AI notebook instance resource in GCP via terraform

# Usage

Basic usage of this submodule is as follows:

For Eg: platform project

# Below example create notebook instance with the default configs

```
module "vertexai_notebook" {
  source          = "app.terraform.io/aa/gcp-vertex-ai/google"
  version         = "0.0.3"
  project_id      = module.project.project_id
  project_name    = module.project.project_name
  project_number  = module.project.project_number
  host_project_id = local.host_project_id
  subnetwork_self_link = local.subnetwork_self_link
  vpc_network_name     = local.vpc
}
```

# Create vm based notebook instance with custom configs.

# Provide the actual required values for instance_names attribute.

1. # Set nb_create_mode = "instance"
2. # Skip or provide container_image block as empty (container_image = {}) for vm based notebook instance.

# Create container based notebook instance with custom configs.

1. # Set nb_create_mode = "container"
2. # Skip or provide vm_image block as empty (vm_image = {}) for container_based notebook

# Refer here for available vm_image image_family attribute, https://cloud.google.com/deep-learning-vm/docs/images

# Refer here for available Container images list https://cloud.google.com/deep-learning-containers/docs/choosing-container

# Refer here for available accelerator_config type attribute https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/notebooks_instance#type

# Below are sample config for notebook vm with multiple instances without GPU

```
module "vertexai_notebook" {
  source          = "app.terraform.io/aa/gcp-vertex-ai/google"
  version         = "0.0.3"
  project_id      = module.project.project_id
  project_name    = module.project.project_name
  project_number  = module.project.project_number
  host_project_id = local.host_project_id
  subnetwork_self_link = local.subnetwork_self_link
  vpc_network_name     = local.vpc
  instance_names = {
    nb1 = {
      nb_create_mode = "instance"
    },
    nb2 = {
      nb_create_mode = "instance"
    }
  }
  #Where nb1, nb2 refers to the individual notebook instance configurations
}
```

# Below are sample config for notebook vm with multiple instances with GPU

```
module "vertexai_notebook" {
  source          = "app.terraform.io/aa/gcp-vertex-ai/google"
  version         = "0.0.3"
  project_id      = module.project.project_id
  project_name    = module.project.project_name
  project_number  = module.project.project_number
  host_project_id = local.host_project_id
  subnetwork_self_link = local.subnetwork_self_link
  vpc_network_name     = local.vpc
  instance_names = {
    nb1 = {
      nb_create_mode = "instance"
      gpu_driver_enabled = true
    },
    nb2 = {
      nb_create_mode = "instance"
      gpu_driver_enabled = true
    }
  }
  #Where nb1, nb2 refers to the individual notebook instance configurations
}
```

# Below are sample config for multiple notebook container instances without GPU

```
module "vertexai_notebook" {
  source          = "app.terraform.io/aa/gcp-vertex-ai/google"
  version         = "0.0.3"
  project_id      = module.project.project_id
  project_name    = module.project.project_name
  project_number  = module.project.project_number
  host_project_id = local.host_project_id
  subnetwork_self_link = local.subnetwork_self_link
  vpc_network_name     = local.vpc
  instance_names = {
    nb1 = {
      nb_create_mode = "container"
    },
    nb2 = {
      nb_create_mode = "container"
    }
  }
  #Where nb1, nb2 refers to the individual notebook instance configurations
}
```

# Below are sample config for notebook container vm with multiple instances with GPU

```
module "vertexai_notebook" {
  source          = "app.terraform.io/aa/gcp-vertex-ai/google"
  version         = "0.0.3"
  project_id      = module.project.project_id
  project_name    = module.project.project_name
  project_number  = module.project.project_number
  host_project_id = local.host_project_id
  subnetwork_self_link = local.subnetwork_self_link
  vpc_network_name     = local.vpc
  instance_names = {
    nb1 = {
      nb_create_mode = "container"
      gpu_driver_enabled = true
    },
    nb2 = {
      nb_create_mode = "container"
      gpu_driver_enabled = true
    }
  }
  #Where nb1, nb2 refers to the individual notebook instance configurations
}
```

Note: If Proxy settings are required, add below line to the configs as needed

```
no_proxy_access = false
```

# Below is the sample notebook vm with custom configs

```
module "vertexai_notebook" {
  source          = "app.terraform.io/aa/gcp-vertex-ai/google"
  version         = "0.0.3"
  project_id      = module.project.project_id
  project_name    = module.project.project_name
  project_number  = module.project.project_number
  host_project_id = local.host_project_id
  subnetwork_self_link = local.subnetwork_self_link
  vpc_network_name     = local.vpc
  instance_names = {
    nb1 = {
      nb_create_mode = "container"
      gpu_driver_enabled = true
      vertexai_nb_zone = "${var.region}-c"
      vertexai_machine_type = "n1-standard-8"
      vertexai_network_tags = ["nb-instance"]
      vertexai_labels = {
        "vm_name" : "nb-instance"
      }
    }
    accelerator_config_type = NVIDIA_TESLA_T4
    accelerator_config_core = 2
  }
  #Where nb1, nb2 refers to the individual notebook instance configurations
}
```

# Test module in levi-modules-d project

Module can be tested in levi-modules-d project. For more details about test environment see documentation GDO. Terraform modules testing

Ready to use configuration can be located in examples/ folder. In order to deploy and test notebook instances in levi-modules-d project run following commands:

cd examples/<folder_name>

terraform init

terraform plan

terraform apply

# when all done don't forget to cleanup

terraform destroy
