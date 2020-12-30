{{/* Use annottations or not */}}
{{- define "linkapi.secrets"}}
{{- if .secretsArn }}
annotations:
  secrets.k8s.aws/sidecarInjectorWebhook: enabled
  secrets.k8s.aws/secret-arn: {{ .secretsArn}}
{{- end }}
{{- end }}

{{/* Define configmap data*/}}
{{- define "linkapi.configMapData"}}
{{- if .envFrom -}}
{{- range $k, $v := .envFrom.configMap.data }}
  {{$k}}: {{$v}}
{{- end }}
{{- end -}}
{{- end}}

{{/* Define secret data*/}}
{{- define "linkapi.secretsData"}}
{{- if .envFrom -}}
{{- range $k, $v := .envFrom.secrets.data }}
  {{$k}}: {{$v | b64enc}}
{{- end }}
{{- end -}}
{{- end}}

{{/* Define container ports */}}
{{- define "linkapi.containersPorts" }}
{{- if .containers.ports }}
ports:
  {{- range $k, $v := .containers.ports }}
  - name: {{ $v.name }}
    containerPort: {{ $v.containerPort}}
    protocol: {{ $v.protocol}}
  {{- end }}
{{- else }}
ports:
  - name: http
    containerPort: 80
    protocol: TCP
{{- end }}
{{- end }}

{{/* Define healthcheck / eadinessProbe and livenessProbe */}}
{{- define "linkapi.healthcheck" }}
{{- if .healthcheck.enabled }}
readinessProbe:
  httpGet:
    path: {{ default "/healthcheck" .healthcheck.path }}
    port: {{ default 80 .healthcheck.port}}
  initialDelaySeconds: {{ default 30 .healthcheck.initialDelaySeconds}}
  timeoutSeconds: {{ default 1 .healthcheck.timeoutSeconds}}
  periodSeconds: {{ default 20 .healthcheck.periodSeconds}}
livenessProbe:
  httpGet:
    path: {{ default "/healthcheck" .healthcheck.path }}
    port: {{ default 80 .healthcheck.port}}
  initialDelaySeconds: {{ default 30 .healthcheck.initialDelaySeconds}}
  timeoutSeconds: {{ default 1 .healthcheck.timeoutSeconds}}
  periodSeconds: {{ default 20 .healthcheck.periodSeconds}}
{{- end }}
{{- end }}

{{/* Define initContainers */}}
{{- define "linkapi.initContainers" }}
{{- if .initContainers.enabled }}
initContainers:
{{- range $key, $val := .initContainers.inits }}
- name: {{ $val.name }}
  image: {{ $val.image }}
  envFrom:
    - configMapRef:
        name: {{ $val.envFrom.configMapRef.name }}
  volumeMounts:
  - name: {{ $val.volumeMounts.name }}
    mountPath: {{ $val.volumeMounts.mountPath }}
{{- end}}
{{- end }}
{{- end }}

{{/* Define containers.volumeMounts */}}
{{- define "linkapi.volumeMounts" -}}
{{- if .containers.volumeMounts }}
volumeMounts:
  {{- range $k, $v := .containers.volumeMounts}}
  - name: {{ $k }}
    mountPath: {{ $v.mountPath}}
  {{- end }}
{{- end }}
{{- end }}

{{/* Define containers.env */}}
{{- define "linkapi.containersEnv" -}}
{{- if .containers.env }}
env:
  {{- range $k, $v := .containers.env }}
  - name: {{ $v.name }}
    value: {{ $v.value }}
  {{- end }}
{{- end }}
{{- end }}





