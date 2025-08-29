#!/bin/sh

set -eu

if [ "$#" -gt 0 ]; then
    versions="$*"
else
    versions="
1.8
1.8.3
1.8.8
1.9.2
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
"
fi

choose_java() {
    version=$1
    mc_minor=$(printf '%s' $1 | cut -d . -f2)
    case "$mc_minor" in
        ''|*[!0-9]*) mc_minor=21 ;;
    esac
    if [ "$mc_minor" -le 16 ]; then
        printf '8'
    elif [ "$mc_minor" -le 20 ]; then
        printf '17'
    elif [ "$mc_minor" -le 21 ]; then
        printf '21'
    fi
}


if ! command -v docker >/dev/null 2>&1; then
    printf '%s\n' 'Error: docker is not installed.'
fi

for version in $versions; do
    java=$(choose_java "$version")
    tag="docker.mrcubee.net/paper-$version"
    printf '==> Build %s (Java %s)\n' "$tag" "$java"
    docker build \
        --build-arg SPIGOT_VERSION="$version" \
        --build-arg JAVA_MAJOR="$java" \
        -t "$tag" .
    printf '==> Push %s\n' "$tag"
    docker push "$tag"
done
