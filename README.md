# Sitio Web Estático con Kubernetes

Este proyecto despliega un sitio web estático utilizando un contenedor NGINX en un clúster de Kubernetes. Todos los pasos se automatizan mediante scripts Bash.

---

## 📁 Estructura


- proyecto-cloud/
    - static-website/
    - k8s/

📦 Este proyecto crea automáticamente los directorios `proyecto-cloud/`, `static-website/` y `k8s/` al ejecutar el script `inicializar_proyecto.sh`.

---

## 🧰 Requisitos

* Ubuntu, WSL o entorno Linux
* `minikube` y `kubectl` instalados y configurados
* `gh` (GitHub CLI) autenticado (`gh auth login`)
* Git configurado

---

## 🚀 Scripts disponibles

### 1. `inicializar_proyecto.sh`

Automatiza la preparación completa del entorno:

- Hace fork del repositorio web estático `ewojjowe/static-website`
- Lo clona localmente en `proyecto-cloud/static-website/`
- Crea la estructura de carpetas `k8s/{namespaces,volumes,deployments,services}`
- Genera los manifiestos YAML preconfigurados
- Crea y sube el repositorio `k8s` a mi cuenta de GitHub (o la que se especifique en la variable USUARIO_GITHUB)

📌 **Ejecutar una sola vez al inicio:**

```bash
chmod +x inicializar_proyecto.sh
./inicializar_proyecto.sh
````

---

### 2. `desplegar.sh`

Realiza el despliegue en Kubernetes usando los manifiestos creados:

* Inicia Minikube
* Solicita montar el contenido estático como volumen
* Aplica namespace, volumen, deployment y service
* Verifica el pod
* Abre el sitio web en el navegador

📌 **Ejecutar luego de inicializar el proyecto:**

```bash
chmod +x desplegar.sh
./desplegar.sh
```

---

### 3. `limpiar.sh`

Limpia todos los recursos creados:

* Elimina el Deployment, Service, PVC, PV y Namespace
* Detiene Minikube

📌 **Ejecutar cuando desees eliminar el entorno:**

```bash
chmod +x limpiar.sh
./limpiar.sh
```

---


## ✍️ Autor

- Lilia Andrea García Hiramatsu
- Computación en la Nube - Desarrollo de Software
- Año: 2025