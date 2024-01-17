#!/bin/bash

set -eou pipefail

NUM_TRIALS=10
ORIGINAL_SHA=08bc2d53579c9ab85415d4363888881b91df073b
MODIFIED_BUILD_TIMES=~/results/modified-builds.csv
MODIFIED_TEST_TIMES=~/results/modified-tests.csv
ORIGINAL_BUILD_TIMES=~/results/original-builds.csv
ORIGINAL_TEST_TIMES=~/results/original-tests.csv
HEADER="time,rss"
readonly NUM_TRIALS PREVIOUS_SHA MODIFIED_BUILD_TIMES MODIFIED_TEST_TIMES   \
         ORIGINAL_BUILD_TIMES ORIGINAL_TEST_TIMES HEADER

echo "$HEADER" > "$MODIFIED_BUILD_TIMES"
echo "$HEADER" > "$MODIFIED_TEST_TIMES"
echo "$HEADER" > "$ORIGINAL_BUILD_TIMES"
echo "$HEADER" > "$ORIGINAL_TEST_TIMES"

. python/_virtualenv3.9/bin/activate

x=0
while [[ "$x" -lt "$NUM_TRIALS" ]]; do
    x=$((x+1))
    echo "Trial ${x} / ${NUM_TRIALS}"

    echo "(Modified) Measuring build times..."
    git checkout --force master >/dev/null 2>/dev/null

    # Need to save our virtual environment because mach destroys it.
    cp -r python/_virtualenv3.9/ python/_virtualenv3.9_backup
    ./mach clean >/dev/null 2>/dev/null
    mv python/_virtualenv3.9_backup python/_virtualenv3.9/

    modified_build_result=$(/usr/bin/time -f'%e %M' ./mach build --dev 2>&1 >/dev/null | tail -n1)
    modified_build_time=$(echo "$modified_build_result" | cut -d' ' -f1)
    modified_build_rss=$(echo "$modified_build_result" | cut -d' ' -f2)
    echo "${modified_build_time},${modified_build_rss}" >> "$MODIFIED_BUILD_TIMES"

    echo "(Modified) Measuring test times..."
    modified_test_result=$(/usr/bin/time -f'%e %M' ./mach test unit 2>&1 >/dev/null | tail -n1)
    modified_test_time=$(echo "$modified_test_result" | cut -d' ' -f1)
    modified_test_rss=$(echo "$modified_test_result" | cut -d' ' -f2)
    echo "${modified_test_time},${modified_test_rss}" >> "$MODIFIED_TEST_TIMES"

    git checkout --force "$ORIGINAL_SHA" >/dev/null 2>/dev/null

    # Need to save our virtual environment because mach destroys it.
    cp -r python/_virtualenv3.9/ python/_virtualenv3.9_backup
    ./mach clean >/dev/null 2>/dev/null
    mv python/_virtualenv3.9_backup python/_virtualenv3.9/

    echo "(Original) Measuring build times..."
    original_build_result=$(/usr/bin/time -f'%e %M' ./mach build --dev 2>&1 >/dev/null | tail -n1)
    original_build_time=$(echo "$original_build_result" | cut -d' ' -f1)
    original_build_rss=$(echo "$original_build_result" | cut -d' ' -f2)
    echo "${original_build_time},${original_build_rss}" >> "$ORIGINAL_BUILD_TIMES"

    echo "(Original) Measuring test times..."
    original_test_result=$(/usr/bin/time -f'%e %M' ./mach test unit 2>&1 >/dev/null | tail -n1)
    original_test_time=$(echo "$original_test_result" | cut -d' ' -f1)
    original_test_rss=$(echo "$original_test_result" | cut -d' ' -f2)
    echo "${original_test_time},${original_test_rss}" >> "$ORIGINAL_TEST_TIMES"
done
