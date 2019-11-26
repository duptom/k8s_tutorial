![K8s Logo](https://lucasvidelaine.files.wordpress.com/2018/01/kubernetes3.png?w=250)

# Tutoriel d'installation de Kubernetes (K8s)

Le tutoriel a été effectué sur des VM Hyper-V sur lesquelles Ubuntu 18.04 Server a été installé. Toutes les instructions d'appliquent donc pour un système d'exploitation Linux (*Ubuntu Server 18.04.3 LTS (Bionic Beaver)*).

À des fins de références, il est possible de consulter le [glossaire de Kubernetes](https://kubernetes.io/docs/reference/glossary/?fundamental=true).

Certaines étapes d'installation spécifient s'il faut faire l'action sur le *Cluster* principal et/ou sur les *Nodes*.

## Activer la virtualisation sur une VM Hyper_V
Si vous utilisez Hyper-V et que la virtualisation n'est pas activée sur votre VM, vous pouvez effectuer la commande suivante sur la VM fermée:

```PowerShell
Set-VMProcessor -VMName <NomDeLaVM> -ExposeVirtualizationExtensions $true
```

## [**Cluster, Nodes**] Installation de microk8s
Microk8s est une distribution de Kubernetes facile d'utilisation avec tous les outils pré installés et configurés. Pour l'installer, simplement lancer cette commande

	sudo apt install snapd | sudo snap install microk8s --classic --channel=1.16/stable
	
Afficher le status de microk8s suite à l'installation:

	microk8s.status --wait-ready

Il faut ajouter l'accès à l'utilisateur à microk8s et docker sinon on doit toujours lancer les commande avec *sudo*.

	sudo usermod -a -G microk8s <utilisateur_actuel>
	sudo usermod -aG docker <utilisateur_actuel>

Ensuite, on doit redémarrer pour appliquer la sécurité

	sudo shutdown -r now

## [**Cluster**] Générer la chaîne de connexion pour les pods
	microk8s.add-node
Le résultat de la commande précédente devrait ressembler à cela:
	
	Join node with: microk8s.join ip-172-31-20-243:25000/DDOkUupkmaBezNnMheTBqFYHLWINGDbf

	If the node you are adding is not reachable through the default
	interface you can use one of the following:

	microk8s.join 10.1.84.0:25000/DDOkUupkmaBezNnMheTBqFYHLWINGDbf
	microk8s.join 10.22.254.77:25000/DDOkUupkmaBezNnMheTBqFYHLWINGDbf

## [**Nodes**] Connecter une node au cluster (optionnel)
Utiliser la commande spécifiée plus haut dans le résultat de la commande «*microk8s.add-node*». On lance la commande *microk8s.join* pour joindre le cluster.

	microk8s.join ip-172-31-20-243:25000/DDOkUupkmaBezNnMheTBqFYHLWINGDbf

# Préparer une image Docker
Pour ce tutoriel, une image docker a déjà été préparée (*duptom44/k8stutorial*), mais si vous voulez essayer, vous pouvez faire votre propre image Docker. 

Premièrement, on crée le fichier *Dockerfile* (il est important d'écrire le nom du fichier avec une majuscule) qui contiendra les information pour la préparation de l'image:
	
	nano Dockerfile

Dans le fichier, on peut écrire:

	FROM nginx:alpine
	COPY /v1 /usr/share/nginx/html
	RUN chmod -R +rwx /usr/share/nginx/html

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

Une fois ces étapes effectuées, on construit l'image Docker (ne pas oublier le point à la fin!):
	
	docker build -t <nom_de_l_image> .

On donne un nouveau tag à l'image avant de l'envoyer sur Docker Hub (le *tag* est toujours optionnel):

	docker tag <NomImageLocal>:<Tag> <nomUtilisateurDocker>/<NouveauNomImage>:<Tag>

Avant d'envoyer l'image sur Docker Hub, on doit se connecter (et au préalable avoir créé un compte sur Docker Hub):

	docker login

Une fois connectés à Docker Hub, on peut pousser l'image:

	docker push <nomUtilisateurDocker>/<NouveauNomImage>:<Tag>

Si on veut publier une autre image (ou une nouvelle version de l'image), on modifie le Dockerfile et on continue les étapes subséquentes.

# Configurer un déploiement dans Kubernetes
Une fois que l'image Docker est disponible, on peut créer le déploiement avec cette image Docker dans Kubernetes:

	microk8s.kubectl create deployment k8stutorial --image=docker.io/duptom44/k8stutorial:v1

Une fois le déploiement créé, il est automatiquement lancé. Par contre, on doit demander à exposer les ports de la Pod:

	microk8s.kubectl create service nodeport k8stutorial --tcp=80:80

Alors que le service est en cours de fonctionnement, si on veut publier la dernière version sans interruption de service, on effectue seulement un changement d'image et Kubernetes s'occupe du reste:

	microk8s.kubectl set image deployments/k8stutorial k8stutorial=docker.io/duptom44/k8stutorial:v2

Pour pouvoir questionner le serveur web pour lequel on a exposé le port, on doit demander à Kubernetes quel port a été exposé:

	microk8s.kubectl get service

Si vous obtenez une erreur *403 Forbidden*, il faut exécuter la commande suivante sur la pod:

	microk8s.kubectl exec <nom_de_la_pod> chmod +rwx /usr/share/nginx/html/index.html

La puissance de Kubernetes réside dans les conteneurs et il est en mesure d'ajuster dynamiquement le nombre de conteneurs:

	microk8s.kubectl scale deployments/k8stutorial --replicas=10

 	microk8s.kubectl autoscale deployments/k8stutorial --min=10 --max=15 --cpu-percent=80

# *Commandes supplémentaires*
## Afficher le status de microk8s:
	microk8s.status --wait-ready

## Lancer le dashboard (si besoin):
Ajouter un '&' à la fin de la commande pour lancer le dashboard en arrière-plan.
On peut seulement se connecter sur le dashboard web sur l'ordinateur local.

	microk8s.kubectl proxy

[Lien pour accéder au dashboard local](http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/)

## Exécuter une commande sur une pod
	microk8s.kubectl exec <nom_de_la_pod>

## Obtenir les déploiements dans Kubernetes
	microk8s.kubectl get deployments
	
## Obtenir les pods actives dans Kubernetes
	microk8s.kubectl get pods
