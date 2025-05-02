#!/bin/bash

# Script: limpiar.sh

# Descripcion: Elimina los recursos de Kubernetes creados por el despliegue
# del sitio web estatico. Tambien detiene minikube.

# Uso: ./limpiar.sh [--ayuda]

# Autor: Lilia Andrea Garcia Hiramatsu


# ---- CONFIGURACION ----

set -euo pipefail # Fail fast
IFS=$'\n\t' # Separador seguro

# Rutas base
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROYECTO_DIR="$BASE_DIR/proyecto-cloud"
K8S_DIR="$PROYECTO_DIR/k8s"

# Nombre de recursos
NAMESPACE="static-website"
DEPLOYMENT="pagina-web"
SERVICE="pagina-web-service"

# ---- FUNCIONES ----

mostrar_ayuda() {
	echo "Uso: $0"
	echo "Elimina los recursos del despliegue del sitio web estatico en Kubernetes."
	echo
	echo "Opciones:"
	echo " --ayuda	Muestra esta ayuda"
	exit 0
}

validar_dependencias() {
	echo "Validando dependencias..."
	for cmd in kubectl minikube; do
		if ! command -v "$cmd" > /dev/null; then
			echo "Error: '$cmd' no esta instalado o no esta en el PATH." >&2
			exit 1
		fi
	done
	echo "Dependencias validadas."
}

eliminar_recursos_k8s() {
	echo "Eliminando recursos de Kubernetes..."

	echo "Eliminando deployment..."
	kubectl delete deployment "$DEPLOYMENT" -n "$NAMESPACE" --ignore-not-found

	echo "Eliminando service..."
	kubectl delete service "$SERVICE" -n "$NAMESPACE" --ignore-not-found

	echo "Eliminando namespace..."
	kubectl delete namespace "$NAMESPACE" --ignore-not-found
}

detener_minikube() {
	echo "Deteniendo minikube..."
	minikube stop
}

# ---- PROGRAMA PRINCIPAL ----

# Parseo de argumentos
if [[ "${1:-}" == "--ayuda" ]]; then
	mostrar_ayuda
fi

validar_dependencias
eliminar_recursos_k8s
detener_minikube

echo "Limpieza completada."
