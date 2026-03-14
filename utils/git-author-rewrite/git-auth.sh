#!/bin/bash

# 1. Define the emails you want to swap
OLD_EMAIL="old@email.com"
CORRECT_NAME="You Name"
CORRECT_EMAIL="new@email.com"

# 2. Run the filter-branch command
# This iterates through every commit and replaces the metadata
git filter-branch --env-filter "
if [ \"\$GIT_COMMITTER_EMAIL\" = \"$OLD_EMAIL\" ]
then
    export GIT_COMMITTER_NAME=\"$CORRECT_NAME\"
    export GIT_COMMITTER_EMAIL=\"$CORRECT_EMAIL\"
fi
if [ \"\$GIT_AUTHOR_EMAIL\" = \"$OLD_EMAIL\" ]
then
    export GIT_AUTHOR_NAME=\"$CORRECT_NAME\"
    export GIT_AUTHOR_EMAIL=\"$CORRECT_EMAIL\"
fi
" --tag-name-filter cat -- --branches --tags
