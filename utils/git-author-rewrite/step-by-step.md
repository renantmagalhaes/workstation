# GIT CLEANUP GUIDE

## STEP 1: PREPARE

git add .
git stash

## STEP 2: REWRITE

# Run your git-auth.sh script here

# Ensure it contains the 'git filter-branch -f' command

## STEP 3: VERIFY

git log -n 10 --format="%h | %an <%ae> | %s"

## STEP 4: PUSH & CLEAN

git push origin master --force
git stash pop
rm -rf .git/refs/original/
rm -rf .git-rewrite

## STEP 5: LOCK IDENTITY

git config user.name "Name"
git config user.email "<youremail@mail.com>"
