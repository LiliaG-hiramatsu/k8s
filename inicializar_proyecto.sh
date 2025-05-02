#!/bin/bash

# Script: inicializar_proyecto.sh

# Descripcion: Automatiza la creacion del entorno Kubernetes con dos repos:
#	- Clona el sitio web estatico desde un fork
#	- Crea la estructura de manifiestos Kubernetes
#	- Crea y sube el repositorio `k8s` a github

set -euo pipefail
IFS=$'\n\t'

# ---- CONFIGURACION ----

USUARIO_GITHUB="LiliaG-hiramatsu"
REPO_WEB="static-website"
REPO_K8S="k8s"
DIR_BASE="$HOME/proyecto-cloud"
DIR_WEB="$DIR_BASE/$REPO_WEB"
DIR_K8S="$DIR_BASE/$REPO_K8S"
URL_ORIGINAL_WEB="https://github.com/ewojjowe/static-website"

# ---- FUNCIONES ----

validar_dependencias() {
	for cmd in git gh; do
		if ! command -v "$cmd" &> /dev/null; then
			echo "Dependencia faltante: $cmd"
			exit 1
		fi
	done
}

hacer_fork_y_clonar() {
	echo "Haciendo fork del repositorio web..."
	gh repo fork "$URL_ORIGINAL_WEB" --clone --remote --org "$USUARIO_GITHUB" || true

	echo "Moviendo repositorio al directorio del proyecto..."
	mkdir -p "$DIR_BASE"
	mv "$REPO_WEB" "$DIR_WEB"
}

crear_directorios_k8s() {
	echo "Creando estructura de manifiestos..."
	mkdir -p "$DIR_K8S"/{namespaces, volumes, deployments, services}
}

generar_manifiestos() {
	echo "Generando manifiestos YAML..."

	cat <<EOF > "$DIR_K8S/namespaces/pagina-namespace.yaml"
apiVersion: v1
kind: Namespace
metadata:
	name: static-website
EOF

	cat <<EOF > "$DIR_K8S/volumes/pagina-volumen_persistente.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
	name: pagina-pv
spec:
	capacity:
		storage: 1Gi
	accessModes:
		- ReadWriteOnce
	persistentVolumeReclaimPolicy: Retain
	hostPath:
		path: /proyecto-cloud/static-website
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
	name: pagina-pvc
	namespace: static-website
spec:
	accessModes:
		- ReadWriteOnce
	volumeName: pagina-pv
	storageClassName: ""
	resources:
		requests:
			storage: 1Gi
EOF

	cat <<EOF > "$DIR_K8S/deployments/pagina-deployment.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
	name: pagina-web
	namespace: static-website
spec:
	replicas: 1
	selector:
		matchLabels:
			app: pagina-web
	template:
		metadata:
			labels:
				app: pagina-web
		spec:
			containers:
			- name: nginx
			  image: nginx:alpine
			  ports:
			  - containerPort: 80
			  volumeMounts:
			  - name: contenido-web
			  mountPath: /esr/share/nginx/html
			  readOnly: true
			volumes:
			- name: contenido-web
			  persistentVolumeClaim:
				claimName: pagina-pvc
EOF

	cat <<EOF > "$DIR_K8S/services/pagina-service.yaml"
apiVersion: v1
kind: Service
metadata:
	name: pagina-web-service
	namespace: static-website
spec:
	type: NodePort
	selector:
		app: pagina-web
	ports:
		- port: 80
		  targetPort: 80
		  nodePort: 30080
EOF
}

crear_repo_k8s_y_subirlo() {
	echo "Creando repositorio $REPO_K8S en github..."
	gh repo create "$USUARIO_GITHUB/$REPO_K8S" --public --source="$DIR_K8S" --remote=origin --push
}

# ---- EJECUCION ----

echo "Inicializando entorno del proyecto completo..."
validar_dependencias
hacer_fork_y_clonar
crear_directorios_k8s
generar_manifiestos
crear_repo_k8s_y_subirlo

echo "Todo listo. Proyecto creado en:"
echo "$DIR_BASE"
echo "https://github.com/$USUARIO_GITHUB/$REPO_K8S"
