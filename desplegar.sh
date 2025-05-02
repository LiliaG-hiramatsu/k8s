#!/bin/bash

# Script: desplegar.sh

# Descripción: Despliega un sitio web estático con NGINX en Kubernetes
#              usando una imagen personalizada de Docker (sin volumen montado).

# Requiere: kubectl, minikube, Linux

# Uso: ./desplegar.sh [--ayuda]

# Autor: Lilia Andrea García Hiramatsu

# ---- CONFIGURACIÓN ----

set -euo pipefail # Fail fast
IFS=$'\n\t' # Separador seguro

# Rutas
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROYECTO_DIR="$HOME/proyecto-cloud"
STATIC_DIR="$PROYECTO_DIR/static-website"
K8S_DIR="$PROYECTO_DIR/k8s"

# Archivos de manifiestos
NS_MANIFIESTO="$K8S_DIR/namespaces/pagina-namespace.yaml"
DEPLOY_MANIFIESTO="$K8S_DIR/deployments/pagina-deployment.yaml"
SERVICE_MANIFIESTO="$K8S_DIR/services/pagina-service.yaml"

NAMESPACE="static-website"
SERVICIO="pagina-web-service"

# ---- FUNCIONES ----

mostrar_ayuda() {
    echo "Uso: $0"
    echo "Automatiza el despliegue del sitio web estático en Kubernetes."
    echo
    echo "Opciones:"
    echo "  --ayuda     Muestra esta ayuda"
    exit 0
}

validar_dependencias() {
    echo "Validando dependencias..."
    for cmd in kubectl minikube docker; do
        if ! command -v "$cmd" > /dev/null; then
            echo "Error: '$cmd' no está instalado o no está en el PATH." >&2
            exit 1
        fi
    done
    echo "Dependencias validadas correctamente."
}

iniciar_minikube() {
    echo "Verificando si Minikube está corriendo..."
    if minikube status | grep -q "Running"; then
        echo "Minikube ya está iniciado."
    else
        echo "Iniciando Minikube con Docker..."
        minikube start --driver=docker
    fi

    if ! kubectl cluster-info > /dev/null 2>&1; then
        echo "Minikube no pudo levantar correctamente el clúster."
        echo "Recomendación: ejecutar 'minikube delete' y luego reiniciar."
        exit 1
    fi
}

crear_dockerfile() {
    local dockerfile_path="$STATIC_DIR/Dockerfile"

    if [[ -f "$dockerfile_path" ]]; then
        echo "Dockerfile ya existe en $dockerfile_path"
    else
        echo "Creando Dockerfile en $dockerfile_path..."
        cat <<EOF > "$dockerfile_path"
FROM nginx:alpine
COPY . /usr/share/nginx/html
EOF
    fi
}

construir_imagen() {
    echo "Construyendo imagen Docker personalizada..."
    docker build -t pagina-web-nginx "$STATIC_DIR"
    echo "Imagen construida: pagina-web-nginx"
}

crear_recursos_k8s() {
    echo "Desplegando recursos en Kubernetes..."

    echo "Aplicando namespace..."
    kubectl apply -f "$NS_MANIFIESTO"

    echo "Aplicando deployment..."
    kubectl apply -f "$DEPLOY_MANIFIESTO"

    echo "Aplicando service..."
    kubectl apply -f "$SERVICE_MANIFIESTO"
}

verificar_pod() {
    echo "Esperando a que el pod esté en estado 'Running'..."
    while true; do
        estado=$(kubectl get pods -n "$NAMESPACE" --no-headers | awk '{print $3}')
        if [[ "$estado" == "Running" ]]; then
            echo "El pod está corriendo correctamente."
            break
        fi
        echo "Aún no está listo... esperando 3 segundos"
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
iniciar_minikube
crear_dockerfile
construir_imagen
crear_recursos_k8s
verificar_pod
abrir_servicio