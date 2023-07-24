# grafaml

Create Grafana Dashboards from YAML using Helm Chart templating.

This YAML:

```yaml
title: "Simple Dashboard"
panels:
  panelWidth: 12
  panelHeight: 8
  list:
    - title: "Prometheus Targets Up"
      type: "stat"
      targets:
        - expr: "up"

    - title: "Resource Usage in Percent"
      description: "Memory and CPU Usage"
      type: "stat"
      targets:
        - expr: "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100"
          legendFormat: "Memory Usage"
        - expr: "sum by (instance, job)(avg by (mode, instance) (rate(node_cpu_seconds_total{mode!='idle'}[2m]))) * 100"
          legendFormat: "CPU Usage"

    - title: "Memory Usage in Percent over Time"
      type: "timeseries"
      targets:
        - expr: "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100"

    - title: "CPU Usage in Percent over Time"
      type: "timeseries"
      targets:
        - expr: "sum by (instance, job) (avg by (mode, instance) (rate(node_cpu_seconds_total{mode!='idle'}[2m])))"
```

Becomes this dashboard:

![Simple Dashboard](./example-dashboards/values-simple-dashboard.png)

## Problems Grafaml Addresses

1. **Grafana UI**: Creating and editing Dashboards in the Grafana UI can be a painstaking and slow process.

2. **Grafana JSON Model**: Creating and editing Dashboards via the Grafana JSON model is complicated,
due to the complexity of the JSON model and the absolute positioning of panels.

3. **Version Control**: Tracking dashboard changes in Git with the Grafan JSON model is inefficient.
Even little changes to the dashboard can cause hundreds of lines to change.

## Features

**Create Dashboards from YAML**: Instead of using the Grafana UI or writing complex JSON models,
you can write simplified YAML files from which the dashboard JSON is generated.
With this, version control becomes efficient again.

**Grid-Based Panel Positioning**: Instead of worrying about the absolute positioning of every single panel,
Grafaml arranges panels based on their definition order in a grid with a flexible number of columns.

**Kubernetes Deployment**: Grafaml is a Helm Chart.
Grafana Dashboards can be deployed as ConfigMaps, which can optionally be discovered by the [Grafana Sidecar Container][1].

## Limitations

**Variable Positioning of Panels**: Panels are arranged in a grid based on their definition order.
Due to this, it is not possible to have panels with variable width or positioning.

## Getting started

### Creating the dashboard YAML

First we need to create a Helm Values file containing the definition of our dashboard.
We'll call the file `values-my-dashboard.json`.
It will define a very simple dashboard with only 2 panels:

```yaml
title: "Simple Dashboard"
panels:
  panelWidth: 12
  panelHeight: 8
  list:
    - title: "Memory Usage in Percent over Time"
      type: "timeseries"
      targets:
        - expr: "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100"
    - title: "CPU Usage in Percent over Time"
      type: "timeseries"
      targets:
        - expr: "sum by (instance, job) (avg by (mode, instance) (rate(node_cpu_seconds_total{mode!='idle'}[2m])))"
```

