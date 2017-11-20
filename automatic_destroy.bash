#!/bin/bash

echo "Removal steps from the latest command back to the first one..."

if [ ! -d ./jupyterlabdemo ]
then
	echo "You must be out of jupyterlabdemo directory to execute this script"
	exit 1
fi

cd jupyterlabdemo

export K8S_CONTEXT=`kubectl config current-context`

kubectl delete -f nginx/kubernetes/nginx-deployment.yml
kubectl delete -f nginx/kubernetes/tls-secrets.yml
kubectl delete -f jupyterhub/kubernetes/jld-hub-secrets.yml
kubectl delete -f jupyterhub/kubernetes/jld-hub-physpvc.yml
kubectl delete -f jupyterhub/kubernetes/jld-hub-service.yml
kubectl delete -f prepuller/kubernetes/prepuller-daemonset.yml
kubectl delete -f fs-keepalive/kubernetes/jld-keepalive-deployment.yml
kubectl delete -f fileserver/kubernetes/jld-fileserver-pvc.yml
kubectl delete -f fileserver/kubernetes/jld-fileserver-service.yml
kubectl delete -f fileserver/kubernetes/jld-fileserver-physpvc.yml
kubectl delete -f fileserver/kubernetes/jld-fileserver-storageclass.yml
kubectl delete -f fileserver/kubernetes/jld-fileserver-deployment.yml

echo "Listing availble clusters"
gcloud container clusters list

echo "Please enter the name of the cluster to be deleted"
read CLUSTER_NAME

gcloud container clusters delete $CLUSTER_NAME

cd ..

if [ -d jupyterlabdemo ]
then
	echo "Would you like to remove jupyterhub sources?"
	read OPT
	case $OPT in
		"y"|"Y"|"yes"|"YES")
			rm -rvf jupyterlabdemo
			;;
		"n"|"N"|"no"|"NO")
			echo "Directory remains then..."
			;;
	esac
fi

echo "All done..."
