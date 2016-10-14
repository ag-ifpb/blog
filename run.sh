#!/bin/bash
echo -e "Executando localmente"

# Build the project.
/Volumes/MacintoshHDExt/ag.works/ari.workspace/repository/go/gopath/bin/hugo server \
--theme=purehugo --buildDrafts
