#!/bin/bash

#################################################################
# Script: desplegar.sh

# Descripción: Automatiza el despliegue de un sitio web estático
# con NGNX en Kubernetes usando manifiestos y un volumen
# persistente.

# Requiere: kubectl, minikube, Linux

# Uso: ./desplegar.sh [--ayuda]

# Autor: Lilia Andrea García Hiramatsu

################################################################

# ---- CONFIGURACIÓN ----

set -euo pipefail # Fail fast
IFS=$'\N\T' # Separador seguro

# Rutas
BASE_DIR="$(cd "$(dirname "${BASE_SOURCE[0]}")" && pwd"
PROYECTO_DIR="$BASE_DIR/proyecto-cloud"
STATIC_DIR="$PROYECTO_DIR/static-website"
K8S_DIR="$PROYECTO_DIR/k8s"

# Archivos de manifiestos
NS_MANIFIESTO="$K8S_DIR/namespaces/pagina-namespace.yaml"
PV_MANIFIESTO="$K8S_DIR/volumes/pagina-volumen_persistente.yaml"
DEPLOY_MANIFIESTO="$K8S_DIR/deployments/pagina-deployment.yaml"
SERVICE_MANIFIESTO="$K8S_DIR/services/pagina-service.yaml"

NAMESPACE="static-website"
SERVICIO="pagina-web-service"

# ---- FUNCIONES ----

mostrar_ayuda() {
	echo "Uso: $0"
	echo "Automatiza el despliegue del sitio web estatico en Kubernetes."
	echo
	echo "Opciones:"
	echo " --ayuda	Muestra esta ayuda"
	exit 0
}

validar_dependencias() {
	echo "Validando dependencias..."
	for cmd in kubctl minikube; do
		if ! command -v "$cmd" > /dev/null; then
			echo "Error: 'cmd' no esta instalado o no esta en el PATH." >&2
			exit 1
		fi
	done
	echo "Dependencias validadas."
}

montar_directorio() {
	echo "Asegurate de montar el directorio estatico en otra terminal con:"
	echo "minikube mount \"$STATIC_DIR:/proyecto-cloud/static-website\""
	echo "Deja la terminal del mount abierta durante todo el despliegue."
	read -p "Presiona [Enter] cuando hayas montado el directorio..."
}

crear_recursos_k8s() {
	echo "Desplegando recursos en Kubernetes..."

	echo "Aplicando namespace..."
	kubectl apply -f "$NS_MANIFIESTO"

	echo "Aplicando volumen persistente..."
	kubectl apply -f "PV_MANIFIESTO"

	echo "Verificando estado del PVC..."
	kubectl get pvc -n "$NAMESPACE"

	echo "Aplicando deployment..."
	kubectl apply -f "$DEPLOY_MANIFIESTO"

	echo "Aplicando service..."
	kubectl apply -f "$SERVICE_MANIFIESTO"
}

verificar_pod() {
	echo "Esperando a que el pod este en estado 'Running'..."

	while true; do
		estado=$(kubectl get pods -n "$NAMESPACE" --no-headers | awk '{print $3}')
		if [[ "$estado" == "Running" ]]; then
			echo "El pod esta corriendo correctamente."
			break
		fi
		echo "Aun no esta listo... esperando 3 segundos"
		sleep 3
	done

	echo
	echo "Estado del pod:"
	kubectl get pods -n "$NAMESPACE"
}

abrir_servicio() {
	echo "Abriendo el sitio web..."
	minikube service "$SERVICIO" -n "$NAMESPACE"
}

# ---- PROGRAMA PRINCIPAL ----

# Parseo de argumentos
if [[ "${1:-}" == "--ayuda" ]]; then
	mostrar_ayuda
fi

validar_dependencias

echo "Iniciando minikube (si no esta corriendo)..."
minikube start

montar_directorio
crear_recursos_k8s
verificar_pod
abrir_servicio
