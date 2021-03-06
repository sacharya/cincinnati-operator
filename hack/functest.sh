#!/bin/bash

set -e

# Override the image name when this is invoked from openshift ci
if [ -n "$OPENSHIFT_BUILD_NAMESPACE" ]; then
	CATALOG_FULL_IMAGE_NAME="registry.svc.ci.openshift.org/${OPENSHIFT_BUILD_NAMESPACE}/stable:cincinnati-operator"
	echo "Openshift CI detected, deploying using image $CATALOG_FULL_IMAGE_NAME"
fi

GOBIN="${GOBIN:-$GOPATH/bin}"
GINKGO=$GOBIN/ginkgo

if ! [ -x "$GINKGO" ]; then
	# The golang-1.13 image used in OpenShift CI enforces vendoring and go get is disabled.
	# Workaround that by unsetting GOFLAGS.
	export GOFLAGS=""
	echo "Retrieving ginkgo and gomega build dependencies"
	go get github.com/onsi/ginkgo/ginkgo
	go get github.com/onsi/gomega/...
else
	echo "GINKO binary found at $GINKGO"
fi


"$GOBIN"/ginkgo build functests/
# Run functional tests
"$GOBIN"/ginkgo functests
