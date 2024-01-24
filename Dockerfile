FROM alpine:3.14.0

ENV BASE_URL="https://get.helm.sh"

ENV HELM_2_FILE="helm-v2.17.0-linux-amd64.tar.gz"
ENV HELM_3_FILE="helm-v3.6.3-linux-amd64.tar.gz"
# make sure these variables are the same in index.js as Gitgub can change the user home
ENV HELM_CACHE_HOME="/root/.cache/helm"
ENV HELM_CONFIG_HOME="/root/.config/helm"
ENV HELM_DATA_HOME="/root/.local/share/helm"
ENV HELM_PLUGINS="/root/.local/share/helm/plugins"
ENV HELM_REGISTRY_CONFIG="/root/.config/helm/registry.json"
ENV HELM_REPOSITORY_CACHE="/root/.cache/helm/repository"
ENV HELM_REPOSITORY_CONFIG="/root/.config/helm/repositories.yaml"

RUN apk add --no-cache ca-certificates \
    --repository http://dl-3.alpinelinux.org/alpine/edge/community/ \
    jq curl bash nodejs aws-cli py3-setuptools &&\
    apk add py3-pip git && \
    pip3 install awscli
RUN \
    # Install helm version 2:
    curl -L ${BASE_URL}/${HELM_2_FILE} |tar xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64 && \
    # Install helm version 3:
    curl -L ${BASE_URL}/${HELM_3_FILE} |tar xvz && \
    mv linux-amd64/helm /usr/bin/helm3 && \
    chmod +x /usr/bin/helm3 && \
    rm -rf linux-amd64 && \
    # Init version 2 helm:
    helm init --client-only && \
    # install helm s3 plugin
    helm3 plugin install https://github.com/hypnoglow/helm-s3.git


ENV PYTHONPATH "/usr/lib/python3.8/site-packages/"

COPY . /usr/src/
ENTRYPOINT ["node", "/usr/src/index.js"]
