#!/bin/bash

# Script: setup.sh
# Descripción: Descarga y da permisos a los scripts principales del proyecto:
#              - inicializar_proyecto.sh
#              - desplegar.sh
#              - limpiar.sh
# Uso: wget -q -O - https://kutt.it/proyecto-k8s | bash

set -euo pipefail
IFS=$'\n\t'

REPO_BASE="https://raw.githubusercontent.com/LiliaG-hiramatsu/k8s/main"
SCRIPTS=("inicializar_proyecto.sh" "desplegar.sh" "limpiar.sh")

echo "Iniciando setup del proyecto..."

for script in "${SCRIPTS[@]}"; do
    echo "Descargando $script..."
    wget -q "$REPO_BASE/$script" -O "$script"
    chmod +x "$script"
done

echo
echo "Todos los scripts fueron descargados correctamente."
echo "Ahora podés ejecutar:"
echo "  ./inicializar_proyecto.sh"
echo "  ./desplegar.sh"
echo "  ./limpiar.sh"
