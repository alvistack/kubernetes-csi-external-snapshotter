# Project Instructions: CSI External Snapshotter Helm Chart Packaging

## Overview
This repository contains the Kubernetes CSI External Snapshotter implementation. To support Helm-based deployments and automated chart releases (via `gh-pages` and `helm/chart-releaser-action`), static deployment manifests under `deploy/kubernetes/` are converted into Helm Charts under `charts/` (`charts/csi-snapshotter` and `charts/snapshot-controller`) using the script at `deploy/util/chart-releaser.sh`.

---

## Workflow for Stable Tag Releases & Chart Packaging

Before each stable tag release or when updating deployment manifests/versions, maintainers must perform the following steps:

1. **Verify & Update Static Deployment Manifests:**
   - Ensure image tags and configurations across static manifests under `deploy/kubernetes/csi-snapshotter/` and `deploy/kubernetes/snapshot-controller/` are synchronized to the target release version (e.g., `v8.7.0`).

2. **Run the Chart Releaser Script:**
   - Execute the chart conversion script:
     ```bash
     ./deploy/util/chart-releaser.sh
     ```
   - This script automatically:
     - Copies CRDs and deployment manifests into `charts/csi-snapshotter/templates/` and `charts/snapshot-controller/templates/`.
     - Automatically synchronizes `charts/csi-snapshotter/values.yaml`, `charts/csi-snapshotter/Chart.yaml`, `charts/snapshot-controller/values.yaml`, and `charts/snapshot-controller/Chart.yaml` with image repositories, tags, pull policies, replica counts, and version metadata from the static manifests.
     - Converts static manifests into Helm template expressions (`{{ .Values... }}` and `{{ .Release.Namespace }}`).

3. **Verify Chart Integrity:**
   - Lint the Helm charts:
     ```bash
     helm lint charts/csi-snapshotter
     helm lint charts/snapshot-controller
     ```
   - Test template rendering:
     ```bash
     helm template csi-snapshotter charts/csi-snapshotter
     helm template snapshot-controller charts/snapshot-controller
     ```

4. **Commit Chart Updates:**
   - Force-add and commit the generated/updated chart artifacts:
     ```bash
     git add --all --force charts/* && git commit -m "Update Helm Charts for v8.7.0"
     ```

---

## Architectural & Script Design Principles (`chart-releaser.sh`)
- **No Deployment Execution:** Unlike deployment scripts, `chart-releaser.sh` does not run `kubectl apply` or post-deploy health checks; instead, it outputs generated manifests and chart templates directly.
- **Automation of Values & Metadata:** `yq` is utilized to parse deployment parameters, automatically synchronizing `Chart.yaml` (`version` and `appVersion`), `values.yaml`, and template variables directly from the static manifests.
