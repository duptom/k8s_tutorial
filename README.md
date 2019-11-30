![K8s Logo](https://lucasvidelaine.files.wordpress.com/2018/01/kubernetes3.png?w=250)

# Présentation de *Kubernetes* (K8s)
*Kubernetes* est un logiciel permettant l'orchestration complète de conteneurs. Grâce à *Kubernetes*, il est facile d'augmenter la puissance qu'on veut occtroyer à nos différentes applications: il suffit de demander à ce que *Kubernetes* ajouter plus de conteneurs de cette application (par exemple).

La conteneurisation, elle, est un type de virtualisation, mais beaucoup plus légèrte qu'une virtualisation comprennant un système d'exploitation complet. On pourrait plutôt appeler la conteneurisation comme l'isolement de l'exécution de nos applications. Cette capacité de conteneurisation nous est apportée par *Docker*.

## *Docker* et *Kubernetes*

![Kubernetes et Docker](https://i1.wp.com/www.docker.com/blog/wp-content/uploads/2019/10/Docker-Kubernetes-together.png?resize=1110%2C624&ssl=1)

# Tutoriel d'installation de *Kubernetes* (K8s)
Le but de ce tutoriel est de procéder à l'installation de *Kubernetes* et de *Docker* et d'être en mesure de déployer des applications à travers l'architecture de ces deux logiciels. Après le tutoriel, vous serez donc en mesure de préparer vous-même votre propre image *Docker* et de la déployer via *Kubernetes* afin d'avoir la meilleure gestion de charge de travail qui existe sur le marché. Vous aurez à votre disposition toutes les commandes essentielles pour visualiser et gérer de manière simple vos déploiements.

Le tutoriel a été effectué sur des VM Hyper-V sur lesquelles Ubuntu 18.04 Server a été installé. Toutes les instructions d'appliquent donc pour un système d'exploitation Linux (*Ubuntu Server 18.04.3 LTS (Bionic Beaver)*).

À des fins de références, il est possible de consulter le [glossaire de *Kubernetes*](https://kubernetes.io/docs/reference/glossary/?fundamental=true).

Certaines étapes d'installation spécifient s'il faut faire l'action sur le *Cluster* principal et/ou sur les *Nodes*.

## Activer la virtualisation sur une VM

### Hyper-V
Si vous utilisez Hyper-V et que la virtualisation n'est pas activée sur votre VM, vous pouvez effectuer la commande suivante sur la VM fermée:

```PowerShell
Set-VMProcessor -VMName <NomDeLaVM> -ExposeVirtualizationExtensions $true
```
### Virtual Box
Si vous ne pouvez pas activer Hyper-V, vous pouvez utiliser l'hyperviseur [VirtualBox](https://www.virtualbox.org/wiki/Downloads) d'Oracle

## [**Cluster, Nodes**]
Mettre à jour le système pour qu'il n'y ait pas de mise à jour en attente:
	
	sudo apt upgrade

## [**Cluster, Nodes**] Installation de microk8s
Microk8s est une distribution de *Kubernetes* facile d'utilisation avec tous les outils pré installés et configurés. Pour l'installer, simplement lancer cette commande (attendre la fin de la commande):

	sudo apt install snapd | sudo snap install microk8s --classic --channel=1.16/stable

Ensuite on doit installer *Docker*:

	sudo apt install docker.io

Il faut ajouter l'accès à l'utilisateur à microk8s et *Docker* sinon on doit toujours lancer les commande avec *sudo*.

	sudo usermod -a -G microk8s <utilisateur_actuel>
	sudo usermod -aG docker <utilisateur_actuel>

Ensuite, on doit redémarrer pour appliquer la sécurité

	sudo shutdown -r now

Afficher le status de microk8s et la version de *Docker* suite à l'installation:

	microk8s.status --wait-ready
	docker -v

## [**Cluster**] Générer la chaîne de connexion pour les *Nodes* (optionnel)
	microk8s.add-node
Le résultat de la commande précédente devrait ressembler à cela:
	
	Join node with: microk8s.join ip-172-31-20-243:25000/DDOkUupkmaBezNnMheTBqFYHLWINGDbf

	If the node you are adding is not reachable through the default
	interface you can use one of the following:

	microk8s.join 10.1.84.0:25000/DDOkUupkmaBezNnMheTBqFYHLWINGDbf
	microk8s.join 10.22.254.77:25000/DDOkUupkmaBezNnMheTBqFYHLWINGDbf

## [**Nodes**] Connecter une *Node* au cluster (optionnel)
Utiliser la commande spécifiée plus haut dans le résultat de la commande «*microk8s.add-node*». On lance la commande *microk8s.join* pour joindre le cluster.

	microk8s.join ip-172-31-20-243:25000/DDOkUupkmaBezNnMheTBqFYHLWINGDbf

# Préparer une image *Docker*
Pour ce tutoriel, une image *Docker* a déjà été préparée (*duptom44/k8stuto*), mais si vous voulez essayer, vous pouvez faire votre propre image *Docker*. 

Premièrement, on crée le fichier *Dockerfile* (il est important d'écrire le nom du fichier avec une majuscule) qui contiendra les information pour la préparation de l'image:
	
	nano Dockerfile

Dans le fichier, on peut écrire:

	FROM nginx:alpine
	COPY /v1 /usr/share/nginx/html
	RUN chmod -R +rwx /usr/share/nginx/html

Pour en savoir plus sur le *Dockerfile*, vous pouvez consulter la [documentation](https://docs.docker.com/engine/reference/builder/).

On sauvegarde le fichier et on prépare le simple fichier HTML qui sera chargé dans le conteneur:

	mkdir v1
	nano ./v1/index.html

Un exemple du contenu de la simple page HTML:

	<html>
	<head>
	<title>Ma premi&egrave;re page K8s</title>
	</head>
	<body>
	<h1>D&eacute;ploiement initial de l'application</h1>
	<p>Allo! Je suis &agrave; la version 1.00!</p>
	</body></html>

Une fois ces étapes effectuées, on construit l'image *Docker* (ne pas oublier le point à la fin!):
	
	docker build -t <nom_de_l_image> .

On donne un nouveau tag à l'image avant de l'envoyer sur *Docker Hub* (le *tag* est toujours optionnel):

	docker tag <NomImageLocal>:<Tag> <nomUtilisateurDocker>/<NouveauNomImage>:<Tag>

Avant d'envoyer l'image sur *Docker Hub*, on doit se connecter (et au préalable avoir créé un compte sur *Docker Hub*):

	docker login

Une fois connectés à *Docker Hub*, on peut pousser l'image:

	docker push <nomUtilisateurDocker>/<NouveauNomImage>:<Tag>

Si on veut publier une autre image (ou une nouvelle version de l'image), on modifie le Dockerfile et on continue les étapes subséquentes.

# Configurer un déploiement dans *Kubernetes*
Une fois que l'image *Docker* est disponible, on peut créer le déploiement avec cette image *Docker* dans *Kubernetes*:

	microk8s.kubectl create deployment k8stuto --image=docker.io/duptom44/k8stuto:v1

Une fois le déploiement créé, il est automatiquement lancé. Par contre, on doit demander à exposer les ports de la *Pod*:

	microk8s.kubectl create service nodeport k8stuto --tcp=80:80

Pour pouvoir questionner le serveur web pour lequel on a exposé le port, on doit demander à *Kubernetes* quel port a été exposé (on prend le port après le port 80 sur le service *NodePort* qu'on vient de créer):

	microk8s.kubectl get service

Pour ouvrir notre page web, on navigue sur le lien suivant:

	http://<adresse_ip_serveur>:<port_exposé>

Si vous obtenez une erreur *403 Forbidden*, il faut exécuter la commande suivante sur la *Pod* (pour obtenir le nom de la *pod*, faire la commande *microk8s.kubectl get pods*):

	microk8s.kubectl exec <nom_de_la_pod> chmod +rwx /usr/share/nginx/html/index.html

Alors que le service est en cours de fonctionnement, si on veut publier la dernière version sans interruption de service, on effectue seulement un changement d'image et *Kubernetes* s'occupe du reste:

	microk8s.kubectl set image deployments/k8stuto k8stuto=docker.io/duptom44/k8stuto:v2

La puissance de *Kubernetes* réside dans les conteneurs et il est en mesure d'ajuster dynamiquement le nombre de conteneurs:

	microk8s.kubectl scale deployments/k8stuto --replicas=10

 	microk8s.kubectl autoscale deployments/k8stuto --min=5 --max=15 --cpu-percent=80

# *Commandes supplémentaires*
## Afficher le status de microk8s:
	microk8s.status --wait-ready

## Lancer le dashboard (si besoin):
Ajouter un '&' à la fin de la commande pour lancer le dashboard en arrière-plan.
On peut se connecter sur le dashboard web uniquement sur l'ordinateur local.

	microk8s.enable dashboard
	microk8s.kubectl proxy

[Lien pour accéder au dashboard local](http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/)

## Exécuter une commande sur une *Pod*
	microk8s.kubectl exec <nom_de_la_pod>

## Obtenir les déploiements dans *Kubernetes*
	microk8s.kubectl get deployments
	
## Obtenir les *Pods* actives dans *Kubernetes*
	microk8s.kubectl get pods
