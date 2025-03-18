output "vm_private_key" {
  value     = module.virtual_machine.vm_private_key
  sensitive = true
}