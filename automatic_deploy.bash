#!/bin/bash

#
# @author: Andres Villalobos, aka: Andy
# @Description: Automated jupyter hub deploy
#

function fill_secrets() {
	WHITELIST="lsst,lsst-sqre"
	DBURL="sqlite:////home/jupyter/jupyterhub.sqlite"
	CALLBACKURL="https://$DNS_ENTRY/hub/oauth_callback"
	GITHUB_CLIENT_ID=$(echo -n $CLIENTID | base64 -i - )
	GITHUB_OAUTH_CALLBACK_URL=$(echo -n $CALLBACKURL | base64 -i -)
	GITHUB_ORGANIZATION_WHITELIST=$(echo -n "lsst,lsst-sqre" | base64 -i -)
	GITHUB_SECRET=$(echo -n $CLIENTSECRET | base64 -i - )
	SESSION_DB_URL=$(echo -n $DBURL | base64 -i - )
	CRYPTO_KEY=$(echo -n "$(openssl rand -hex 32);$(openssl rand -hex 32)" | base64 -i - )
	cp -v jupyterhub/kubernetes/jld-hub-secrets.template.yml jupyterhub/kubernetes/jld-hub-secrets.yml
	sed -i.bkp "s/{{GITHUB_CLIENT_ID}}/$GITHUB_CLIENT_ID/g;s/{{GITHUB_OAUTH_CALLBACK_URL}}/$GITHUB_OAUTH_CALLBACK_URL/g;s/{{GITHUB_ORGANIZATION_WHITELIST}}/$GITHUB_ORGANIZATION_WHITELIST/g;s/{{GITHUB_SECRET}}/$GITHUB_SECRET/g;s/{{SESSION_DB_URL}}/$SESSION_DB_URL/g;s/{{JUPYTERHUB_CRYPTO_KEY}}/$CRYPTO_KEY/g" jupyterhub/kubernetes/jld-hub-secrets.yml
}

function deploy_kubernetes_services(){

	kubectl config use-context "$CLUSTER_NAME-$SUFFIX"
	kubectl create namespace ns-"$CLUSTER_NAME-$SUFFIX"
	kubectl config set-context $(kubectl config current-context) --namespace ns-"$CLUSTER_NAME-$SUFFIX"

	echo -e "\n################################################################################"
	echo "Deploying Kubernetes services/server"
	kubectl create -f fileserver/kubernetes/jld-fileserver-deployment.yml
	kubectl create -f fileserver/kubernetes/jld-fileserver-storageclass.yml
	kubectl create -f fileserver/kubernetes/jld-fileserver-service.yml

	echo -e "\n################################################################################"
	echo "Copying the template as the production file"

	cp -v fileserver/kubernetes/jld-fileserver-pv.template.yml  fileserver/kubernetes/jld-fileserver-pv.yml
	cp -v fileserver/kubernetes/jld-fileserver-physpvc.template.yml fileserver/kubernetes/jld-fileserver-physpvc.yml
	cp -v fileserver/kubernetes/jld-fileserver-pvc.template.yml fileserver/kubernetes/jld-fileserver-pvc.yml

	SHARED_VOLUME_SIZE=$[$PHYSICAL_SHARED_VOLUME_SIZE*95/100]

	sed -i.bkp "s/{{PHYSICAL_SHARED_VOLUME_SIZE}}/$PHYSICAL_SHARED_VOLUME_SIZE/g" fileserver/kubernetes/jld-fileserver-physpvc.yml
	sed -i.bkp "s/{{SHARED_VOLUME_SIZE}}/$SHARED_VOLUME_SIZE/g" fileserver/kubernetes/jld-fileserver-pvc.yml
	sed -i.bkp "s/{{SHARED_VOLUME_SIZE}}/$SHARED_VOLUME_SIZE/g" fileserver/kubernetes/jld-fileserver-pv.yml

	kubectl create -f fileserver/kubernetes/jld-fileserver-physpvc.yml
	kubectl create -f fileserver/kubernetes/jld-fileserver-pvc.yml

	kubectl create -f fileserver/kubernetes/jld-fileserver-pv.yml

	K8S_CLUSTER_IP=$(kubectl get service jld-fileserver | grep jld-fileserver | awk '{print $3}')

	echo -e "\n################################################################################"
	echo "Kubernetes cluster's IP server: $K8S_CLUSTER_IP"
	sed -i.bkp "s/{{CLUSTER_IDENTIFIER}}/$SUFFIX/g;s/{{NFS_SERVER_IP_ADDRESS}}/$K8S_CLUSTER_IP/g" fileserver/kubernetes/jld-fileserver-pv.yml


	kubectl create -f fs-keepalive/kubernetes/jld-keepalive-deployment.yml
	kubectl create -f prepuller/kubernetes/prepuller-daemonset.yml
	kubectl create -f jupyterhub/kubernetes/jld-hub-service.yml
	kubectl create -f jupyterhub/kubernetes/jld-hub-physpvc.yml
	kubectl create -f jupyterhub/kubernetes/jld-hub-secrets.yml

	#TODO: create an extra function to create/fill/replace the values on jupyterlabdemo/nginx/kubernetes/tls-secrets.yml
	cp -v ../tls/tls-secrets.yaml nginx/kubernetes/tls-secrets.yml
	kubectl create -f nginx/kubernetes/tls-secrets.yml

	cp -v  nginx/kubernetes/nginx-deployment.template.yml nginx/kubernetes/nginx-deployment.yml
	sed -i.bkp "s/'{{HOSTNAME}}'/$DNS_ENTRY/g" nginx/kubernetes/nginx-deployment.yml
	kubectl create -f nginx/kubernetes/nginx-deployment.yml
	kubectl create -f nginx/kubernetes/nginx-service.yml
	echo -e "\n################################################################################"
	echo "Sleeping the script by 60 seconds to get the IP assigned to NGINX"
	sleep 60
	NGINX_POD_IP=$(kubectl describe service jld-nginx | grep ^LoadBalancer | awk '{print $3}')
	echo "NGINX POD created at IP: $NGINX_POD_IP"
}

