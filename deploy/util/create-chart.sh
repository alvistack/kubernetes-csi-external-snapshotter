#!/usr/bin/env bash

# Copyright 2025 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euxo pipefail

BASE_DIR="$( cd "$( dirname "$0" )" && pwd )/../../"

TEMP_DIR="$( mktemp -d )"
trap 'rm -rf ${TEMP_DIR}' EXIT

SNAPSHOT_CONTROLLER_YAML=${BASE_DIR}/charts/snapshot-controller/templates/setup-snapshot-controller.yaml

cp -rfp ${BASE_DIR}/client/config/crd/* ${BASE_DIR}/charts/snapshot-controller/templates/
cp -rfp ${BASE_DIR}/deploy/kubernetes/snapshot-controller/* ${BASE_DIR}/charts/snapshot-controller/templates/
rm -rf ${BASE_DIR}/charts/snapshot-controller/templates/kustomization.yaml

find ${BASE_DIR}/charts/snapshot-controller/templates/*.yaml | while read -r _YAML
do
    yq -P -I 2 '... comments=""' -i ${_YAML}
    sed -i 's/namespace: kube-system/namespace: {{ .Release.Namespace }}/g' ${_YAML}
done

sed -i 's/replicas: .*$/replicas: {{ .Values.snapshotController.replicaCount }}/g' ${SNAPSHOT_CONTROLLER_YAML}
sed -i 's/image: .*$/image: {{ .Values.snapshotController.image.repository }}:{{ .Values.snapshotController.image.tag }}/g' ${SNAPSHOT_CONTROLLER_YAML}
sed -i 's/imagePullPolicy: .*$/imagePullPolicy: {{ .Values.snapshotController.image.pullPolicy }}/g' ${SNAPSHOT_CONTROLLER_YAML}
