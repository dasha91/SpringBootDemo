import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete"
  to = azurerm_resource_group.res-0
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.ContainerRegistry/registries/postgresacr"
  to = azurerm_container_registry.res-1
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.ContainerRegistry/registries/postgresacr/scopeMaps/_repositories_admin"
  to = azurerm_container_registry_scope_map.res-2
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.ContainerRegistry/registries/postgresacr/scopeMaps/_repositories_pull"
  to = azurerm_container_registry_scope_map.res-3
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.ContainerRegistry/registries/postgresacr/scopeMaps/_repositories_push"
  to = azurerm_container_registry_scope_map.res-4
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.ContainerService/managedClusters/aks-cli-cluster"
  to = azurerm_kubernetes_cluster.res-5
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.ContainerService/managedClusters/aks-cli-cluster/agentPools/nodepool1"
  to = azurerm_kubernetes_cluster_node_pool.res-6
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres"
  to = azurerm_postgresql_server.res-7
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres"
  to = azurerm_postgresql_active_directory_administrator.res-8
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/array_nulls"
  to = azurerm_postgresql_configuration.res-9
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/autovacuum"
  to = azurerm_postgresql_configuration.res-10
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/autovacuum_analyze_scale_factor"
  to = azurerm_postgresql_configuration.res-11
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/autovacuum_analyze_threshold"
  to = azurerm_postgresql_configuration.res-12
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/autovacuum_freeze_max_age"
  to = azurerm_postgresql_configuration.res-13
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/autovacuum_max_workers"
  to = azurerm_postgresql_configuration.res-14
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/autovacuum_multixact_freeze_max_age"
  to = azurerm_postgresql_configuration.res-15
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/autovacuum_naptime"
  to = azurerm_postgresql_configuration.res-16
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/autovacuum_vacuum_cost_delay"
  to = azurerm_postgresql_configuration.res-17
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/autovacuum_vacuum_cost_limit"
  to = azurerm_postgresql_configuration.res-18
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/autovacuum_vacuum_scale_factor"
  to = azurerm_postgresql_configuration.res-19
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/autovacuum_vacuum_threshold"
  to = azurerm_postgresql_configuration.res-20
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/autovacuum_work_mem"
  to = azurerm_postgresql_configuration.res-21
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/azure.replication_support"
  to = azurerm_postgresql_configuration.res-22
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/backend_flush_after"
  to = azurerm_postgresql_configuration.res-23
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/backslash_quote"
  to = azurerm_postgresql_configuration.res-24
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/bgwriter_delay"
  to = azurerm_postgresql_configuration.res-25
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/bgwriter_flush_after"
  to = azurerm_postgresql_configuration.res-26
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/bgwriter_lru_maxpages"
  to = azurerm_postgresql_configuration.res-27
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/bgwriter_lru_multiplier"
  to = azurerm_postgresql_configuration.res-28
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/bytea_output"
  to = azurerm_postgresql_configuration.res-29
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/check_function_bodies"
  to = azurerm_postgresql_configuration.res-30
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/checkpoint_completion_target"
  to = azurerm_postgresql_configuration.res-31
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/checkpoint_warning"
  to = azurerm_postgresql_configuration.res-32
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/client_encoding"
  to = azurerm_postgresql_configuration.res-33
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/client_min_messages"
  to = azurerm_postgresql_configuration.res-34
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/commit_delay"
  to = azurerm_postgresql_configuration.res-35
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/commit_siblings"
  to = azurerm_postgresql_configuration.res-36
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/connection_throttling"
  to = azurerm_postgresql_configuration.res-37
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/constraint_exclusion"
  to = azurerm_postgresql_configuration.res-38
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/cpu_index_tuple_cost"
  to = azurerm_postgresql_configuration.res-39
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/cpu_operator_cost"
  to = azurerm_postgresql_configuration.res-40
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/cpu_tuple_cost"
  to = azurerm_postgresql_configuration.res-41
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/cursor_tuple_fraction"
  to = azurerm_postgresql_configuration.res-42
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/datestyle"
  to = azurerm_postgresql_configuration.res-43
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/deadlock_timeout"
  to = azurerm_postgresql_configuration.res-44
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/debug_print_parse"
  to = azurerm_postgresql_configuration.res-45
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/debug_print_plan"
  to = azurerm_postgresql_configuration.res-46
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/debug_print_rewritten"
  to = azurerm_postgresql_configuration.res-47
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/default_statistics_target"
  to = azurerm_postgresql_configuration.res-48
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/default_text_search_config"
  to = azurerm_postgresql_configuration.res-49
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/default_transaction_deferrable"
  to = azurerm_postgresql_configuration.res-50
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/default_transaction_isolation"
  to = azurerm_postgresql_configuration.res-51
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/default_transaction_read_only"
  to = azurerm_postgresql_configuration.res-52
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/default_with_oids"
  to = azurerm_postgresql_configuration.res-53
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/effective_cache_size"
  to = azurerm_postgresql_configuration.res-54
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/enable_bitmapscan"
  to = azurerm_postgresql_configuration.res-55
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/enable_hashagg"
  to = azurerm_postgresql_configuration.res-56
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/enable_hashjoin"
  to = azurerm_postgresql_configuration.res-57
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/enable_indexonlyscan"
  to = azurerm_postgresql_configuration.res-58
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/enable_indexscan"
  to = azurerm_postgresql_configuration.res-59
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/enable_material"
  to = azurerm_postgresql_configuration.res-60
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/enable_mergejoin"
  to = azurerm_postgresql_configuration.res-61
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/enable_nestloop"
  to = azurerm_postgresql_configuration.res-62
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/enable_partitionwise_aggregate"
  to = azurerm_postgresql_configuration.res-63
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/enable_partitionwise_join"
  to = azurerm_postgresql_configuration.res-64
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/enable_seqscan"
  to = azurerm_postgresql_configuration.res-65
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/enable_sort"
  to = azurerm_postgresql_configuration.res-66
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/enable_tidscan"
  to = azurerm_postgresql_configuration.res-67
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/escape_string_warning"
  to = azurerm_postgresql_configuration.res-68
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/exit_on_error"
  to = azurerm_postgresql_configuration.res-69
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/extra_float_digits"
  to = azurerm_postgresql_configuration.res-70
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/force_parallel_mode"
  to = azurerm_postgresql_configuration.res-71
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/from_collapse_limit"
  to = azurerm_postgresql_configuration.res-72
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/geqo"
  to = azurerm_postgresql_configuration.res-73
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/geqo_effort"
  to = azurerm_postgresql_configuration.res-74
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/geqo_generations"
  to = azurerm_postgresql_configuration.res-75
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/geqo_pool_size"
  to = azurerm_postgresql_configuration.res-76
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/geqo_seed"
  to = azurerm_postgresql_configuration.res-77
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/geqo_selection_bias"
  to = azurerm_postgresql_configuration.res-78
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/geqo_threshold"
  to = azurerm_postgresql_configuration.res-79
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/gin_fuzzy_search_limit"
  to = azurerm_postgresql_configuration.res-80
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/gin_pending_list_limit"
  to = azurerm_postgresql_configuration.res-81
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/hot_standby_feedback"
  to = azurerm_postgresql_configuration.res-82
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/idle_in_transaction_session_timeout"
  to = azurerm_postgresql_configuration.res-83
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/intervalstyle"
  to = azurerm_postgresql_configuration.res-84
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/join_collapse_limit"
  to = azurerm_postgresql_configuration.res-85
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/lc_monetary"
  to = azurerm_postgresql_configuration.res-86
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/lc_numeric"
  to = azurerm_postgresql_configuration.res-87
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/lo_compat_privileges"
  to = azurerm_postgresql_configuration.res-88
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/lock_timeout"
  to = azurerm_postgresql_configuration.res-89
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/log_autovacuum_min_duration"
  to = azurerm_postgresql_configuration.res-90
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/log_checkpoints"
  to = azurerm_postgresql_configuration.res-91
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/log_connections"
  to = azurerm_postgresql_configuration.res-92
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/log_disconnections"
  to = azurerm_postgresql_configuration.res-93
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/log_duration"
  to = azurerm_postgresql_configuration.res-94
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/log_error_verbosity"
  to = azurerm_postgresql_configuration.res-95
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/log_line_prefix"
  to = azurerm_postgresql_configuration.res-96
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/log_lock_waits"
  to = azurerm_postgresql_configuration.res-97
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/log_min_duration_statement"
  to = azurerm_postgresql_configuration.res-98
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/log_min_error_statement"
  to = azurerm_postgresql_configuration.res-99
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/log_min_messages"
  to = azurerm_postgresql_configuration.res-100
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/log_replication_commands"
  to = azurerm_postgresql_configuration.res-101
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/log_retention_days"
  to = azurerm_postgresql_configuration.res-102
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/log_statement"
  to = azurerm_postgresql_configuration.res-103
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/log_statement_stats"
  to = azurerm_postgresql_configuration.res-104
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/log_temp_files"
  to = azurerm_postgresql_configuration.res-105
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/logging_collector"
  to = azurerm_postgresql_configuration.res-106
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/maintenance_work_mem"
  to = azurerm_postgresql_configuration.res-107
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/max_locks_per_transaction"
  to = azurerm_postgresql_configuration.res-108
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/max_parallel_workers"
  to = azurerm_postgresql_configuration.res-109
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/max_parallel_workers_per_gather"
  to = azurerm_postgresql_configuration.res-110
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/max_prepared_transactions"
  to = azurerm_postgresql_configuration.res-111
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/max_replication_slots"
  to = azurerm_postgresql_configuration.res-112
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/max_standby_archive_delay"
  to = azurerm_postgresql_configuration.res-113
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/max_standby_streaming_delay"
  to = azurerm_postgresql_configuration.res-114
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/max_wal_senders"
  to = azurerm_postgresql_configuration.res-115
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/max_wal_size"
  to = azurerm_postgresql_configuration.res-116
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/min_parallel_index_scan_size"
  to = azurerm_postgresql_configuration.res-117
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/min_parallel_table_scan_size"
  to = azurerm_postgresql_configuration.res-118
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/min_wal_size"
  to = azurerm_postgresql_configuration.res-119
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/old_snapshot_threshold"
  to = azurerm_postgresql_configuration.res-120
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/operator_precedence_warning"
  to = azurerm_postgresql_configuration.res-121
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/parallel_leader_participation"
  to = azurerm_postgresql_configuration.res-122
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/parallel_setup_cost"
  to = azurerm_postgresql_configuration.res-123
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/parallel_tuple_cost"
  to = azurerm_postgresql_configuration.res-124
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/pg_qs.interval_length_minutes"
  to = azurerm_postgresql_configuration.res-125
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/pg_qs.max_query_text_length"
  to = azurerm_postgresql_configuration.res-126
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/pg_qs.query_capture_mode"
  to = azurerm_postgresql_configuration.res-127
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/pg_qs.replace_parameter_placeholders"
  to = azurerm_postgresql_configuration.res-128
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/pg_qs.retention_period_in_days"
  to = azurerm_postgresql_configuration.res-129
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/pg_qs.track_utility"
  to = azurerm_postgresql_configuration.res-130
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/pg_stat_statements.max"
  to = azurerm_postgresql_configuration.res-131
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/pg_stat_statements.save"
  to = azurerm_postgresql_configuration.res-132
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/pg_stat_statements.track"
  to = azurerm_postgresql_configuration.res-133
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/pg_stat_statements.track_utility"
  to = azurerm_postgresql_configuration.res-134
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/pgms_wait_sampling.history_period"
  to = azurerm_postgresql_configuration.res-135
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/pgms_wait_sampling.query_capture_mode"
  to = azurerm_postgresql_configuration.res-136
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/postgis.gdal_enabled_drivers"
  to = azurerm_postgresql_configuration.res-137
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/quote_all_identifiers"
  to = azurerm_postgresql_configuration.res-138
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/random_page_cost"
  to = azurerm_postgresql_configuration.res-139
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/row_security"
  to = azurerm_postgresql_configuration.res-140
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/search_path"
  to = azurerm_postgresql_configuration.res-141
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/seq_page_cost"
  to = azurerm_postgresql_configuration.res-142
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/session_replication_role"
  to = azurerm_postgresql_configuration.res-143
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/shared_preload_libraries"
  to = azurerm_postgresql_configuration.res-144
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/statement_timeout"
  to = azurerm_postgresql_configuration.res-145
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/synchronize_seqscans"
  to = azurerm_postgresql_configuration.res-146
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/synchronous_commit"
  to = azurerm_postgresql_configuration.res-147
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/tcp_keepalives_count"
  to = azurerm_postgresql_configuration.res-148
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/tcp_keepalives_idle"
  to = azurerm_postgresql_configuration.res-149
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/tcp_keepalives_interval"
  to = azurerm_postgresql_configuration.res-150
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/temp_buffers"
  to = azurerm_postgresql_configuration.res-151
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/timezone"
  to = azurerm_postgresql_configuration.res-152
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/track_activities"
  to = azurerm_postgresql_configuration.res-153
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/track_activity_query_size"
  to = azurerm_postgresql_configuration.res-154
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/track_commit_timestamp"
  to = azurerm_postgresql_configuration.res-155
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/track_counts"
  to = azurerm_postgresql_configuration.res-156
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/track_functions"
  to = azurerm_postgresql_configuration.res-157
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/track_io_timing"
  to = azurerm_postgresql_configuration.res-158
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/transform_null_equals"
  to = azurerm_postgresql_configuration.res-159
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/vacuum_cost_delay"
  to = azurerm_postgresql_configuration.res-160
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/vacuum_cost_limit"
  to = azurerm_postgresql_configuration.res-161
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/vacuum_cost_page_dirty"
  to = azurerm_postgresql_configuration.res-162
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/vacuum_cost_page_hit"
  to = azurerm_postgresql_configuration.res-163
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/vacuum_cost_page_miss"
  to = azurerm_postgresql_configuration.res-164
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/vacuum_defer_cleanup_age"
  to = azurerm_postgresql_configuration.res-165
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/vacuum_freeze_min_age"
  to = azurerm_postgresql_configuration.res-166
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/vacuum_freeze_table_age"
  to = azurerm_postgresql_configuration.res-167
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/vacuum_multixact_freeze_min_age"
  to = azurerm_postgresql_configuration.res-168
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/vacuum_multixact_freeze_table_age"
  to = azurerm_postgresql_configuration.res-169
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/wal_buffers"
  to = azurerm_postgresql_configuration.res-170
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/wal_receiver_status_interval"
  to = azurerm_postgresql_configuration.res-171
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/wal_writer_delay"
  to = azurerm_postgresql_configuration.res-172
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/wal_writer_flush_after"
  to = azurerm_postgresql_configuration.res-173
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/work_mem"
  to = azurerm_postgresql_configuration.res-174
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/xmlbinary"
  to = azurerm_postgresql_configuration.res-175
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/configurations/xmloption"
  to = azurerm_postgresql_configuration.res-176
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/databases/azure_maintenance"
  to = azurerm_postgresql_database.res-177
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/databases/azure_sys"
  to = azurerm_postgresql_database.res-178
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/databases/demo"
  to = azurerm_postgresql_database.res-179
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/databases/postgres"
  to = azurerm_postgresql_database.res-180
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/firewallRules/AllowIps"
  to = azurerm_postgresql_firewall_rule.res-181
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/firewallRules/ServiceLinkerFirewallRulepostgres_conn1"
  to = azurerm_postgresql_firewall_rule.res-182
}
import {
  id = "/subscriptions/ad70ac39-7cb2-4ed2-8678-f192bc4272b6/resourceGroups/aks-postgres-compete/providers/Microsoft.DBforPostgreSQL/servers/aks-cli-postgres/firewallRules/svc_wrapk"
  to = azurerm_postgresql_firewall_rule.res-183
}
