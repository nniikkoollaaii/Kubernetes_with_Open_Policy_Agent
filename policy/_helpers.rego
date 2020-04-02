package main


###############################################################################
# read containers from various inputs

# kubernetes admission review for kind pod
input_containers[container] {
    container := input.request.object.spec.containers[_]
}

# kubernetes admission review for kind ???
input_containers[container] {
    container := input.request.object.spec.template.spec.containers[_]
}


# deployment manifest
input_containers[container] {
    input.kind = "Deployment"
    container := input.spec.template.spec.containers[_]
}