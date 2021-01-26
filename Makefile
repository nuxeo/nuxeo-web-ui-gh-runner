-include .env
export

REGISTRY=us-east1-docker.pkg.dev/$(GKE_PROJECT)
VERSION?=latest
IMAGE=$(REGISTRY)/webui/gh-runner:$(VERSION)

.PHONY: all image deploy

all: image deploy

nuxeo.repo:
	echo \
	[nuxeo]\\n\
	name=Nexus Private Yum Release Repository\\n\
	baseurl=https://packages.nuxeo.com/repository/yum-registry/\\n\
	username=$(YUM_REPO_USERNAME)\\n\
	password=$(YUM_REPO_PASSWORD)\\n\
	enabled=1\\n\
	gpgcheck=0\\n\
	> nuxeo.repo

image: nuxeo.repo
	docker build . -t $(IMAGE)
	docker push $(IMAGE)

kustomization.yaml:
	kustomize create --resources manifests/deployment.yaml,manifests/hpa.yaml --namespace webui
	kustomize edit add secret web-ui-gh-runner-secret --from-literal=GITHUB_TOKEN=$(GITHUB_TOKEN)
	kustomize edit set image webui/runner:latest=$(IMAGE)

deploy: kustomization.yaml
	kustomize build . | kubectl apply -f - 

clean:
	rm nuxeo.repo kustomization.yaml

