#!/bin/sh

set -eu

if [ "$#" -gt 0 ]; then
    versions="$*"
else
    versions="
1.8.8
1.9.4
1.10.2
1.11.2
1.12.2
1.13
1.13.2
1.14.4
1.15.2
1.16.1
1.16.3
1.16.5
1.17.1
1.18.1
1.18.2
1.19.2
1.19.3
1.19.4
1.20.1
1.20.2
1.20.4
1.20.6
1.21.1
1.21.3
1.21.4
1.21.5
1.21.8
1.21.9
1.21.10
1.21.11
"
fi

choose_java() {
    version=$1
    mc_major=$(printf '%s' $1 | cut -d . -f1)
    mc_minor=$(printf '%s' $1 | cut -d . -f2)
    mc_patch=$(printf '%s' $1 | cut -d . -f3)

    mc_major=${mc_major:-0}
    mc_minor=${mc_minor:-0}
    mc_patch=${mc_patch:-0}

    if [ "$mc_major" -ge 26 ]; then
        printf '25'
        return
    fi

    if [ "$mc_major" -eq 1 ] && { [ "$mc_minor" -ge 21 ] || { [ "$mc_minor" -eq 20 ] && [ "$mc_patch" -ge 5 ]; }; }; then
        printf '21'
        return
    fi

    if [ "$mc_major" -eq 1 ] && [ "$mc_minor" -ge 17 ]; then
        printf '17'
        return
    fi

    printf '8'
}

if ! command -v docker >/dev/null 2>&1; then
    printf '%s\n' 'Error: docker is not installed.'
fi

for version in $versions; do
    java=$(choose_java "$version")
    tag="docker.mrcubee.net/paper-$version"
    printf '==> Build %s (Java %s)\n' "$tag" "$java"
    docker build \
        --build-arg PAPER_VERSION="$version" \
        --build-arg JAVA_MAJOR="$java" \
        -t "$tag" .
    printf '==> Push %s\n' "$tag"
    docker push "$tag"
done
