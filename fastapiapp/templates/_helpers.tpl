{{/*
This helper function generates the service URL based on the type and configuration of each service.
*/}}

{{- define "fastapiapp.serviceURL" -}}
{{- range $serviceName, $serviceConfig := .Values.services }}
  {{- if eq $serviceConfig.type "NodePort" }}
    export NODE_PORT=$(kubectl get --namespace {{ .Release.Namespace }} -o jsonpath="{.spec.ports[0].nodePort}" services {{ include "fastapiapp.fullname" . }}-{{ $serviceName }})
    export NODE_IP=$(kubectl get nodes --namespace {{ .Release.Namespace }} -o jsonpath="{.items[0].status.addresses[0].address}")
    echo http://$NODE_IP:$NODE_PORT
  {{- else if eq $serviceConfig.type "ClusterIP" }}
    export POD_NAME=$(kubectl get pods --namespace {{ .Release.Namespace }} -l "app.kubernetes.io/name={{ include "fastapiapp.name" . }},app.kubernetes.io/instance={{ .Release.Name }}" -o jsonpath="{.items[0].metadata.name}")
    export CONTAINER_PORT=$(kubectl get pod --namespace {{ .Release.Namespace }} $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
    echo "Visit http://127.0.0.1:{{ $serviceConfig.port }} to use your application"
    kubectl --namespace {{ .Release.Namespace }} port-forward $POD_NAME 8080:$CONTAINER_PORT
  {{- else if eq $serviceConfig.type "LoadBalancer" }}
    NOTE: It may take a few minutes for the LoadBalancer IP to be available.
    You can watch its status by running 'kubectl get --namespace {{ .Release.Namespace }} svc -w {{ include "fastapiapp.fullname" . }}-{{ $serviceName }}'
    export SERVICE_IP=$(kubectl get svc --namespace {{ .Release.Namespace }} {{ include "fastapiapp.fullname" . }}-{{ $serviceName }} --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
    echo http://$SERVICE_IP:{{ $serviceConfig.port }}
  {{- end }}
{{- end }}
{{- end }}
