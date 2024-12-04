---
runme:
  id: 01JDMZ1BTQXH9M03YKJ7CJAZ7R
  version: v3
---

# Ubuntu Terminal with Kubernetes, Docker, and NFS Setup

This project sets up a GoTTY-based terminal application using Docker, Kubernetes, and NFS for persistent storage. Below are the detailed steps to build the Docker image, set up Kubernetes using RKE2, configure NFS, and deploy the application.

## Project Structure

```
sec-labs/
├── Dockerfile
├── manifest
│   ├── deployment.yaml
│   ├── ingress.yaml
│   └── pvc.yaml
└── README.md
```

- **Dockerfile**: Contains the configuration to build the Docker image for GoTTY terminal.
- **manifest/**: Contains Kubernetes deployment, ingress, and persistent volume claim YAML files.
- **README.md**: This file with instructions to set up the environment and deploy the application.

## Prerequisites

Before starting, ensure that you have the following tools installed:

- **Docker**: To build and run Docker containers.
- **Kubernetes** (with RKE2 for the cluster setup).
- **kubectl**: To interact with your Kubernetes cluster.
- **NFS Server**: For persistent volume (PV) storage.
- **GitHub Actions**: For automating Docker image builds and deployments.

### 1. Install Docker

1. Update the package database and install dependencies:

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
```

2. Add Docker's official GPG key and repository:

```bash
curl -fsSL https://get.docker.com | bash
```

3. Start Docker and enable it to start on boot:

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

4. Add your user to the Docker group:

```bash
sudo usermod -aG docker $USER
```

5. Verify Docker installation:

```bash
docker --version
```

### 2. Set up Kubernetes using RKE2

1. **Install RKE2**:

```bash
curl -sfL https://get.rke2.io | sh -
```

2. **Start the RKE2 server**:

```bash
sudo systemctl enable rke2-server.service
sudo systemctl start rke2-server.service
```

3. **Set up kubectl**:

```bash
export KUBEVIRT_VERSION=v0.49.0
export KUBEVIRT_KUBEVIRT_VERSION=v0.49.0
sudo ln -s /usr/local/bin/kubectl /usr/local/bin/kubevirt
```

4. **Check your Kubernetes nodes**:

```bash
kubectl get node
```

### 3. Build the Docker Image

1. Clone the repository containing the Dockerfile and Kubernetes manifests.

2. **Build the Docker image**:

```bash
docker build -t your_dockerhub_username/sec-labs:v1.1 .
```

3. **Push the Docker image** to Docker Hub:

```bash
docker push your_dockerhub_username/sec-labs:v1.1
```

### 4. Set up the ConfigMap

The ConfigMap is used to pass environment variables to your pods. Here, we set the `GOTTY_USER` environment variable, which is used to create the terminal user.

1. **Create the ConfigMap**:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: gotty-config
  namespace: sec
data:
  GOTTY_USER: "appuser"
```

2. Apply the ConfigMap:

```bash
kubectl apply -f gotty-configmap.yaml
```

### 5. Set up NFS for Persistent Storage

1. **Install NFS Server on your system**:

```bash
sudo apt-get update
sudo apt-get install -y nfs-kernel-server
```

2. **Create the NFS export directory**:

```bash
sudo mkdir -p /mnt/nfs_share
sudo chmod 777 /mnt/nfs_share
```

3. **Export the directory**:

Edit `/etc/exports` and add the following line:

```bash
/mnt/nfs_share  *(rw,sync,no_subtree_check)
```

4. **Restart the NFS server**:

```bash
sudo systemctl restart nfs-kernel-server
```

### 6. Create PersistentVolume and PersistentVolumeClaim

Ensure that your PV is set up to use NFS. Here's an example for both PV and PVC configurations:

```yaml
# PersistentVolume configuration (nfs-pv.yaml)
apiVersion: v1
kind: PersistentVolume
metadata:
  name: user-data
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /mnt/nfs_share    # Path on the NFS server
    server: 10.0.0.44  # Replace with your NFS server IP
```

```yaml
# PersistentVolumeClaim configuration (nfs-pvc.yaml)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: user-session-pvc
  namespace: sec
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
```

Apply the PV and PVC:

```bash
kubectl apply -f nfs-pv.yaml
kubectl apply -f nfs-pvc.yaml
```

### 7. Create Kubernetes Resources

1. **Deployment** (`manifest/deployment.yaml`):

Ensure that your deployment is using the persistent volume claim (`user-session-pvc`) and `ConfigMap` for the user configuration.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gotty-terminal
  namespace: sec
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gotty-terminal
  template:
    metadata:
      labels:
        app: gotty-terminal
    spec:
      containers:
      - name: gotty-terminal
        image: your_dockerhub_username/sec-labs:v1.1
        ports:
        - containerPort: 8080
        envFrom:
        - configMapRef:
            name: gotty-config
        volumeMounts:
        - mountPath: /user_sessions
          name: session-storage
        - mountPath: /etc/sudoers.d
          name: sudoers-volume
      volumes:
      - name: session-storage
        persistentVolumeClaim:
          claimName: user-session-pvc
      - name: sudoers-volume
        emptyDir: {}
```

2. **Service** (`manifest/service.yaml`):

```yaml
apiVersion: v1
kind: Service
metadata:
  name: gotty-terminal-service
  namespace: sec
spec:
  selector:
    app: gotty-terminal
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
  type: ClusterIP
```

3. **Ingress** (`manifest/ingress.yaml`):

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: gotty-ingress
  namespace: sec
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: localhost  # Or your external IP or domain
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: gotty-terminal-service
            port:
              number: 8080
```

Apply all Kubernetes manifests:

```bash
kubectl apply -f manifest/deployment.yaml
kubectl apply -f manifest/service.yaml
kubectl apply -f manifest/ingress.yaml
```

### 8. Perform Rolling Updates

To perform a rolling update for your deployment:

1. **Update the Docker image** or configuration.
2. **Apply the update**:

```bash
kubectl set image deployment/gotty-terminal gotty-terminal=your_dockerhub_username/sec-labs:v1.2 --record
```

This will trigger a rolling update and replace old pods with the new ones.

### 9. Set up GitHub Actions

To automate the Docker image build and push process, use GitHub Actions:

Create a `.github/workflows/docker-image.yml` file:

```yaml
name: Build and Push Docker Image

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Log in to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build Docker Image
        run: docker build -t ${{ secrets.DOCKER_USERNAME }}/sec-labs:v1.1 .

      - name: Push Docker Image
        run: docker push ${{ secrets.DOCKER_USERNAME }}/sec-labs:v1.1
```

Ensure that your Docker Hub credentials are set up in GitHub Secrets (`DOCKER_USERNAME` and `DOCKER_PASSWORD`).
