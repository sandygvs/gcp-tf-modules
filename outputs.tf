output "nb_instance_id" {
  value = [for name in google_notebooks_instance.vertexai_instance : name.id]
}

output "nb_stop_scheduler" {
  value = local.stop_scheduler_map
}

output "nb_start_scheduler" {
  value = local.start_scheduler_map
}