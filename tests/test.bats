setup() {
  set -eu -o pipefail
  export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export TESTDIR=~/tmp/test-elasticsearch
  mkdir -p $TESTDIR
  export PROJNAME=test-elasticsearch
  export DDEV_NON_INTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}
  ddev start -y >/dev/null
}

health_checks() {
  # Check Elasticsearch health
  ddev exec "curl -s http://elasticsearch:9200" | grep "docker-cluster" || ( echo "Elasticsearch health check failed"; exit 1 )

  # Check Kibana health
  ddev exec "curl -s https://localhost:5601" | grep "Welcome to Kibana" || ( echo "Kibana health check failed"; exit 1 )
}

teardown() {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install Elasticsearch and Kibana addon from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ${DIR}
  ddev restart
  health_checks
}

@test "install Elasticsearch and Kibana addon from release" {
  set -eu -o pipefail
  cd ${TESTDIR} || ( printf "unable to cd to ${TESTDIR}\n" && exit 1 )
  echo "# ddev get ddev/ddev-elasticsearch-kibana with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev get ddev/ddev-elasticsearch-kibana
  ddev restart >/dev/null
  health_checks
}