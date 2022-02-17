# Coverity on Kubernetes

Requirements:
 - a Kubernetes cluster -- 1.18 - 1.23
   - scripts are provided to create a single-node KinD cluster
   - at least one node with enough spare CPU and memory to run analysis
 - kubectl
 - helm3
 
You will also need:
 - a valid Coverity license
 - access to Coverity images
 - access to the Coverity helm chart
 
## Setup procedure

1. Get Coverity images into a registry that your kubernetes cluster can pull from

2. Copy your license file into this directory at `license.dat`

3. (optional) create a KinD cluster

    ```bash
    pushd kind
      ./create-cluster.sh
    popd
    ```

4. make sure your cluster can pull images from the registry

 - if authentication is required, you'll need to create an image pull secret and pass the name of the secret
   as a helm override, for example `--set imagePullSecret=registry-auth-secret-name`

5. run the deploy script, specifying the location of the chart as well as the location of the images and the name
   of a node to run analysis on:

    ```bash
    COVERITY_CHART_LOCATION=path/to/cnc \
    COVERITY_ANALYSIS_NODE_NAME=kind-control-plane \
      ./deploy-coverity.sh \
        --set imageRegistry=localhost:5000 \
        --set publicImageRegistry=localhost:5000 \
        --set imagePullSecret=registry-auth-secret-name
    ```
