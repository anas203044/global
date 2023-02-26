#!/bin/bash

# Set your GitHub username and PAT here
username="anas203044"
pat="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"

# Set the name and contents of the custom workflow file
workflow_file_name="custom-workflow.yml"

# Initialize the list of repositories
#repos_file=".github/repos.txt"
repos_file="./repos.txt"
if [ ! -f "$repos_file" ]; then
  touch "$repos_file"
fi
repos=$(cat "$repos_file")

# Get the updated list of repositories
updated_repos=$(curl -s -H "Authorization: token $pat" "https://api.github.com/users/$username/repos" | grep -oP '"full_name": "\K(.*)(?=")')

# Find any new repositories that have been added
new_repos=$(comm -23 <(echo "$updated_repos" | tr ' ' '\n' | sort) <(echo "$repos" | tr ' ' '\n' | sort))

# For each new repository, create the custom workflow file
for repo in $new_repos; do
  echo "Creating custom workflow file in $repo"
  curl -s -H "Authorization: token $pat" -H "Accept: application/vnd.github.v3+json" -X PUT -d "{\"path\": \".github/workflows/$workflow_file_name\", \"message\": \"Add custom workflow file\", \"content\": \"$(echo -n $'name: workflow \non: \n  push:\n    branches:\n      - master\nenv:\n  SONAR_TOKEN: squ_92ce500b4383353ef21219293c07ffff35128a09\n  SONAR_HOST_URL: http://54.73.70.164:9000\n\njobs:\n  build:\n    name: Build\n    runs-on: ubuntu-latest\n    steps:\n      - uses: anas203044/global/globalaction@main\n        with:\n          sonar-token: \${{ env.SONAR_TOKEN }}\n          sonar-host-url: \${{ env.SONAR_HOST_URL }}\n' | base64 | tr -d '\n')\"}" "https://api.github.com/repos/$repo/contents/.github/workflows/$workflow_file_name"
done

# Print a message if any new repositories were added
if [ -n "$new_repos" ]; then
  echo "New repositories added:"
  echo "$new_repos"

  # Update the list of repositories in the file
  echo "$updated_repos" > "$repos_file"
fi
