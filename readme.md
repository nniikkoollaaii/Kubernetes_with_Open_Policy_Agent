# Setup Kubernetes with Open Policy Agent and enforce these Policys in your CD-Pipeline

## Setup a test cluster with KinD

Follow the readme in folder "kind"

## Definde OPA-Policys

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

I start my test files with .test.rego

Execute tests with

    opa test policy/

    conftest verify policy/

## Check your policys against your configuration

Assuming your configuration-to-test are in folder /app like mine use:

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



## Enforce OPA-Policys in your Cluster with Gatekeeper

Gatekeeper v1 (aka kube-mgmt) works with these previous written policies.

The current version [Gatekeeper v3](https://kubernetes.io/blog/2019/08/06/opa-gatekeeper-policy-and-governance-for-kubernetes/) works with the [Open Policy Agent Constraint Framework](https://github.com/open-policy-agent/frameworks)

Here policies are definied via Constraint Templates and Constraints

Install Gatekeeper in your KinD Cluster

    ./kubectl apply -f gatekeeper/gatekeeper.yaml

    kubectl get all --all-namespaces

    ./kubectl apply -f gatekeeper/policy/registry.template.yaml

    ./kubectl apply -f gatekeeper/policy/registry.constraint.yaml

### test these policies against your local files

The opa binary nor conftest has the ability to check policies defined with the OPA Constraint Framework against local manifest files.

The new announced project [kpt](https://googlecontainertools.github.io/kpt/) does have as mentioned in this Github Issue https://github.com/open-policy-agent/gatekeeper/issues/540

I got this response:

    docker run -i -v C:\Users\54623\Documents\git-repos\Github\Kubernetes_with_Open_Policy_Agent:/source gcr.io/kpt-functions/read-yaml -i /dev/null -d source_dir=/yaml_manifest_including_constraints_and_templates | docker run -i gcr.io/kpt-functions/gatekeeper-validate

I modified it to get the source files from a named volume:

    docker run -i -v gatekeeper-policy:/source gcr.io/kpt-functions/read-yaml -i /dev/null -d source_dir=/source | docker run -i gcr.io/kpt-functions/gatekeeper-validate

Currently I'm hitting an rego_parse_error.
I filled this [Issue here](https://github.com/GoogleContainerTools/kpt/issues/493)