# Sitio web estático con Kubernetes

Este proyecto despliega un sitio web estático utilizando un contenedor NGINX en un clúster de Kubernetes. Los archivos HTML se montan desde un volumen persistente  (`PersistentVolume`) para asegurar la persistencia del contenido.

## 🧱 Estructura del Proyecto

El proyecto está organizado de la siguiente manera:

- `proyecto-cloud/`
  - `k8s/`: Contiene todos los manifiestos de Kubernetes organizados en subdirectorios.
    - `namespaces/`
      - `pagina-namespace.yaml`: Define el namespace `static-website`.
    - `volumes/`
      - `pagina-volumen_persistente.yaml`: Define el PersistentVolume y el PersistentVolumeClaim.
    - `deployments/`
      - `pagina-deployment.yaml`: Define el Deployment del pod que ejecuta el sitio web.
    - `services/`
      - `pagina-service.yaml`: Define el servicio que expone el sitio web mediante un `NodePort`.
    - `README.md`: Documentación del proyecto.

## ⚙️ Requisitos

- Kubernetes (probado en Docker Desktop y Minikube)
- `kubectl` instalado y configurado
- Carpeta local con contenido web: `/proyecto-cloud/static-website`

## 🚀 Despliegue

1. **Iniciar minikube**

minikube start

1. **Crear el Namespace**

En el directorio namespaces creé el manifiesto para crear el namespace. El archivo se llama "pagina-namespace.yaml" y el namespace se llama "static-website".

kubectl apply -f k8s/namespaces/pagina-namespace.yaml

Para comprobar que se creó correctamente:

kubectl get namespaces

2. **Crear el manifiesto del volumen persistente y la claim**

En el directorio volumes creé el manifiesto para el volumen persistente y la claim, el archivo se llama pagina-volumen_persistente.yaml

Antes de aplicar el manifiesto, montar el directorio local con minikube:

Para Windows desde el cmd:

minikube mount C:\proyecto-cloud\static-website:/proyecto-cloud/static-website

(Si lo hacía desde git bash, no funcionaba porque instalé minikube desde el cmd).

Sino para Linux:

minikube mount ~/proyecto-cloud/static-website:/proyecto-cloud/static-website

Esta ventana debe quedar abierta!

En otro cmd o terminal, aplicar el manifiesto creado anteriormente con:

kubectl apply -f k8s/volumes/pagina-volumen_persistente.yaml

Aquí verificar que el pvc y el pv estén en estado "bound" con el comando:

kubectl get pvc -n static-website

3. **Crear el manifiesto deployment y service**

Dentro del directorio k8s creé los directorios "deployments" y "services", en los cuales, dentro de cada uno, creé los manifiestos correspondientes, llamados pagina-deployment.yaml y pagina-service.yaml respectivamente.
El servicio se llama pagina-web-service.

### Desplegar el contenedor NGINX

kubectl apply -f k8s/deployments/pagina-deployment.yaml

### Exponer el servicio por NodePort

kubectl apply -f k8s/services/pagina-service.yaml

4. **Acceder al sitio web**

Antes verificar el estado del pod:
kubectl get pods -n static-website
Debe estar READY: 1/1 y STATUS: Running 

minikube service pagina-web-service -n static-website

Se abrirá la página web estática en el navegador.
Sino, escribí en el navegador:
http://localhost:30080

## 📂 Archivos Clave

* pagina-volumen_persistente.yaml: definde un volumen persistente con hostPath y su claim.
* pagina-deployment.yaml: despliega un pod con imagen nginx:alpine y monta el volumen.
* pagina-service.yaml: expone el pod mediante NodePort.

## 🧽 Limpieza

Para eliminar los recursos creados:

kubctl delete -f k8s/ --recursive

## 💬 Notas

Asegurarse de que la ruta del hostPath del volumetn exista en el nodo antes de aplicar el manifiesto.
El archivo html debe estar dentro de /proyecto-cloud/static-website antes de iniciar el despliegue.

## ✍️ Autor

Lilia Andrea García Hiramatsu
Mini proyecto para la asignatura Computación en la Nube.