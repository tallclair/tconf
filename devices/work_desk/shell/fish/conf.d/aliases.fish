# Kubernetes aliases
abbr -a k8s-e2e 'kubetest -v'
abbr -a k8s-run-e2e 'make WHAT=test/e2e/e2e.test && KUBERNETES_CONFORMANCE_TEST=y hack/ginkgo-e2e.sh --ginkgo.focus'
abbr -a k8s-make-e2e 'bazel build //test/e2e:e2e.test_binary //vendor/github.com/onsi/ginkgo/ginkgo:ginkgo'

abbr -a kind-test-e2e 'make WHAT="test/e2e/e2e.test" && ./_output/bin/e2e.test -context kind-kind -ginkgo.focus="$FOCUS" -num-nodes 2'
abbr -a kind-test-e2e-rerun './_output/bin/e2e.test -context kind-kind -ginkgo.focus="$FOCUS" -num-nodes 2'
abbr -a kind-create-e2e-cluster 'kind create cluster --config $HOME/src/github.com/tallclair/k8s-devel/config/kind-e2e-config.yaml --image kindest/node:latest'

abbr -a k-use-ns 'kubectl config set-context --current --namespace'

# K8s deploy environment
abbr -a k8s-env 'echo $K8S_ENV; or echo default'
abbr -a k8s-env-small 'source $HOME/k8s/devel/config/config-small.sh && k8s-env'

# Go aliases
abbr -a graph-png "dot -Tpng -o /tmp/graph.png && google-chrome /tmp/graph.png"
abbr -a graph-svg "dot -Tsvg -o /tmp/graph.svg && google-chrome /tmp/graph.svg"
