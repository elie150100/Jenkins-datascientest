{{/*
Expand the name of the chart.
*/}}
{{- define "fastapiapp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "fastapiapp.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "fastapiapp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fastapiapp.labels" -}}
helm.sh/chart: {{ include "fastapiapp.chart" . }}
{{ include "fastapiapp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fastapiapp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fastapiapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
This helper function generates the service URL based on the type and configuration of each service.
*/}}
{{- define "fastapiapp.serviceURL" -}}
{{- $root := . }}
{{- range $serviceName, $serviceConfig := .Values.services }}
Service: {{ $serviceName }}
  {{- if eq $serviceConfig.type "NodePort" }}
    export NODE_PORT=$(kubectl get --namespace {{ $root.Release.Namespace }} -o jsonpath="{.spec.ports[0].nodePort}" services {{ include "fastapiapp.fullname" $root }}-{{ $serviceName }})
    export NODE_IP=$(kubectl get nodes --namespace {{ $root.Release.Namespace }} -o jsonpath="{.items[0].status.addresses[0].address}")
    echo http://$NODE_IP:$NODE_PORT
  {{- else if eq $serviceConfig.type "ClusterIP" }}
    export POD_NAME=$(kubectl get pods --namespace {{ $root.Release.Namespace }} -l "app.kubernetes.io/name={{ include "fastapiapp.name" $root }},app.kubernetes.io/instance={{ $root.Release.Name }},service={{ $serviceName }}" -o jsonpath="{.items[0].metadata.name}")
    export CONTAINER_PORT=$(kubectl get pod --namespace {{ $root.Release.Namespace }} $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
    echo "Visit http://127.0.0.1:{{ $serviceConfig.port }} to use your application"
    kubectl --namespace {{ $root.Release.Namespace }} port-forward $POD_NAME 8080:$CONTAINER_PORT
  {{- else if eq $serviceConfig.type "LoadBalancer" }}
    NOTE: It may take a few minutes for the LoadBalancer IP to be available.
    You can watch its status by running 'kubectl get --namespace {{ $root.Release.Namespace }} svc -w {{ include "fastapiapp.fullname" $root }}-{{ $serviceName }}'
    export SERVICE_IP=$(kubectl get svc --namespace {{ $root.Release.Namespace }} {{ include "fastapiapp.fullname" $root }}-{{ $serviceName }} --template "{{ "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}" }}")
    echo http://$SERVICE_IP:{{ $serviceConfig.port }}
  {{- end }}
{{- end }}
{{- end }}