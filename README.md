# 🚀 Deploy Nextcloud on OpenShift

This guide provides step-by-step instructions to deploy Nextcloud on an OpenShift cluster.

## **📌 Prerequisites**
Before you begin, ensure you have:
- Access to an **OpenShift** cluster (`oc` or `kubectl` CLI installed)
- A **Quay.io** account with a **Nextcloud container image** (`quay.io/<your_quay_user>/nextcloud:latest`)
- A PostgreSQL database for Nextcloud

---

## **🔧 Step 1: Update Deployment Variables**
Modify the **`nextcloud-deployment.yaml`** file:

### **📝 Required Changes**
| Variable | Description | Location |
|----------|------------|----------|
| `<your_quay_user>` | Your **Quay.io username** where the Nextcloud image is stored | `image: quay.io/<your_quay_user>/nextcloud:latest` |
| `<your-password-here>` | Secure **PostgreSQL password** (do NOT store plaintext in GitHub) | `nextcloud-db-secret` |
| `nextcloud.example.com` | **Public domain** or **IP address** for your Nextcloud instance | `trusted_domains` and `overwrite.cli.url` in **ConfigMap** |

🔹 If you haven't built and pushed the Nextcloud container yet, follow:
```sh
podman build -t quay.io/<your_quay_user>/nextcloud:latest .
podman push quay.io/<your_quay_user>/nextcloud:latest