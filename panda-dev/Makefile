
RELEASE_NAME ?= dev

activemq:
	helm template activemq-$(RELEASE_NAME) helm/activemq -f helm/activemq/values.yaml > activemq.yaml

idds:
	helm template idds-$(RELEASE_NAME) helm/idds -f helm/idds/values.yaml > idds.yaml

panda:
	helm template panda-$(RELEASE_NAME) helm/panda -f helm/panda/values.yaml > panda.yaml

helm: activemq idds panda

apply:
	kubectl apply -k .
