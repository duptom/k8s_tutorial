![K8s Logo](https://lucasvidelaine.files.wordpress.com/2018/01/kubernetes3.png?w=250)

# Tutoriel d'installation de Kubernetes (K8s)

Le tutoriel a été effectué sur des VM Hyper-V sur lesquelles Ubuntu 18.04 Server a été installé. Toutes les instructions d'appliquent donc pour un système d'exploitation Linux.

À des fins de références, il est possible de consulter le [glossaire de Kubernetes](https://kubernetes.io/docs/reference/glossary/?fundamental=true).

## Virtualisation
---
Valider que le système prend en charge la virtualisation (la sortie de la commande ne doit pas être vide):

	egrep --color 'vmx|svm' /proc/cpuinfo

Si on a pas de résultat avec la dernière commande, **on doit installer KVM**.
## Installer KVM (Kernel Based Virtual Machine)
---
Commande d'installation:

	sudo apt-get install qemu-kvm libvirt-bin virtinst bridge-utils cpu-checker

Valider que l'installation est correcte:

	kvm-ok

Le retour supposé de la dernière commande si l'installation s'est bien déroulée:

	INFO: /dev/kvm exists
	KVM acceleration can be used

Si vous utilisez Hyper-V et que la virtualisation n'est pas activée sur votre VM, vous pouvez effectuer la commande suivante sur la VM fermée:

```PowerShell
Set-VMProcessor -VMName <NomDeLaVM> -ExposeVirtualizationExtensions $true
```

Revalider que le système prend en charge la virtualisation (la sortie ne doit pas être vide):

	egrep --color 'vmx|svm' /proc/cpuinfo

## [Installer kubectl](https://kubernetes.io/fr/docs/tasks/tools/install-kubectl/)
---
Commandes d'installation:

	curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

	chmod +x ./kubectl

	sudo mv ./kubectl /usr/local/bin/kubectl

Valider la version de kubectl:
	
	kubectl version

## [Installer minikube](https://kubernetes.io/fr/docs/tasks/tools/install-minikube/)
---
Commande d'installation: 

	curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube

Ajouter minikube au path: 
	
	sudo cp minikube /usr/local/bin && rm minikube

Démarrer minikube:

	minikube start

## Installer Docker
---
Commande d'installation:

	sudo apt install docker.io

Valider l'installation:

	docker --version

Activer Docker:

	sudo systemctl enable docker

## [Installer kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
---
Commandes d'installation:

	sudo apt-get update && sudo apt-get install -y apt-transport-https curl
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
	cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
	deb https://apt.kubernetes.io/ kubernetes-xenial main
	EOF
	sudo apt-get update
	sudo apt-get install -y kubelet kubeadm kubectl
	sudo apt-mark hold kubelet kubeadm kubectl



## [Installer le GUI de Kubernetes](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
---
Commande d'installation:

	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta4/aio/deploy/recommended.yaml

Commande de démarrage:

	kubectl proxy

## Installer un CNI (container network interface)
Commandes d'installation pour Calico:

	kubectl apply -f https://docs.projectcalico.org/v3.10/manifests/calico.yaml

## Déployer Kubernetes
---
Commandes:

	sudo swapoff -a
	sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=<Adresse_IP_Du_Serveur>

Configuration initiale de Kubernetes s'il n'y a pas eu d'erreur avec les commandes précédentes:

	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config

## Configurer un compte de service pour accéder au GUI
---
Créer le compte:

	kubectl create serviceaccount dashboard -n default

Attribuer les rôles au comptes nouvellement créé:

	kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboard

Obtenir le token de première connexion du compte:

	kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode


To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.1.31:6443 --token i88nvj.ejcc7ygqrcv5xxsm \
    --discovery-token-ca-cert-hash sha256:a432c794936a6207d807a34c9b62cdaf03417022796567995784232858ce66f7 

kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode

sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=192.168.1.31

sudo swapoff -a
