# minikube
#!/bin/bash

echo "starting minikube with cpu=4 &memory= 4096"
minikube start --memory='4096' --cpus='4'


echo "creating an jenkins namespace and setting jenkins namespace as default namespace"
kubectl create ns jenkins
kubectl get ns 
kubectl config set-context --current --namespace=jenkins 

echo "running jenkins as a pod on minikube using Helm repo"
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update -y
helm install stable/jenkins --namespace jenkins  --generate-name
js=$(kubectl get services --sort-by=.metadata.name -n jenkins -o=name |grep 'jenkins-..........$' |cut -f2 -d/)
kubectl expose service $js  --port=8080 --target-port=8080 --type=NodePort --name=jenkins -n jenkins
a=$(kubectl get svc -n jenkins |grep NodePort |awk '$1=="jenkins"{print $5}'|cut -f2 -d: |cut -f1 -d/)
p=$(printf $(kubectl get secret --namespace jenkins $js -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo)



echo "Running sonarqube as a pod in minikube using Helm repo"

helm install stable/sonarqube --namespace=jenkins --generate-name
ss=$(kubectl get services --sort-by=.metadata.name -n jenkins -o=name |grep "..-sonarqube" |cut -f2 -d/)
kubectl expose service $ss  --port=9000 --target-port=9000 --type=NodePort --name=sonarqube -n jenkins
kubectl get svc -n jenkins |grep NodePort |awk '$1=="sonarqube"{print $5}'|cut -f2 -d: |cut -f1 -d/
b=$(kubectl get svc -n jenkins |grep NodePort |awk '$1=="sonarqube"{print $5}'|cut -f2 -d: |cut -f1 -d/)



echo "

*****************************************************************************************************************
*														*
*		 "jenkins pod url is :"$(minikube ip):$a							*
*		 "username=admin"										*
*		 "password=$p"											*
*		 "sonarqube pod url is :"$(minikube ip):$b							*
*														*
*														*
*														*
*														*
*****************************************************************************************************************

"


