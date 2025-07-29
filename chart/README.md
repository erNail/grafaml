# grafaml

> WARNING: This chart has moved registries. Starting from v3.0.0,
> it will be available only at oci://ghcr.io/ernail/charts/grafaml

Generate Grafana dashboards from YAML with automatic panel positioning using Helm Chart templating.

Find the full documentation at [GitHub](https://github.com/erNail/grafaml).

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| ernail | <nagel.eric.95@googlemail.com> |  |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| apiVersions | object | `{"configMap":"v1"}` | The api versions of the resources created by this chart.  Ref: https://kubernetes.io/docs/reference/using-api/deprecation-guide/ |
| dashboardBase | object | `{"tags":["grafaml"],"title":"Grafana Dashboard"}` | The base definition of the Dashboard. This field can contain any valid Grafana JSON Dashboard model as YAML. It must **not contain the `panels` field**. Check `.Values.panels` for more information. It must **not contain the `uid` field**. Check `.Values.uid` for more information. Be aware that Grafana does not provide a full overview of all available fields. To find out about other options, it's possible to create the desired dashboard in the UI, then inspect the JSON.  Ref: https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/view-dashboard-json-model/#json-fields |
| dashboardBase.tags | list | `["grafaml"]` | The tags of the dashboard. |
| extraLabels | object | `{"grafana_dashboard":"1"}` | Additional labels to add to the ConfigMap. |
| fullnameOverride | string | `""` | Use this to override the fullname of the chart. |
| nameOverride | string | `""` | Use this to override the name of the chart. |
| namespaceOverride | string | `""` | Use this to override the namespace of the chart. By default, `.Release.Namespace` is used. |
| onlyRenderDashboardJson | bool | `false` | Wether to render only the dashboard JSON, or the entire ConfigMap. |
| panels | object | `{"columns":2,"list":[{"targets":[{"expr":"up"}],"title":"Prometheus Targets Up","type":"stat"},{"description":"Memory and CPU Usage","targets":[{"expr":"(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100","legendFormat":"Memory Usage"},{"expr":"sum by (instance, job)(avg by (mode, instance) (rate(node_cpu_seconds_total{mode!='idle'}[2m]))) * 100","legendFormat":"CPU Usage"}],"title":"Resource Usage in Percent","type":"stat"},{"targets":[{"expr":"(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100"}],"title":"Memory Usage in Percent over Time","type":"timeseries"},{"targets":[{"expr":"sum by (instance, job) (avg by (mode, instance) (rate(node_cpu_seconds_total{mode!='idle'}[2m])))"}],"title":"CPU Usage in Percent over Time","type":"timeseries"}],"panelHeight":8}` | The configuration of the automatically positioned panels. |
| panels.columns | int | `2` | The number of columns of the grid in which the panels are placed. With 2 columns, each panel will have a width of 12 grid units |
| panels.list | list | `[{"targets":[{"expr":"up"}],"title":"Prometheus Targets Up","type":"stat"},{"description":"Memory and CPU Usage","targets":[{"expr":"(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100","legendFormat":"Memory Usage"},{"expr":"sum by (instance, job)(avg by (mode, instance) (rate(node_cpu_seconds_total{mode!='idle'}[2m]))) * 100","legendFormat":"CPU Usage"}],"title":"Resource Usage in Percent","type":"stat"},{"targets":[{"expr":"(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100"}],"title":"Memory Usage in Percent over Time","type":"timeseries"},{"targets":[{"expr":"sum by (instance, job) (avg by (mode, instance) (rate(node_cpu_seconds_total{mode!='idle'}[2m])))"}],"title":"CPU Usage in Percent over Time","type":"timeseries"}]` | The list of panels Each item can contain any valid Grafana JSON Panel model as YAML. Be aware that Grafana does not provide a full overview of all available fields. To find out about other options, it's possible to create the desired dashboard in the UI, then inspect the JSON. For example dashboards created with grafaml, check out the [example charts](https://github.com/erNail/grafaml/tree/main/example-charts)  |
| panels.panelHeight | int | `8` | The height of each panel in grid units. |
| uid | string | `""` | The unique identifier of the Dashboard. If not set, the sha1sum of {{ .names.fullname }} will be used. When setting a value, make sure it is unique across all dashboards in your Grafana instance. The value must be between 8 and 40 characters.  Ref: https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/view-dashboard-json-model/#json-fields |
