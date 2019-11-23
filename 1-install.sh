##------------------------------------------
# Install snap
##------------------------------------------
sudo apt install snapd

##------------------------------------------
# Install microk8s
##------------------------------------------
sudo snap install microk8s --classic --channel=1.16/stable

## Afficher le status de microk8s
microk8s.status --wait-ready