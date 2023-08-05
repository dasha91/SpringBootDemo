resource "azurerm_resource_group" "res-0" {
  location = "eastus"
  name     = "aks-postgres-compete"
}
resource "azurerm_container_registry" "res-1" {
  location            = "eastus"
  name                = "postgresacr"
  resource_group_name = "aks-postgres-compete"
  sku                 = "Basic"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_container_registry_scope_map" "res-2" {
  actions                 = ["repositories/*/metadata/read", "repositories/*/metadata/write", "repositories/*/content/read", "repositories/*/content/write", "repositories/*/content/delete"]
  container_registry_name = "postgresacr"
  description             = "Can perform all read, write and delete operations on the registry"
  name                    = "_repositories_admin"
  resource_group_name     = "aks-postgres-compete"
  depends_on = [
    azurerm_container_registry.res-1,
  ]
}
resource "azurerm_container_registry_scope_map" "res-3" {
  actions                 = ["repositories/*/content/read"]
  container_registry_name = "postgresacr"
  description             = "Can pull any repository of the registry"
  name                    = "_repositories_pull"
  resource_group_name     = "aks-postgres-compete"
  depends_on = [
    azurerm_container_registry.res-1,
  ]
}
resource "azurerm_container_registry_scope_map" "res-4" {
  actions                 = ["repositories/*/content/read", "repositories/*/content/write"]
  container_registry_name = "postgresacr"
  description             = "Can push to any repository of the registry"
  name                    = "_repositories_push"
  resource_group_name     = "aks-postgres-compete"
  depends_on = [
    azurerm_container_registry.res-1,
  ]
}
resource "azurerm_kubernetes_cluster" "res-5" {
  dns_prefix          = "aks-cli-cl-aks-postgres-com-ad70ac"
  location            = "eastus"
  name                = "aks-cli-cluster"
  resource_group_name = "aks-postgres-compete"
  default_node_pool {
    name    = "nodepool1"
    vm_size = "Standard_DS2_v2"
  }
  identity {
    type = "SystemAssigned"
  }
  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDdBewjATgjBHeDa2Acq2Kk5P04/UuzAaNQbceBi+TgCmuSgnglENOOF3l/EP5fTvZenCFC+1zgU+dlPhrm6oFAq+uAR9YAbHVJO0s3XBiAIabZZ3oIm7cXmqCNBWuJqRWao/2JlDYAsj3OxnzyPNTe2qUWzye+oU+m4TNe6brOtbiiURTpS9JWUFtHn6wjii3JUEc0S3kADn8ip1i59YZdzjMDChitODFYhP9sjux6vm5mmGeVzRb7IMDxek4H4pkznCuOITjH1XVXn2baLgD1rHwMxcTd2JssWwV4DGet8d8if4xnz0AF9otvnS9X4D8XO+gm3MPx2cyyw0sX6HhZ"
    }
  }
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_kubernetes_cluster_node_pool" "res-6" {
  kubernetes_cluster_id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.ContainerService/managedClusters/aks-cli-cluster"
  mode                  = "System"
  name                  = "nodepool1"
  vm_size               = "Standard_DS2_v2"
  workload_runtime      = "OCIContainer"
  depends_on = [
    azurerm_kubernetes_cluster.res-5,
  ]
}
resource "azurerm_postgresql_server" "res-7" {
  location                         = "eastus"
  name                             = "aks-cli-postgres"
  resource_group_name              = "aks-postgres-compete"
  sku_name                         = "GP_Gen5_2"
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
  version                          = "11"
  threat_detection_policy {
    enabled = true
  }
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_postgresql_active_directory_administrator" "res-8" {
  login               = "dasha@contosohotels.com"
  object_id           = "7aaccb9f-b1ed-43d2-a571-e1ebd95f5d3c"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  tenant_id           = "4b2462a4-bbee-495a-a0e1-f23ae524cc9c"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-9" {
  name                = "array_nulls"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-10" {
  name                = "autovacuum"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-11" {
  name                = "autovacuum_analyze_scale_factor"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0.05"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-12" {
  name                = "autovacuum_analyze_threshold"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "50"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-13" {
  name                = "autovacuum_freeze_max_age"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "200000000"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-14" {
  name                = "autovacuum_max_workers"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "3"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-15" {
  name                = "autovacuum_multixact_freeze_max_age"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "400000000"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-16" {
  name                = "autovacuum_naptime"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "15"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-17" {
  name                = "autovacuum_vacuum_cost_delay"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "20"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-18" {
  name                = "autovacuum_vacuum_cost_limit"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "-1"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-19" {
  name                = "autovacuum_vacuum_scale_factor"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0.05"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-20" {
  name                = "autovacuum_vacuum_threshold"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "50"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-21" {
  name                = "autovacuum_work_mem"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "-1"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-22" {
  name                = "azure.replication_support"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "REPLICA"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-23" {
  name                = "backend_flush_after"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-24" {
  name                = "backslash_quote"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "safe_encoding"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-25" {
  name                = "bgwriter_delay"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "20"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-26" {
  name                = "bgwriter_flush_after"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "64"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-27" {
  name                = "bgwriter_lru_maxpages"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "100"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-28" {
  name                = "bgwriter_lru_multiplier"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "2"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-29" {
  name                = "bytea_output"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "hex"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-30" {
  name                = "check_function_bodies"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-31" {
  name                = "checkpoint_completion_target"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0.9"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-32" {
  name                = "checkpoint_warning"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "30"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-33" {
  name                = "client_encoding"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "sql_ascii"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-34" {
  name                = "client_min_messages"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "notice"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-35" {
  name                = "commit_delay"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-36" {
  name                = "commit_siblings"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "5"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-37" {
  name                = "connection_throttling"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-38" {
  name                = "constraint_exclusion"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "partition"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-39" {
  name                = "cpu_index_tuple_cost"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0.005"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-40" {
  name                = "cpu_operator_cost"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0.0025"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-41" {
  name                = "cpu_tuple_cost"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0.01"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-42" {
  name                = "cursor_tuple_fraction"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0.1"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-43" {
  name                = "datestyle"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "iso, mdy"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-44" {
  name                = "deadlock_timeout"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "1000"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-45" {
  name                = "debug_print_parse"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-46" {
  name                = "debug_print_plan"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-47" {
  name                = "debug_print_rewritten"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-48" {
  name                = "default_statistics_target"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "100"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-49" {
  name                = "default_text_search_config"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "pg_catalog.english"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-50" {
  name                = "default_transaction_deferrable"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-51" {
  name                = "default_transaction_isolation"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "read committed"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-52" {
  name                = "default_transaction_read_only"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-53" {
  name                = "default_with_oids"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-54" {
  name                = "effective_cache_size"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "655360"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-55" {
  name                = "enable_bitmapscan"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-56" {
  name                = "enable_hashagg"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-57" {
  name                = "enable_hashjoin"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-58" {
  name                = "enable_indexonlyscan"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-59" {
  name                = "enable_indexscan"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-60" {
  name                = "enable_material"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-61" {
  name                = "enable_mergejoin"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-62" {
  name                = "enable_nestloop"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-63" {
  name                = "enable_partitionwise_aggregate"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-64" {
  name                = "enable_partitionwise_join"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-65" {
  name                = "enable_seqscan"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-66" {
  name                = "enable_sort"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-67" {
  name                = "enable_tidscan"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-68" {
  name                = "escape_string_warning"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-69" {
  name                = "exit_on_error"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-70" {
  name                = "extra_float_digits"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-71" {
  name                = "force_parallel_mode"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-72" {
  name                = "from_collapse_limit"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "8"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-73" {
  name                = "geqo"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-74" {
  name                = "geqo_effort"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "5"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-75" {
  name                = "geqo_generations"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-76" {
  name                = "geqo_pool_size"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-77" {
  name                = "geqo_seed"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0.0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-78" {
  name                = "geqo_selection_bias"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "2.0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-79" {
  name                = "geqo_threshold"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "12"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-80" {
  name                = "gin_fuzzy_search_limit"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-81" {
  name                = "gin_pending_list_limit"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "4096"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-82" {
  name                = "hot_standby_feedback"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-83" {
  name                = "idle_in_transaction_session_timeout"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-84" {
  name                = "intervalstyle"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "postgres"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-85" {
  name                = "join_collapse_limit"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "8"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-86" {
  name                = "lc_monetary"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "English_United States.1252"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-87" {
  name                = "lc_numeric"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "English_United States.1252"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-88" {
  name                = "lo_compat_privileges"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-89" {
  name                = "lock_timeout"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-90" {
  name                = "log_autovacuum_min_duration"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "-1"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-91" {
  name                = "log_checkpoints"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-92" {
  name                = "log_connections"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-93" {
  name                = "log_disconnections"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-94" {
  name                = "log_duration"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-95" {
  name                = "log_error_verbosity"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "default"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-96" {
  name                = "log_line_prefix"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "%t-%c-"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-97" {
  name                = "log_lock_waits"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-98" {
  name                = "log_min_duration_statement"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "-1"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-99" {
  name                = "log_min_error_statement"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "error"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-100" {
  name                = "log_min_messages"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "warning"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-101" {
  name                = "log_replication_commands"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-102" {
  name                = "log_retention_days"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "3"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-103" {
  name                = "log_statement"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "none"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-104" {
  name                = "log_statement_stats"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-105" {
  name                = "log_temp_files"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "-1"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-106" {
  name                = "logging_collector"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-107" {
  name                = "maintenance_work_mem"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "131072"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-108" {
  name                = "max_locks_per_transaction"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "64"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-109" {
  name                = "max_parallel_workers"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "8"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-110" {
  name                = "max_parallel_workers_per_gather"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "2"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-111" {
  name                = "max_prepared_transactions"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-112" {
  name                = "max_replication_slots"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "10"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-113" {
  name                = "max_standby_archive_delay"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "30000"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-114" {
  name                = "max_standby_streaming_delay"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "30000"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-115" {
  name                = "max_wal_senders"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "10"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-116" {
  name                = "max_wal_size"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "1024"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-117" {
  name                = "min_parallel_index_scan_size"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "64"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-118" {
  name                = "min_parallel_table_scan_size"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "1024"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-119" {
  name                = "min_wal_size"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "256"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-120" {
  name                = "old_snapshot_threshold"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "-1"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-121" {
  name                = "operator_precedence_warning"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-122" {
  name                = "parallel_leader_participation"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-123" {
  name                = "parallel_setup_cost"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "1000"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-124" {
  name                = "parallel_tuple_cost"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0.1"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-125" {
  name                = "pg_qs.interval_length_minutes"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "15"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-126" {
  name                = "pg_qs.max_query_text_length"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "6000"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-127" {
  name                = "pg_qs.query_capture_mode"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "none"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-128" {
  name                = "pg_qs.replace_parameter_placeholders"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-129" {
  name                = "pg_qs.retention_period_in_days"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "7"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-130" {
  name                = "pg_qs.track_utility"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-131" {
  name                = "pg_stat_statements.max"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "5000"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-132" {
  name                = "pg_stat_statements.save"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-133" {
  name                = "pg_stat_statements.track"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "none"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-134" {
  name                = "pg_stat_statements.track_utility"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-135" {
  name                = "pgms_wait_sampling.history_period"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "100"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-136" {
  name                = "pgms_wait_sampling.query_capture_mode"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "none"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-137" {
  name                = "postgis.gdal_enabled_drivers"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "DISABLE_ALL"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-138" {
  name                = "quote_all_identifiers"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-139" {
  name                = "random_page_cost"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "4.0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-140" {
  name                = "row_security"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-141" {
  name                = "search_path"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "\"$user\", public"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-142" {
  name                = "seq_page_cost"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "1.0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-143" {
  name                = "session_replication_role"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "origin"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-144" {
  name                = "shared_preload_libraries"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = ""
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-145" {
  name                = "statement_timeout"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-146" {
  name                = "synchronize_seqscans"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-147" {
  name                = "synchronous_commit"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-148" {
  name                = "tcp_keepalives_count"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-149" {
  name                = "tcp_keepalives_idle"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-150" {
  name                = "tcp_keepalives_interval"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-151" {
  name                = "temp_buffers"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "1024"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-152" {
  name                = "timezone"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "UTC"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-153" {
  name                = "track_activities"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-154" {
  name                = "track_activity_query_size"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "1024"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-155" {
  name                = "track_commit_timestamp"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-156" {
  name                = "track_counts"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-157" {
  name                = "track_functions"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "none"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-158" {
  name                = "track_io_timing"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "on"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-159" {
  name                = "transform_null_equals"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "off"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-160" {
  name                = "vacuum_cost_delay"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-161" {
  name                = "vacuum_cost_limit"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "200"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-162" {
  name                = "vacuum_cost_page_dirty"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "20"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-163" {
  name                = "vacuum_cost_page_hit"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "1"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-164" {
  name                = "vacuum_cost_page_miss"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "10"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-165" {
  name                = "vacuum_defer_cleanup_age"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-166" {
  name                = "vacuum_freeze_min_age"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "50000000"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-167" {
  name                = "vacuum_freeze_table_age"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "150000000"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-168" {
  name                = "vacuum_multixact_freeze_min_age"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "5000000"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-169" {
  name                = "vacuum_multixact_freeze_table_age"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "150000000"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-170" {
  name                = "wal_buffers"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "8192"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-171" {
  name                = "wal_receiver_status_interval"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "10"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-172" {
  name                = "wal_writer_delay"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "200"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-173" {
  name                = "wal_writer_flush_after"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "128"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-174" {
  name                = "work_mem"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "4096"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-175" {
  name                = "xmlbinary"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "base64"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_configuration" "res-176" {
  name                = "xmloption"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  value               = "content"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_database" "res-177" {
  charset             = "UTF8"
  collation           = "English_United States.1252"
  name                = "azure_maintenance"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_database" "res-178" {
  charset             = "UTF8"
  collation           = "English_United States.1252"
  name                = "azure_sys"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_database" "res-179" {
  charset             = "UTF8"
  collation           = "English_United States.1252"
  name                = "demo"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_database" "res-180" {
  charset             = "UTF8"
  collation           = "English_United States.1252"
  name                = "postgres"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_firewall_rule" "res-181" {
  end_ip_address      = "0.0.0.0"
  name                = "AllowIps"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  start_ip_address    = "0.0.0.0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_firewall_rule" "res-182" {
  end_ip_address      = "174.61.163.193"
  name                = "ServiceLinkerFirewallRulepostgres_conn1"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  start_ip_address    = "174.61.163.193"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
resource "azurerm_postgresql_firewall_rule" "res-183" {
  end_ip_address      = "255.255.255.255"
  name                = "svc_wrapk"
  resource_group_name = "aks-postgres-compete"
  server_name         = "aks-cli-postgres"
  start_ip_address    = "0.0.0.0"
  depends_on = [
    azurerm_postgresql_server.res-7,
  ]
}
