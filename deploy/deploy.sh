#!/usr/bin/env bash
set -ex

if [[ -z $KUBECONTEXT ]]; then
  export KUBECONTEXT=admin@fellow
fi

if [[ -z $IMAGE ]]; then
  echo "\$IMAGE not set, please set it to a git sha with a build container and try again."
  exit 1;
fi

export REVISION=$IMAGE

# krane uses TASK_ID as the deployment_id, this is normally set by shipit
if [[ -z $TASK_ID ]]; then
  export TASK_ID=`date +%s | sha256sum | head -c 6`
fi

# gem install krane to get this tool
krane render \
  --filenames ./deploy/production \
  --bindings=container_registry=326253947186.dkr.ecr.us-west-2.amazonaws.com \
  --current-sha="$REVISION" \
  | krane deploy \
      --stdin \
      --selector="kubernetes-deploy=managed" \
      polr-production "$KUBECONTEXT"
