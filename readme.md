# Setup Kubernetes with Open Policy Agent and enforce these Policys in your CD-Pipeline

## Intro to OPA-Policies

https://www.openpolicyagent.org/docs/latest/policy-language/

Example in Folder "policy"

### Choose Binary

You can work with the [OPA binary](https://www.openpolicyagent.org/docs/latest/#1-download-opa) or with this tool [conftest](https://www.conftest.dev/install/)

The Tool [conftest](https://github.com/instrumenta/conftest) enables you to quickly test your kubernetes configuration against these policys

Conftest is simpler to use

### Unit Test your Policys

write unit test in .rego files.

Test execution detects all policys in .rego files starting with "test_" and executes them
https://www.openpolicyagent.org/docs/latest/policy-testing/

I end my test files name with .test.rego

Execute tests with

    opa test policy/

    conftest verify policy/

### Check your policys against your configuration

Assuming your configuration are in a folder /app like mine use:

    opa eval -d policy -i .\app\deployment.yaml "data.main.deny"
or 

    conftest test app/deployment.yaml
    conftest test app/

Conftest detects your policys under "./policys" and enforces them on \<file>


### use policys in your cicd pipeline

you can pull policys from different [sources](https://github.com/instrumenta/conftest/pull/107)

Pull the policies from this example via

    conftest pull git::http://github.com/nniikkoollaaii/Kubernetes_with_Open_Policy_Agent.git


More interesting is this onliner 

    conftest test --update git::http://github.com/nniikkoollaaii/Kubernetes_with_Open_Policy_Agent.git app/

It downloads the "policy" folder from the git repo and saves them locally under ./policy/policy
I don't know why two "policy" folders but it runs



## Enforce OPA-Policies in your Kubernetes Cluster with Gatekeeper

Gatekeeper v1 (aka kube-mgmt) works with these previous written policies.

The current version [Gatekeeper v3](https://kubernetes.io/blog/2019/08/06/opa-gatekeeper-policy-and-governance-for-kubernetes/) works with the [Open Policy Agent Constraint Framework](https://github.com/open-policy-agent/frameworks)

Here policies are definied via Constraint Templates and Constraints

For example we want to create a constraint template restricting images in containers to come from a trusted registry

Here three problems come up

1. Most times you're submitting a kubernetes deployment with a probably invalid image. The deployment object creates a replicaset and the replicaset creates one or more pods. Most of the examples out there intercept these CREATE, UPDATE AdmissionReviews from API Server to Gatekeeper. But to be able to test our policies against local files (for example in our CI/CD pipeline) our policies have to support deployment objects

2. Nor conftest either opa eval support validation opa constraint framework policies.

3. How to test your policies when they are defined in a Constraint Template yaml file


### How to unit tests your policies

The trick we're using is still defining your policies in .rego files.
We design the policies and the tests to be as similar as being used by gatekeeper.


Then we automatically copy the content of the .rego files in the correct constraint template yaml files via a helm template

    {{ .Files.Get  "src.rego" | indent 8 }}


### How to enforce your policies against local files

To adress pain points one and two from above we have to do the following

#### Extend policies to accept mainly used kubernetes objects

Based on an example on the gatekeeper project for restricting registry for an image of an container https://github.com/open-policy-agent/gatekeeper/tree/master/library/general/allowedrepos
I created an example under constraint-template-policies

Its defined as an (minimal) Umbrella Helm Chart with an minimal Subchart for every area of policies

src.rego contains the rego rules

src_test.rego contains test cases for this rego policies

constraint.yaml the constraint

template.yaml contains the constraint template definition and a placeholder to be replaced by helm by the rego code

Exec tests via

    opa test .\constraint-template-policies\templates\allowed-registry\ --ignore *.yaml


Helm Template into kpt directory to test locally

    helm template test .\constraint-template-policies\ --output-dir ./kpt/test


#### Apply the policies against your local files

The opa binary nor conftest has the ability to check policies defined with the OPA Constraint Framework against local manifest files.

The new announced project [kpt](https://googlecontainertools.github.io/kpt/) does have as mentioned in this Github Issue https://github.com/open-policy-agent/gatekeeper/issues/540

I got this response:

    docker run -i -v $(pwd):/source gcr.io/kpt-functions/read-yaml -i /dev/null -d source_dir=/yaml_manifest_including_constraints_and_templates | docker run -i gcr.io/kpt-functions/gatekeeper-validate

I modified it to get the source files from a named volume:

    docker run -i -v gatekeeper-policy:/source gcr.io/kpt-functions/read-yaml -i /dev/null -d source_dir=/source | docker run -i gcr.io/kpt-functions/gatekeeper-validate

But it was easier for me to use the kpt binary with an dir containing all constraints, constraint templates and manifest files

    kpt fn run .\kpt\app\ --image gcr.io/kpt-functions/gatekeeper-validate

The directory "kpt" contains in the subdir "app" all application manifests. In the second subdir are the templated constraints and constraint templates from the previous section.


## Install Gatekeeper in your KinD Cluster#

### Setup a test cluster with KinD

Follow the readme in folder "kind"


### Install Gatekeeper

    ./kubectl apply -f gatekeeper/gatekeeper.yaml

    kubectl get all --all-namespaces

### Apply policies to your cluster

helm install currently not working because of using crd usage with Constraint Template

(crds directory probably but helm template does not include crds and the --include-crd param is buggy on windows)

you have to manually "kubectl apply" first the ConstraintTemplate and then the Constraint

    k apply -f .\kpt\test\constraint-template-policies-umbrella-chart\charts\allowed-registry-policy\templates\constraint.yaml
    k apply -f .\kpt\test\constraint-template-policies-umbrella-chart\charts\allowed-registry-policy\templates\template.yaml
