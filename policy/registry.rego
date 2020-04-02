package main

import data.main.input_containers

deny[reason] {
  some container
  input_containers[container]
  not startswith(container.image, "quay.io/")
  reason := sprintf("image '%v' comes from untrusted registry", [container.image])
}
