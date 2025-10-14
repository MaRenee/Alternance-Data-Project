
data "azurerm_resource_group" "resource-group" {
  name     = "data-rg"
}

resource "azurerm_storage_account" "storage-account" {
  name                     = "wemsstagedatastadev"
  resource_group_name      = data.azurerm_resource_group.resource-group.name
  location                 = data.azurerm_resource_group.resource-group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_user_assigned_identity" "identity" {
  name                = "wemsidentitydev"
  resource_group_name = data.azurerm_resource_group.resource-group.name
  location            = data.azurerm_resource_group.resource-group.location
  
}

resource "azurerm_container_registry" "acr" {
  name                = "wemscontainerregistrydev"
  resource_group_name = data.azurerm_resource_group.resource-group.name
  location            = data.azurerm_resource_group.resource-group.location
  sku                 = "Basic"
  admin_enabled       = true
  
}

resource "azurerm_storage_account" "function-sacc" {
  name                     = "wemsfunctionapisaccdev"
  resource_group_name      = data.azurerm_resource_group.resource-group.name
  location                 = data.azurerm_resource_group.resource-group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "service-plan" {
  name                = "wemssimportdataapidevplan"
  location            = data.azurerm_resource_group.resource-group.location
  resource_group_name = data.azurerm_resource_group.resource-group.name
  sku_name = "B1"
  os_type = "Linux"
}
 
resource "azurerm_linux_function_app" "function-app" {
  name                       = "wemsimportdataapidev"
  location                   = data.azurerm_resource_group.resource-group.location
  resource_group_name        = data.azurerm_resource_group.resource-group.name
  service_plan_id            = azurerm_service_plan.service-plan.id
  storage_account_name       = azurerm_storage_account.function-sacc.name
  storage_account_access_key = azurerm_storage_account.function-sacc.primary_access_key
  
  identity {
    type = "UserAssigned"
    identity_ids = [ azurerm_user_assigned_identity.identity.id ]
  }
  site_config {
    container_registry_use_managed_identity = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.identity.client_id
    application_stack {
      docker {
        image_name = "uploadfileapi"
        image_tag = "latest"
        registry_url = "wemscontainerregistrydev.azurecr.io"
      }
    }
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = false
  }
}

resource "azurerm_role_assignment" "acr-pull"{
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
  scope                = azurerm_container_registry.acr.id
}

resource "azurerm_data_factory" "adf" {
  name                = "wemsdatafactorydev"
  location            = data.azurerm_resource_group.resource-group.location
  resource_group_name = data.azurerm_resource_group.resource-group.name 
}

resource "azurerm_postgresql_flexible_server" "pgsql" {
  name                   = "wemspgserverdev"
  location               = data.azurerm_resource_group.resource-group.location
  resource_group_name    = data.azurerm_resource_group.resource-group.name
  administrator_login    = "pgadmin"
  administrator_password = "P@ssword1234!"
  sku_name               = "B_Standard_B1ms"
  version                = "15"
  storage_mb             = 32768
  backup_retention_days  = 7

}

resource "azurerm_postgresql_flexible_server_database" "pgdb" {
  name                = "dataintegration"
  server_id         = azurerm_postgresql_flexible_server.pgsql.id
  charset             = "UTF8"
  collation           = "en_US.utf8"
}



 
