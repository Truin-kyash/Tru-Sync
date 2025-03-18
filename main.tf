provider "azurerm" {
  features {}
  subscription_id = "94eb1620-1ab5-4f1f-8556-aaa60252291c"
}



locals {
  project_name      = var.project_name
  environment       = var.environment 
  region           = var.region      
  location         = var.location    
  location_prefix  = var.location_prefix
  resource_name    = "${local.project_name}-${local.location_prefix}-${local.environment}"
 tags = {
    project_name = var.project_name
    environment  = var.environment
    maintainer   = "DevOps Team"  
}

}


module "resource_group" {
  source              = "./modules/resource_group"
  resource_group_name = "${local.resource_name}-rg"
  location            = var.location
  tags                =local.tags
 
}

module "vnet" {
  source              = "./modules/vnet"
  vnet_name           = "${local.resource_name}-vnet"
  resource_group_name = module.resource_group.resource_group_name
  location            = var.location
  vnet_address        = var.vnet_address  
  tags                 = local.tags 
}

module "subnet" {
  source              = "./modules/subnet"
  subnet_name         = "${local.resource_name}-subnet"
  resource_group_name = module.resource_group.resource_group_name
  vnet_name           = module.vnet.vnet_name
  location            = local.location
  address_prefixes    = ["10.0.1.0/24"]
  tags                 = local.tags 
}

module "app_service_plan" {
  source              = "./modules/app_service_plan"
  app_service_plan_name = "${local.resource_name}-app-plan"
  resource_group_name = module.resource_group.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B1"
  tags                 = local.tags 
}

module "web_app" {
  source               = "./modules/web_app"
  web_app_name         = "${local.resource_name}-node-app"
  resource_group_name  = module.resource_group.resource_group_name
  location             = var.location
  subnet_id            = module.subnet.subnet_id  
  app_service_plan_id  = module.app_service_plan.app_service_plan_id
  tags                 = local.tags 
}

module "static_web_app" {
  source              = "./modules/static_web_app"
  static_web_app_name = "${local.resource_name}-static-web-app"
  resource_group_name = module.resource_group.resource_group_name
  preview_env         = true
  sku_size            = "Standard"
  location            = var.location
  sku_tier            = "Free"
  subscription_id     = var.subscription_id
  public_access       = true
  user_assigned_identity_name = "my-identity"
  environments        = "AllEnvironments"
  tags                 = local.tags 
}

module "virtual_machine" {
  source               = "./modules/virtual_machine"
  vm_name              = "${local.resource_name}-virtual-machine5"
  resource_group_name  = module.resource_group.resource_group_name
  size                 = "Standard_B1ls"
  location             = var.location
  subnet_id            = module.subnet.subnet_id 
  tags                 = local.tags 
}

module "storage" {
  source                = "./modules/storage"
  storage_account_name  = substr(replace("${local.resource_name}stoge", "-", ""), 0, 24)
  resource_group_name   = module.resource_group.resource_group_name
  location              = var.location
  account_tier          = "Standard"
  tags                 = local.tags 
}

module "ai_foundry" {
  source               = "./modules/ai_foundry"
  resource_group_name  = module.resource_group.resource_group_name
  resource_group = module.resource_group.resource_group_name
  tenant_id = var.tenant_id
  resource_group_id    = module.resource_group.resource_group_id  
  storage_account_name = module.storage.storage_account_name    
  prefix               = local.resource_name
  subscription_id      = var.subscription_id
  location             = var.location
  tags                 = local.tags
}

 