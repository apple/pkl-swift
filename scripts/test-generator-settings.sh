#!/usr/bin/env bash
# Copyright © 2026 Apple Inc. and the Pkl project authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -eu

repo_dir=$(cd "$(dirname "$0")/.." && pwd)
pkl_exec=${PKL_EXEC:-pkl}
work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

printf 'module Probe\nvalue = "ok"\n' > "$work_dir/Probe.pkl"
for name in plain 'with spaces' 'percent%hash#question?' '你好'; do
    mkdir "$work_dir/$name"
    (
        cd "$work_dir/$name"
        output=$("$pkl_exec" run --project-dir "$repo_dir/codegen/src" \
            "$repo_dir/codegen/src/gen.pkl" --dry-run "$work_dir/Probe.pkl")
        printf '%s\n' "$output" | grep -F '.out/Probe.pkl.swift'
        cat > generator-settings.pkl <<EOF
amends "$repo_dir/codegen/src/GeneratorSettings.pkl"
outputPath = "from-settings"
EOF
        output=$("$pkl_exec" run --project-dir "$repo_dir/codegen/src" \
            "$repo_dir/codegen/src/gen.pkl" --dry-run "$work_dir/Probe.pkl")
        printf '%s\n' "$output" | grep -F 'from-settings/Probe.pkl.swift'
        cat > explicit.pkl <<EOF
amends "$repo_dir/codegen/src/GeneratorSettings.pkl"
outputPath = "explicit"
EOF
        output=$("$pkl_exec" run --project-dir "$repo_dir/codegen/src" \
            "$repo_dir/codegen/src/gen.pkl" --generator-settings explicit.pkl \
            --dry-run "$work_dir/Probe.pkl")
        printf '%s\n' "$output" | grep -F 'explicit/Probe.pkl.swift'
    )
done
