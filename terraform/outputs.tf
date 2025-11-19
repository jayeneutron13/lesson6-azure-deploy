output "rg_name"     { value = azurerm_resource_group.rg.name } 
output "webapp_name" { value = azurerm_linux_web_app.webapp.name } 
output "webapp_url"  { value = "https://${azurerm_linux_web_app.webapp.default_hostname}" } 
