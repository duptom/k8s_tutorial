![K8s Logo](https://lucasvidelaine.files.wordpress.com/2018/01/kubernetes3.png?w=250)

# Tutoriel d'installation de Kubernetes (K8s)

Le tutoriel a été effectué sur des VM Hyper-V sur lesquelles Ubuntu 18.04 Server a été installé. Toutes les instructions d'appliquent donc pour un système d'exploitation Linux.

À des fins de références, il est possible de consulter le [glossaire de Kubernetes](https://kubernetes.io/docs/reference/glossary/?fundamental=true).

## Activer la virtualisation sur une VM Hyper_V
Si vous utilisez Hyper-V et que la virtualisation n'est pas activée sur votre VM, vous pouvez effectuer la commande suivante sur la VM fermée:

```PowerShell
Set-VMProcessor -VMName <NomDeLaVM> -ExposeVirtualizationExtensions $true
```

## [**Cluster, Pod**] Lancer le premier script d'installation
	wget -O - https://raw.githubusercontent.com/duptom/k8s_tutorial/master/1-install.sh | sudo bash



## [**Cluster, Pod**] Ajouter l'accès à l'utilisateur à microk8s et docker
	sudo usermod -a -G microk8s <utilisateur_actuel>
	sudo usermod -aG docker <utilisateur_actuel>

## **[**Cluster, Pod**]** Redémarrer pour appliquer la sécurité
	sudo shutdown -r now

## [**Cluster**] Générer la chaîne de connexion pour les pods
	microk8s.add-node
Le résultat de cette commande devrait ressembler à cela:
	
	Join node with: microk8s.join ip-172-31-20-243:25000/DDOkUupkmaBezNnMheTBqFYHLWINGDbf

	If the node you are adding is not reachable through the default
	interface you can use one of the following:

	microk8s.join 10.1.84.0:25000/DDOkUupkmaBezNnMheTBqFYHLWINGDbf
	microk8s.join 10.22.254.77:25000/DDOkUupkmaBezNnMheTBqFYHLWINGDbf

# [**Pods**] Connecter une pod au cluster
Utiliser la commande spécifiée plus haut dans le résultat de la commande «*microk8s.add-node*» exécutée sur le cluster.

	microk8s.join ip-172-31-20-243:25000/DDOkUupkmaBezNnMheTBqFYHLWINGDbf

# Configurer un déploiement dans Kubernetes
	microk8s.kubectl apply -f <emplacement_fichier_configuration>

# Supprimer un déploiement
	microk8s.kubectl delete -n default deployment <nom_du_deploiement>

# *Commandes supplémentaires*
## Afficher le status de microk8s:
	microk8s.status --wait-ready

## Lancer le dashboard (si besoin):
Ajouter un '&' à la fin de la commande pour lancer le dashboard en arrière-plan.
On peut seulement se connecter sur le dashboard web sur l'ordinateur local.

	microk8s.kubectl proxy

Lien pour accéder au dashboard local:

	http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/