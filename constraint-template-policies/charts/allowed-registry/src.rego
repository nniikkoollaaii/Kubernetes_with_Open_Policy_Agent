package k8sallowedrepos

violation[{"msg": msg}] {
  input_containers[container]
  satisfied := [good | repo = input.parameters.repos[_] ; good = startswith(container.image, repo)]
  not any(satisfied)
  msg := sprintf("container <%v> has an invalid image repo <%v>, allowed repos are %v", [container.name, container.image, input.parameters.repos])
}

violation[{"msg": msg}] {
  input_initcontainers[container]
  satisfied := [good | repo = input.parameters.repos[_] ; good = startswith(container.image, repo)]
  not any(satisfied)
  msg := sprintf("container <%v> has an invalid image repo <%v>, allowed repos are %v", [container.name, container.image, input.parameters.repos])
}


# read containers from various inputs
# kubernetes admission review for kind pod
input_containers[container] {
  container := input.review.object.spec.containers[_]
}

# kubernetes admission review for kind Deployment
input_containers[container] {
  container := input.review.object.spec.template.spec.containers[_]
}

# we could fail rules, if there document type isn't under validation via
  # check if key "review" exists and is not false
  #input.review

  # is input kind Deployment, then add this containers to the incremental rule
  # input.review.object.kind == "Deployment"


# read initcontainers from various inputs
# kubernetes admission review for kind pod
input_initcontainers[initcontainer] {
  initcontainer := input.review.object.spec.initContainers[_]
  
}

# kubernetes admission review for kind Deployment
input_initcontainers[initcontainer] {
  initcontainer := input.review.object.spec.template.spec.initContainers[_]
}