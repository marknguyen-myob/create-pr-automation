
REPO_LIST="repos.txt"
NEW_FILE="./CODEOWNERS"
BRANCH_NAME="CPD-367-add-CODEOWNERS"
COMMIT_MESSAGE="CPD-367: Add CODEOWNERS file"
PR_TITLE="CPD-367: Add CODEOWNERS file"
PR_BODY="Jira card: https://arlive.atlassian.net/browse/CPD-367
Summary:

- Standardize the git practice
- Get notified about any code changes"

while read REPO; do
  echo "Processing repository: $REPO"
  
  git clone "$REPO"
  cd "$(basename "$REPO" .git)" || exit

  # Checkout branch
  git checkout -b "$BRANCH_NAME"

  echo "Creating CODEOWNERS file..."
  if [ ! -d ".github" ]; then
    mkdir -p ".github"
  fi

  cp "../$NEW_FILE" ".github/CODEOWNERS"

  echo "current directory: $(pwd)"
  git add .
  git commit -m "$COMMIT_MESSAGE"
  git push --set-upstream origin "$BRANCH_NAME"
  gh pr create --title "$PR_TITLE" --body "$PR_BODY"

  # clean up resources
  cd ..
  rm -rf "$(basename "$REPO" .git)"
done < "$REPO_LIST"