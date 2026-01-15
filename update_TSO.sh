#!/bin/bash

REPO_LIST="repos.txt"
BRANCH_NAME="update-tso-owner"
OLD_EMAIL="armando.vasquez@myob.com"
NEW_EMAIL="krish.seenivasan@myob.com"
COMMIT_MESSAGE="Update TSO owner from $OLD_EMAIL to $NEW_EMAIL"
PR_TITLE="Update TSO on SysCat"
PR_BODY="Summary:

- Replace TSO owner email from $OLD_EMAIL to $NEW_EMAIL
- Automated update across codebase"

PR_LINKS=()

while read REPO; do
  echo "========================================"
  echo "Processing repository: $REPO"
  echo "========================================"
  
  REPO_NAME="$(basename "$REPO" .git)"
  
  git clone "$REPO"
  cd "$REPO_NAME" || exit

  # Check if there are any files containing the old email
  if ! grep -rl "$OLD_EMAIL" . --exclude-dir=.git 2>/dev/null | head -1 | grep -q .; then
    echo "No files containing $OLD_EMAIL found in $REPO_NAME. Skipping..."
    cd ..
    rm -rf "$REPO_NAME"
    continue
  fi

  # Checkout new branch
  git checkout -b "$BRANCH_NAME"

  # Find and replace email in all files (excluding .git directory)
  echo "Replacing $OLD_EMAIL with $NEW_EMAIL..."
  
  # Use find + sed for cross-platform compatibility
  # For macOS, use sed -i '' and for Linux use sed -i
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    find . -type f -not -path './.git/*' -exec grep -l "$OLD_EMAIL" {} \; | while read file; do
      echo "  Updating: $file"
      sed -i '' "s/$OLD_EMAIL/$NEW_EMAIL/g" "$file"
    done
  else
    # Linux
    find . -type f -not -path './.git/*' -exec grep -l "$OLD_EMAIL" {} \; | while read file; do
      echo "  Updating: $file"
      sed -i "s/$OLD_EMAIL/$NEW_EMAIL/g" "$file"
    done
  fi

  # Check if there are any changes to commit
  if git diff --quiet; then
    echo "No changes detected in $REPO_NAME. Skipping..."
    cd ..
    rm -rf "$REPO_NAME"
    continue
  fi

  echo "Committing and pushing changes..."
  git add .
  git commit -m "$COMMIT_MESSAGE"
  git push --set-upstream origin "$BRANCH_NAME"
  
  echo "Creating pull request..."
  PR_URL=$(gh pr create --title "$PR_TITLE" --body "$PR_BODY" 2>&1)
  echo "PR created: $PR_URL"
  PR_LINKS+=("$REPO_NAME: $PR_URL")

  # Clean up resources
  cd ..
  rm -rf "$REPO_NAME"
  
  echo "Completed: $REPO_NAME"
  echo ""
done < "$REPO_LIST"

echo "========================================"
echo "All repositories processed!"
echo "========================================"

# Print all PR links
if [ ${#PR_LINKS[@]} -gt 0 ]; then
  echo ""
  echo "========================================"
  echo "Created Pull Requests:"
  echo "========================================"
  for pr in "${PR_LINKS[@]}"; do
    echo "$pr"
  done
  echo "========================================"
  echo "Total PRs created: ${#PR_LINKS[@]}"
  echo "========================================"
else
  echo ""
  echo "No PRs were created."
fi
