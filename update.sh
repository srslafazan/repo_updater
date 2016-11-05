#!/bin/bash

# TODO: async track changes and inform user of failures at finish

base_dirname=$PWD

# Options
sync=true # Enable to update synchronously
debug=true
quiet=true


# Helpers
git_checkout() {
  branch=${1:-master}
  git checkout $branch --quiet
}

git_is_unstaged() {
  return "$(git diff-index HEAD -- | echo $?)"
}

# Update Local Repository by Directory Name
# @param {$dirname}
update_repository() {
  repo_dirname="$1"
 
  echo; 
  
  cd $base_dirname/$repo_dirname && echo "[$repo_dirname] Starting update..." || echo "[$repo_dirname] failed to initiate (bash error $?)"
  
  # Check for unstaged changes and add/commit/checkout master
  unstaged="$(git_is_unstaged | echo $?)"
  if [ $unstaged -ne 0 ]; then 
    echo "[$repo_dirname] Adding changes..."
    git add .
    echo "[$repo_dirname] Committing changes..."
    git commit -m "Committed by update script to save your changes. Please git reset --soft HEAD~ to continue." --quiet
    git_checkout
    # echo "[$repo_dirname] failed to change branches (git error $?). Please check the repository and try again." && exit $?
  fi
 
  # Pull rebase
  echo "[$repo_dirname] Syncing with remote..."
  git_checkout

  git pull --rebase origin master --quiet
  if [ $? -eq 0 ]; then
    echo "[$repo_dirname] Done."
  else
    echo "[$repo_dirname] failed to pull changes (git error $?). Please check the repository and try again." && exit $?
  fi
}


# Start
echo "[Options] sync = $sync"
echo "[Options] debug = $debug"
echo "[Options] quiet = $quiet"

echo; echo "[Status] Starting repository updates...";

if [ $sync == true ]
  then
    update_repository "ClientAuth"
    update_repository "WebUtilsLibrary"
    update_repository "WebUILibrary"
    update_repository "WebConstantsLibrary"
    update_repository "WebPortal"
    update_repository "Clients"
    update_repository "Server"
  else
    eval update_repository "ClientAuth" &
    eval update_repository "WebUtilsLibrary" &
    eval update_repository "WebUILibrary" &
    eval update_repository "WebConstantsLibrary" &
    eval update_repository "WebPortal" &
    eval update_repository "Clients" &
    eval update_repository "Server"
  wait
fi

echo; echo "[Status] Done."; echo;
