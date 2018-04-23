# Chart for Technical On-boarding
[![pipeline status](https://git.cnct.io/common-tools/samsung-cnct_chart-technical-on-boarding/badges/master/pipeline.svg)](https://git.cnct.io/common-tools/samsung-cnct_chart-technical-on-boarding/commits/master)

Generate Github Projects according to your specific needs - onboarding, sprints, task lists. As we continue developing, this product will continue to improve. And as usual, patches are always welcome.

## Instructions for adaptation for specific use

To configure this helm chart for your specific use, you may also want to configure its [corresponding container](https://github.com/samsung-cnct/container-technical-on-boarding).

### Prerequisites

#### Fork and clone

[Fork and clone](https://guides.github.com/activities/forking/) this repository into your Github repository and workspace.

#### Kubectl

Make sure you have installed [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

#### Helm

Make sure you have installed [helm](https://docs.helm.sh/using_helm/#installing-helm)

#### Appr plugin

Install appr (application registry) plugin according to instructions here: https://github.com/app-registry/appr#osx
provides an nginx ingress controller chart on [Quay](http://quay.io) and you will need this plugin to be able to install charts on your Kubernetes cluster from a chart registry.

#### A Kubernetes cluster

You will need to have access to a working Kubernetes cluster with admin privilege (i.e. use GKE)

#### A Github repository for your project board

Create a GitHub repository where your onboarding projects will be created.
Enable Issues on that repo (Settings --> check Issues)

### Set up and deploy your chart

1. On your cluster, run `helm init`(this will deploy tiller)
2. Your cluster will need an ingress controller to be able to expose the app running on your cluster to the outside. Deploy the following helm chart like so:
`helm registry install quay.io/samsung_cnct/nginx-ingress`
3. Find the ingress controller's external IP address by querying your cluster:
`kubectl get services -o wide`
You should see a Service of Type LoadBalancer that has an external IP address. Make a note of this address.
It is possible that it may take a few moments for your ingress controller pod to spin up; you can run
`kubectl get pods` and that should tell you the status of your pod.
4. Create a DNS record that resolves to the IP address from Step 3 (i.e. with AWS Route 53)
5. Register your app with [GitHub OAuth](https://github.com/settings/applications/new) (more information [here](https://developer.github.com/v3/guides/basics-of-authentication/))
  - For the Application name, fill in anything you like that makes sense to you
  - The Homepage URL is the name of the GitHub repository your project boards will be created in.
  - For the Authorization Callback URL, use the DNS name from Step 4: `http://<your_DNS_name>/tracks`
  - Once your application is registered, make a note of the `clientId` and `clientSecret`.
7. Configure technical-on-boarding/values.yaml to reflect your particular setup. Change the following values:
  - host: `<your_DNS_name>`
  - onboard.org: `<your GitHub org name>`
  - onboard.repo: `<Github repository you created for the project boards>`
  - onboard.clientId: `<Github OAuth clientId from step 5>`
  - onboard.clientSecret `<Github OAuth clientSecret from step 5>`
8. In your cloned folder for the helm chart, run
` build/build.sh` (this will generate a Chart.yaml)
then
`helm install ./technical-on-boarding` (this will install the chart on your cluster).
Again, wait a few minutes for the pod to be ready. `kubectl get pods` will show readiness status.
9. Go to http://`<your_DNS_name>` and follow the steps to create a new project. Each user visiting this site will be able to create their very own project board on your onboarding repo.

*Note*: This chart currently deploys a very specific container image, hosted by Samsung CNCT. It has several tracks designed for learning about Kubernetes, Kubernetes app development, and cluster operation. Should you wish to change those tracks or introduce your own, you will need to modify our [base container](https://github.com/samsung-cnct/container-technical-on-boarding) accordingly (instructions coming soon).


## Configuration

The following tables lists the configurable parameters of the Technical On-boarding chart and their default values.

| Parameter                | Description                                     | Default                                                |
| ------------------------ | ----------------------------------------------- | ------------------------------------------------------ |
| `image           `       | FQDN repository/image name                      | `quay.io/samsung_cnct/technical-on-boarding-container` |
| `tag`                    | image tag                                       | latest                                                 |
| `onboard.org`            | organization                                    | ` samsung-cnct`                                        |
| `onboard.repo`           | repo where new issues will be created           | `technical-on-boarding`                                |
| `onboard.clientId`       | github client id                                |  **Required**                                          |
| `onboard.clientSecret`   | github client secret                            |  **Required**                                          |

### GitLab Configuration

*(For CNCT development purposes only)*

The following project level [GitLab secret variable](https://git.cnct.io/help/ci/variables/README.md#secret-variables)
is required:

  - `REGISTRY_PASSWORD`: Set as gitlab secret variable. The associated registry password. (corresponding quay.io robot token)
