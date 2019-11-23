![K8s Logo](https://lucasvidelaine.files.wordpress.com/2018/01/kubernetes3.png?w=250)

# Tutoriel d'installation de Kubernetes (K8s)

Le tutoriel a été effectué sur des VM Hyper-V sur lesquelles Ubuntu 18.04 Server a été installé. Toutes les instructions d'appliquent donc pour un système d'exploitation Linux.

À des fins de références, il est possible de consulter le [glossaire de Kubernetes](https://kubernetes.io/docs/reference/glossary/?fundamental=true).

## Lancer le premier script d'installation

wget -O - https://raw.githubusercontent.com/duptom/k8s_tutorial/master/1-install.sh | sudo bash