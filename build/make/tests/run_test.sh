#!/usr/bin/env bash
# Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

SAVE_EXPECTED=true

TEST_ROOT=$(mktemp -d)

mkdir -p ${TEST_ROOT}/release/1-22/development
touch ${TEST_ROOT}/release/SUPPORTED_RELEASE_BRANCHES
echo "1-22" > ${TEST_ROOT}/release/DEFAULT_RELEASE_BRANCH
echo "1" >  ${TEST_ROOT}/release/1-22/development/RELEASE
echo "base-tag" > ${TEST_ROOT}/EKS_DISTRO_MINIMAL_BASE_TAG_FILE
echo "base-git-tag" > ${TEST_ROOT}/EKS_DISTRO_MINIMAL_BASE_GIT_TAG_FILE

mkdir -p ${TEST_ROOT}/build/lib
for script in "update-attribution-files/create_pr.sh" "lib/wait_for_tag.sh" \
    "lib/go_mod_download.sh" "lib/simple_create_binaries.sh" "lib/validate_checksums.sh" \
    "lib/gather_licenses.sh" "lib/create_attribution.sh" "lib/buildkit.sh" "lib/fetch_binaries.sh" \
    "lib/simple_create_tarballs.sh" "lib/create_release_checksums.sh" "lib/validate_artifacts.sh" \
    "lib/upload_artifacts.sh" "../release/s3_sync.sh"; do
    SCRIPT_PATH=${TEST_ROOT}/build/$script
    mkdir -p $(dirname ${SCRIPT_PATH})
    cp ${SCRIPT_ROOT}/tracking_script.sh ${SCRIPT_PATH}
done

REPO_ROOT=$(git rev-parse --show-toplevel)
cp ${REPO_ROOT}/Common.mk ${TEST_ROOT}

PROJECT_DIR=${TEST_ROOT}/projects/aws/make-test
mkdir -p ${PROJECT_DIR}
cp ${SCRIPT_ROOT}/Makefile ${PROJECT_DIR}

TESTS=(
    # 1 binary, 1 image
    "single-binary" \
    # 2 binary, 2 images
    "two-binaries" \
    # 2 binaries, different go mods, multiple licenses and attribution (ex: tink/actions)
    "multiple-go-mods" \
    # mix of same and different go mod paths with name override (ex: capi)
    "go-mod-override" \
    # license filter override, go mod override
    "license-filter-override"
    # override base image for specific image, additional build-args
    "base-image-override"
    # fetch-binaries for specific image
    "fetch-binaries"
    # has s3 artifacts, no images
    "has-s3-artifacts"
)

for test in ${TESTS[@]}; do
    cp ${SCRIPT_ROOT}/cases/${test}/Override.mk ${TEST_ROOT}
    RESULTS_DIR=${TEST_ROOT}/results/${test}
    EXPECTED_DIR=${SCRIPT_ROOT}/expected/${test}

    mkdir -p ${RESULTS_DIR}
    export RESULT_DIR=${RESULTS_DIR}
    export BASE_DIRECTORY=${TEST_ROOT}

    make -C ${PROJECT_DIR} build GIT_HASH=override-hash

    if $SAVE_EXPECTED; then
        mkdir -p ${EXPECTED_DIR}
        cp ${RESULTS_DIR}/* ${EXPECTED_DIR}
    fi

    diff ${RESULTS_DIR} ${EXPECTED_DIR}

    make -C ${PROJECT_DIR} clean GIT_HASH=override-hash

done
