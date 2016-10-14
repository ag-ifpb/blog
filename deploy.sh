#!/bin/bash
echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project.
/Volumes/MacintoshHDExt/ag.works/ari.workspace/repository/go/gopath/bin/hugo -t purehugo

# Go To Public folder
cd public

# Add changes to git.
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master
git subtree push --prefix=public https://github.com/ag-ifpb/blog.git gh-pages

# Come Back
cd ..
