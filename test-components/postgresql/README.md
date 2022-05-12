#Postgres k8s deployment

## Deployment

* Clone this repo to your local machine

* Install kubectl

      https://kubernetes.io/docs/tasks/tools/install-kubectl/

* Install minikube

      https://kubernetes.io/docs/tasks/tools/install-minikube/
	  https://minikube.sigs.k8s.io/docs/start/

* Start minikube with extra RAM:

      minikube start --memory='4000mb'

* Deploy:

      kubectl apply -f postgres.yaml

## Some helpful commands

* View nodes:

      kubectl get nodes

* View all containers:

      kubectl get pods
      kubectl get pods -A

* View all (services, deployments, pods and so on):

      kubectl get all

* View/Tail logfiles of pod:

      kubectl logs <NAME>

      kubectl logs -f <NAME>

* Shut down minikube:

      minikube stop

## Test to connect postgresql

* log into postgresql with kubectl exec

      kubectl exec -it [pod-name] --  psql -h localhost -U admin --password -p [port] postgresdb
      kubectl exec -it postgres-7b68d68685-h49s4 --  psql -h localhost -U admin --password -p 5432 postgresdb
