package test

import data.main

test_image_safety {
  unsafe_image := {
    "request": {
      "kind": {"kind": "Pod"},
      "object": {
        "spec": {
          "containers": [
            {"image": "quay.io/nginx"},
            {"image": "busybox"}
          ]
        }
      }
    }
  }
  count(main.deny) == 1 with input as unsafe_image
}