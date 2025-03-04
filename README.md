# 🚀 Deploy Nextcloud on OpenShift

This guide provides step-by-step instructions to deploy Nextcloud on an OpenShift cluster.

## **📌 Prerequisites**
Before you begin, ensure you have:
- Access to an **OpenShift** cluster (`oc` or `kubectl` CLI installed)
- A **Quay.io** account with a **Nextcloud container image** (`quay.io/<your_quay_user>/nextcloud:latest`) You can use (`quay.io/ryan_nix/nextcloud:latest`) as an example or build your own with the Dockerfile provided in this repo.
- You have enough quota within OpenShift to deploy a PostgreSQL database. i.e., `oc describe resourcequotas -n <namespace>`

---

## **🔧 Step 1: Update Deployment Variables**
Modify the **`nextcloud-deployment.yaml`** file:

### **📝 Required Changes**
| Variable | Description | Location |
|----------|------------|----------|
| `<your_quay_user>` | Your **Quay.io username** where the Nextcloud image is stored | `image: quay.io/<your_quay_user>/nextcloud:latest` |
| `<your-password-here>` | Secure **PostgreSQL password** (do NOT store plaintext in GitHub) | `nextcloud-db-secret` |
| `nextcloud.example.com` | **Public domain** or **IP address** for your Nextcloud instance | `trusted_domains` and `overwrite.cli.url` in **ConfigMap** |

- If you haven’t built and pushed the Nextcloud container yet, run:
podman build -t quay.io/<your_quay_user>/nextcloud:latest .
podman push quay.io/<your_quay_user>/nextcloud:latest

- Now, create the PostgreSQL secret and apply all required Kubernetes resources:

`kubectl create secret generic nextcloud-db-secret \`
`  --from-literal=db-user=nextcloud \`
`  --from-literal=db-password='your-secure-password'`

`kubectl apply -f nextcloud-pvc.yaml`
`kubectl apply -f nextcloud-deployment.yaml`
`kubectl apply -f nextcloud-db.yaml`

- To expose Nextcloud externally via OpenShift Routes:
`oc expose svc nextcloud --hostname=nextcloud.example.com`

- Restart Nextcloud to apply all changes:
`kubectl rollout restart deployment nextcloud`

### **📝 Required Changes**
- Check that the Nextcloud and PostgreSQL pods are running:
`kubectl get pods`
|----------|------------|----------|
| NAME                            | READY |  | STATUS  |    | RESTARTS  |  AGE |
| nextcloud-xxxx-yyyy             | 1/1   |  | Running |   | 0         |  5m  |
| nextcloud-db-xxxx-yyyy          | 1/1   |  | Running |   | 0         |  5m  |

- For security, move the Nextcloud /data/ directory to persistent storage. Modify config.php inside the running Nextcloud pod:

`kubectl exec -it $(kubectl get pods -l app=nextcloud -o jsonpath="{.items[0].metadata.name}") -- sh -c "echo \"'datadirectory' => '/var/www/data',\" >> /var/www/html/config/config.php"`

- Confirm that data is being stored in the persistent volume:
`kubectl exec -it $(kubectl get pods -l app=nextcloud -o jsonpath="{.items[0].metadata.name}") -- ls -l /var/www/data`

- After deployment, check if your namespace still has available resources:
`oc describe resourcequotas -n <namespace>`

- Finally, access Nextcloud via the OpenShift Route URL:
`https://nextcloud.example.com`




