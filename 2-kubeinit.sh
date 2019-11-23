##-------------------------------------------------
## Démarrer kubeadm avec la configuration de Cilium
##-------------------------------------------------
sudo swapoff -a
kubeadm init --pod-network-cidr=10.217.0.0/16