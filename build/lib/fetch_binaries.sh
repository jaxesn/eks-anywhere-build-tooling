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


set -x
set -o errexit
set -o nounset
set -o pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "${SCRIPT_ROOT}/common.sh"

BINARY_DEPS_DIR="$1" 
BUILT_BINARY_DEPS_DIR="$2"
DEP="$3"
ARTIFACTS_BUCKET="$4"
LATEST_TAG="$5"
RELEASE_BRANCH="${6-$(build::eksd_releases::get_release_branch)}"

DEP=${DEP#"$BINARY_DEPS_DIR"}
OS_ARCH="$(cut -d '/' -f1 <<< ${DEP})"
PRODUCT=$(cut -d '/' -f2 <<< ${DEP})
REPO_OWNER=$(cut -d '/' -f3 <<< ${DEP})
REPO=$(cut -d '/' -f4 <<< ${DEP})
S3_ARTIFACTS_FOLDER_OVERRIDE=$(cut -d '/' -f5 <<< ${DEP})
ARCH="$(cut -d '-' -f2 <<< ${OS_ARCH})"
CODEBUILD_CI="${CODEBUILD_CI:-false}"

S3_ARTIFACTS_FOLDER=${S3_ARTIFACTS_FOLDER_OVERRIDE:-$LATEST_TAG}
GIT_COMMIT_OVERRIDE=false
if [ -n "$S3_ARTIFACTS_FOLDER_OVERRIDE" ]; then
    GIT_COMMIT_OVERRIDE=true
fi

OUTPUT_DIR_FILE=$BINARY_DEPS_DIR/linux-$ARCH/$PRODUCT/$REPO_OWNER/$REPO
if [[ $REPO == *.tar.gz ]]; then
    mkdir -p $(dirname $OUTPUT_DIR_FILE)
else
    mkdir -p $OUTPUT_DIR_FILE
fi

if [[ $PRODUCT = 'eksd' ]]; then
    if [[ $REPO_OWNER = 'kubernetes' ]]; then
        TARBALL="kubernetes-$REPO-linux-$ARCH.tar.gz"
        URL=$(build::eksd_releases::get_eksd_kubernetes_asset_url $TARBALL $RELEASE_BRANCH $ARCH)
        # these tarballs will extra with the kubernetes/{client,server} folders
        OUTPUT_DIR_FILE=$BINARY_DEPS_DIR/linux-$ARCH/$PRODUCT
    else
        URL=$(build::eksd_releases::get_eksd_component_url $REPO_OWNER $RELEASE_BRANCH $ARCH)
    fi
else
    URL=$(build::common::get_latest_eksa_asset_url $ARTIFACTS_BUCKET $REPO_OWNER/$REPO $ARCH $S3_ARTIFACTS_FOLDER $GIT_COMMIT_OVERRIDE)
fi

if [ "$CODEBUILD_CI" = "true" ]; then
    build::common::wait_for_tarball $URL
fi

DOWNLOAD_DIR=$(mktemp -d)
trap "rm -rf $DOWNLOAD_DIR" EXIT

FILENAME=$(basename $URL)

BUILT_FILE_PATH=$BUILT_BINARY_DEPS_DIR/$OS_ARCH/$PRODUCT/$REPO_OWNER/$REPO/$FILENAME

if [[ -f $BUILT_FILE_PATH ]]; then
    cp $BUILT_FILE_PATH $BUILT_FILE_PATH.sha256 $DOWNLOAD_DIR
else
    wget -q --retry-connrefused $URL $URL.sha256 -P $DOWNLOAD_DIR    
    (cd $DOWNLOAD_DIR && sha256sum -c $FILENAME.sha256)
fi

if [[ $REPO == *.tar.gz ]]; then
    mv $DOWNLOAD_DIR/$FILENAME $OUTPUT_DIR_FILE
else
    tar xzf $DOWNLOAD_DIR/$FILENAME -C $OUTPUT_DIR_FILE
fi
