The read-yaml function returns a Kind: List of my yaml files
Echoing these into the gatekeeper-validate function and you can test more easily.
See test-gatekeeper-validate-function.txt


kpt fn run app --image gcr.io/kpt-functions/gatekeeper-validate