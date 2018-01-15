#!/bin/bash
set -ex

TAGS="$(ls ci/ | grep Dockerfile | cut -d '.' -f2)"

[ $GITLAB_CI ] && REGISTRY=$CI_REGISTRY_IMAGE || REGISTRY=LuaJIT
[ $GITLAB_CI ] && docker login -u gitlab-ci-token -p $CI_BUILD_TOKEN $CI_REGISTRY_IMAGE

echo $(docker images -a)
for t in $TAGS; do
    IMG=$REGISTRY:$t
    TMP=$REGISTRY:tmp
    if [[ "$(docker images -q $IMG 2>/dev/null)" == "" ]]; then
        echo "----- Building $IMG -----"
        docker build --force-rm --rm=true -t $TMP -f ci/Dockerfile.$t .
        CID=$(docker run -dit $TMP bash -c "true")
        docker wait $CID
        docker export $CID | docker import - $IMG
        docker rm $CID
        docker rmi $TMP
        [ $GITLAB_CI ] && docker push $IMG
        echo "----- DONE $IMG -----"
    fi
done

DANGLING="$(docker images -f "dangling=true" -q)"
[[ -n $DANGLING ]] && docker rmi $DANGLING || true
