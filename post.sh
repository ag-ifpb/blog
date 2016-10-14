#!/bin/bash
echo -e "Criando nova postagem"

# create post.
/Volumes/MacintoshHDExt/ag.works/ari.workspace/repository/go/gopath/bin/hugo new "post/$1.md"

# edit page
nano content/post/$1.md