################################################################################
# Pre-requisits check                                                          #
################################################################################

if [ -z $(which gcloud) ]
then
	echo "Google Cloud API not found on the path, quitting..."
	exit 1
else
	echo "Google API found at: $(which gcloud)"
	gcloud version
fi

echo "Checking if kubectl is installed, if not, this will install it"

if [ -z $(gcloud components list 2>&1 | grep kubectl | grep "Installed" -o) ]
then
	gcloud components install kubectl
else
	echo "kubectl found: $(which kubectl)"
	kubectl version
fi

################################################################################
# Configuration input                                                          #
################################################################################

echo "This script will create a cluster with minimal resources possible available from Google"
echo "Please indicate the First letter of your name plus the Two first characters of your Surname, ALL LOWERCASE"
read SUFFIX
echo "Please enter the name of the cluster"
read CLUSTER_NAME

echo "Client ID:"
read CLIENTID

echo "Client secret"
read CLIENTSECRET

echo "Enter DNS entry"
read DNS_ENTRY

echo "Enter shared volume size"
read PHYSICAL_SHARED_VOLUME_SIZE

################################################################################
# Cluster configuration and source download                                    #
################################################################################

echo "Cluster creation using name: $CLUSTER_NAME-$SUFFIX"
gcloud container clusters create "$CLUSTER_NAME-$SUFFIX" --num-nodes=2 --machine-type=n1-standard-2 --zone=us-central1-a

echo -e "\n################################################################################"
echo "Making sure that the credential were properly setted up"
gcloud container clusters get-credentials "$CLUSTER_NAME-$SUFFIX"

echo -e "\n################################################################################"
echo "Getting JupyterLabDemo sources from GitHub"
if [ -d jupyterlabdemo ]
then
	echo "Directory already exists, would you like to remove the current directory and get a new version?"
	read OPT
	case $OPT in
		"y"|"Y"|"yes"|"YES")
			rm -rvf jupyterlabdemo
			git clone https://github.com/lsst-sqre/jupyterlabdemo
			;;
		"n"|"N"|"no"|"NO")
			echo "Current directory untouched, however modified files will be redeployed"
			;;
	esac
else
	git clone https://github.com/lsst-sqre/jupyterlabdemo
fi

echo -e "\n################################################################################"
echo "Going into JupyterLab directory..."
cd jupyterlabdemo

#Function created to fill the secrets file for JupyterHub
fill_secrets

#Deploy all the kubernetes services
deploy_kubernetes_services

export K8S_CONTEXT=`kubectl config current-context`

(cd jupyterhub/ ; ./redeploy)

echo "This is all what I can do by now..."
