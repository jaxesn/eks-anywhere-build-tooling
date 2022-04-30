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

# BASE_DIRECTORY and RESULT_DIR set from env

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SCRIPT_NAME=$(basename "$0")

ARGS=""
for arg in "$@" 
do
    ARGS+="${arg#$BASE_DIRECTORY} "
done

echo ${ARGS} >> ${RESULT_DIR}/${SCRIPT_NAME}.log

if [ "${SCRIPT_NAME}" == "simple_create_binaries.sh" ]; then
    TARGET_FILE=$2
    ALL_TARGET_FILES=${13:-}
    # target file is meant to be treated as a folder since multiple binaries will written out
    if [[ "${TARGET_FILE}" == */ ]]; then
        TARGET_FILES=(${ALL_TARGET_FILES// / })
        mkdir -p ${TARGET_FILE}
        for file in ${TARGET_FILES[@]}; do touch ${TARGET_FILE}/${file}; done
    else
        mkdir -p $(dirname ${TARGET_FILE})
        touch $TARGET_FILE
    fi
elif [ "${SCRIPT_NAME}" == "go_mod_download.sh" ]; then
    REPO="$2"
    REPO_SUBPATH="${5:-}"
    mkdir -p ${REPO}/${REPO_SUBPATH}
elif [ "${SCRIPT_NAME}" == "create_attribution.sh" ]; then
    PROJECT_ROOT="$1"
    OUTPUT_DIR="$3"
    OUTPUT_FILENAME="$4"
    RELEASE_BRANCH="${5:-}"

    if [[ -n "$RELEASE_BRANCH" ]] && [ -d "$PROJECT_ROOT/$RELEASE_BRANCH" ]; then
        PROJECT_ROOT=$PROJECT_ROOT/$RELEASE_BRANCH
    fi

    touch ${PROJECT_ROOT}/${OUTPUT_FILENAME}
fi
