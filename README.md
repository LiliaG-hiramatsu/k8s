# Sitio Web Estático con Kubernetes

El proyecto automatiza el despliegue con scripts de Bash de un sitio web estático usando una imagen Docker personalizada con NGINX en Kubernetes, sin necesidad de volúmenes ni montajes externos.

---

## 🧰 Requisitos

* Ubuntu, WSL o entorno Linux
* `minikube` y `kubectl` instalados y configurados
* `gh` (GitHub CLI) autenticado (`gh auth login`)
* Git configurado

---

## 🚀 Iniciar

Se crea el script principal `setup.sh` que gestiona todo el proyecto. Este script lo que hace es descargar los scripts `inicializar_proyecto.sh`, `desplegar.sh` y `limpiar.sh` desde mi repositorio de github (o el que se especifique en la variable REPO_BASE) y los deja listos para ejecutarlos de a uno.
Esto se lleva a cabo con el comando

`wget -q -O - https://kutt.it/proyecto-k8s | bash`

Este comando:
- Usa wget para descargar el script desde una URL corta (se crea con https://kutt.it y la URL RAW del archivo)
- Con -q -O -:
    - -q: modo silencioso
    - -O -: guarda la salida en stdout
- Con | bash lo ejecuta directamente como un script Bash

### 1. `inicializar_proyecto.sh`

Ejecutamos el primer script:

`./inicializar_proyecto.sh`

Automatiza la preparación completa del entorno:

- Hace fork del repositorio web estático `ewojjowe/static-website`
- Lo clona localmente en `proyecto-cloud/static-website/`
- Crea la estructura de carpetas `k8s/namespaces` `k8s/deployments` `k8s/services`
- Genera los manifiestos YAML preconfigurados
- Crea y sube el repositorio `k8s` a mi cuenta de GitHub (o la que se especifique en la variable USUARIO_GITHUB)

### 2. `desplegar.sh`

Ejecutamos el segundo script:

`./desplegar.sh`

Realiza el despliegue en Kubernetes usando los manifiestos creados:

* Inicia Minikube
* Crea un Dockerfile
* Contruye la imagen de Docker
* Aplica namespace, deployment y service
* Verifica el estado del pod
* Abre el sitio web en el navegador

### 3. `limpiar.sh`

Ejecutamos el tercer script:

`./limpiar.sh`

Limpia todos los recursos creados:

* Elimina el Deployment, Service y Namespace
* Detiene Minikube

---

## ✍️ Autor

- Lilia Andrea García Hiramatsu
- Computación en la Nube - Desarrollo de Software
- Año: 2025