You can find all possible configuration options in the [default `values.yaml`](./charts/grafaml/values.yaml)
and in the [Values](#values) section.

You can find example Dashboards in the [`example-dashboards`](./example-dashboards/) directory.

In the next stept, the `values-my-dashboard.json` will be merged with the default [default `values.yaml`](./charts/grafaml/values.yaml),
from which the dashboard JSON will be generated.

### Generating the dashboard JSON

This step is optional if you want to [deploy the dashboard in a Kubernetes Cluster](#deploying-the-dashboard-in-kubernetes).

Execute this code in your Shell to create a `dashboard.json`:

```shell
# Adapt the variables to your needs
name="my-dashboard"
values="./values-my-dashboard.yaml"
helm template $name oci://registry-1.docker.io/ernail/grafaml --values $values --set onlyRenderDashboardJson=true | tail -n +3 > dashboard.json
```

### Deploying the dashboard in Kubernetes

Execute this code in your shell to deploy the dashboard as ConfigMap in Kubernetes:

```shell
name="my-dashboard"
values="./values-my-dashboard.yaml"
namespace="my-namespace"
helm upgrade $name oci://registry-1.docker.io/ernail/grafaml --install --create-namespace --namespace $namespace --values $values
```

If you are using the [Grafana Sidecar Container][1], the dashboard should now be available in your Grafana.

[1]: https://github.com/grafana/helm-charts/blob/main/charts/grafana/README.md#sidecar-for-dashboards

## Usage

The basic usage of Grafaml is already explained in the [Getting Started](#getting-started) section.
Any additional usage information is documented here.

### Using Helmfile

[Helmfile](https://github.com/helmfile/helmfile) is a declarative spec for deploying Helm Charts.
It can be used to simplify the commands for rendering and deploying the dashboards.

If you want to use Helmfile, here is an example `helmfile.yaml`:

```yaml
repositories:
  - name: "ernail"
    url: "registry-1.docker.io/ernail"
    oci: true

releases:
  - name: "my-dashboard"
    namespace: "my-namespace"
    chart: "ernail/grafaml"
    version: "1.0.0"
    values:
      - "./values-my-dashboard.yaml"
      - onlyRenderDashboardJson: false
```

Execute this code in your Shell to create a `dashboard.json`:

```shell
helmfile template --file ./helmfile.yaml --set onlyRenderDashboardJson=true | tail -n +3 > dashboard.json
```

Execute this code in your shell to deploy the dashboard as ConfigMap in Kubernetes:

```shell
helmfile apply --file ./helmfile.yaml
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| annotations | object | `{"enabled":false,"list":[{"expr":"up","name":"My Annotation"}]}` | The dashboard annotations. Ref: [Grafana JSON Visualizations](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/annotate-visualizations/)  |
| annotations.list | list | `[{"expr":"up","name":"My Annotation"}]` | Grafana does not provide a full list with options. To find out about other options, create the desired annotations in the Grafana UI, inspect the JSON, and transform it to YAML. |
| editable | bool | `true` | Wether the dashboard is editable or not. Ref: [Grafana JSON Fields](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/view-dashboard-json-model/#json-fields)  |
| extraLabels | object | `{"created-with":"grafaml"}` | Additional labels to add to the ConfigMap. Ref: [Kubernetes Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)  |
| graphTooltip | string | `"0"` | The tooltip behavior of the dashboard. 0 for no shared crosshair or tooltip (default), 1 for shared crosshair, 2 for shared crosshair and shared tooltip. Ref: [Grafana JSON Fields](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/view-dashboard-json-model/#json-fields)  |
| onlyRenderDashboardJson | bool | `false` | Wether to render only the dashboard JSON, or the entire ConfigMap. Set this to true if you are not interested in deploying the Dashboard in a Kubernetes Cluster. Use `helm template ./charts/grafaml --set onlyRenderDashboardJson=true | tail -n +3 > dashboard.json` to get the dashboard JSON model as a file.  |
| panels | object | `{"list":[{"targets":[{"expr":"up"}],"title":"Prometheus Targets Up","type":"stat"},{"description":"Memory and CPU Usage","targets":[{"expr":"(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100","legendFormat":"Memory Usage"},{"expr":"sum by (instance, job)(avg by (mode, instance) (rate(node_cpu_seconds_total{mode!='idle'}[2m]))) * 100","legendFormat":"CPU Usage"}],"title":"Resource Usage in Percent","type":"stat"},{"targets":[{"expr":"(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100"}],"title":"Memory Usage in Percent over Time","type":"timeseries"},{"targets":[{"expr":"sum by (instance, job) (avg by (mode, instance) (rate(node_cpu_seconds_total{mode!='idle'}[2m])))"}],"title":"CPU Usage in Percent over Time","type":"timeseries"}],"panelHeight":8,"panelWidth":12}` | The dashboard panels. The positioning will be handled automatically, so there is no need to define the "gridPos" Ref: [Grafana JSON Panels](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/view-dashboard-json-model/#panels)  |
| panels.list | list | `[{"targets":[{"expr":"up"}],"title":"Prometheus Targets Up","type":"stat"},{"description":"Memory and CPU Usage","targets":[{"expr":"(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100","legendFormat":"Memory Usage"},{"expr":"sum by (instance, job)(avg by (mode, instance) (rate(node_cpu_seconds_total{mode!='idle'}[2m]))) * 100","legendFormat":"CPU Usage"}],"title":"Resource Usage in Percent","type":"stat"},{"targets":[{"expr":"(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100"}],"title":"Memory Usage in Percent over Time","type":"timeseries"},{"targets":[{"expr":"sum by (instance, job) (avg by (mode, instance) (rate(node_cpu_seconds_total{mode!='idle'}[2m])))"}],"title":"CPU Usage in Percent over Time","type":"timeseries"}]` | Check [Grafana JSON Panels](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/view-dashboard-json-model/#panels) for more options. Grafana does not provide a full list with options. To find out about other options, create the desired panels in the Grafana UI, inspect the panel JSON, and transform it to YAML. For example dashboards created with grafaml, check out the [example charts](https://github.com/erNail/grafaml/tree/main/example-charts)  |
| panels.panelWidth | int | `12` | Grafana dashboards have a maximum width of 24. The panel width has to be a factor of 24.  |
| refresh | string | `"30s"` | The auto-refresh interval. Ref: [Grafana JSON Fields](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/view-dashboard-json-model/#json-fields)  |
| style | string | `"dark"` | The style of the dashboard, either "dark" or "light". Ref: [Grafana JSON Fields](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/view-dashboard-json-model/#json-fields)  |
| tags | list | `["grafaml"]` | The tags of the dashboard. Ref: [Grafana JSON Fields](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/view-dashboard-json-model/#json-fields)  |
| templating | object | `{"enabled":false,"list":[{"allFormat":"wildcard","current":{"text":"prod","value":"prod"},"includeAll":true,"multi":true,"name":"environment","query":"tag_values(cpu.utilization.average,env)","type":"query"}]}` | The dashboard template variables. Ref: [Grafana JSON Templating](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/view-dashboard-json-model/#templating)  |
| templating.list | list | `[{"allFormat":"wildcard","current":{"text":"prod","value":"prod"},"includeAll":true,"multi":true,"name":"environment","query":"tag_values(cpu.utilization.average,env)","type":"query"}]` | Check [Grafana JSON Templating](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/view-dashboard-json-model/#templating) for all possible options.  |
| time | object | `{"from":"now-6h","to":"now"}` | The time range for the dashboard. Ref: [Grafana JSON Fields](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/view-dashboard-json-model/#json-fields)  |
| timepicker | object | `{"collapse":false,"enable":true,"enabled":false,"notice":false,"now":true,"status":"Stable","type":"timepicker"}` | The configuration of the time picker. Check [Grafana JSON Timepicker](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/view-dashboard-json-model/#timepicker) for all possible options. Ref: [Grafana JSON Timepicker](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/view-dashboard-json-model/#timepicker)   |
| timepicker.enable | bool | `true` | Wether the timepicker is enabled or not.  |
| timepicker.enabled | bool | `false` | Wether the timepicker configuration is rendered or not.  |
| timezone | string | `"browser"` | The timezone of the dashboard, either "utc" or "browser". Ref: [Grafana JSON Fields](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/view-dashboard-json-model/#json-fields)  |
| title | string | `"Grafana Dashboard"` | The displayed title of the Dashboard. Ref: [Grafana JSON Fields](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/view-dashboard-json-model/#json-fields)  |

## Development

### Testing

```shell
helm unittest ./charts/grafaml
```

### Linting

```shell
pip install -r requirements.txt
pre-commit run --all-files
helm lint ./charts/grafaml
kube-linter lint ./charts/grafaml
```

### Templating

Using Helm:

```shell
helm template grafaml ./charts/grafaml
```

Using Helmfile:

```shell
helmfile template --file ./charts/grafaml/helmfile.yaml
```

### Deploying

Using Helm:

```shell
helm upgrade grafaml ./charts/grafaml --install --create-namespace --namespace grafaml
```

Using Helmfile:

```shell
helmfile apply --file ./charts/grafaml/helmfile.yaml
```

### Generating documentation

```shell
helm-docs ./charts/grafaml/ --output-file ../../README.md
helm-docs ./charts/grafaml/
```
