#!/bin/bash

set -e # Exit on error

# Ensure required scripts are present
[[ -f "scripts/variables.sh" ]] || { echo "❌ Missing variables.sh"; exit 1; }
[[ -f "scripts/logger.sh" ]] || { echo "❌ Missing logger.sh"; exit 1; }

source "scripts/variables.sh"
source "scripts/logger.sh"


usage() {
    echo "Usage: $0 [-d] [-f <flavor>]"
    echo "  -d  Deploy"
    echo "  -f  Flavor (production, development)"
    exit 1
}

while getopts "df:" opt; do
    case $opt in
        d)
            need_deploy=true
            ;;
        f)
            flavor=$OPTARG
            ;;
        *)
            usage
            ;;
    esac
done


log_info "Pushing changes to remote repository... 🚀"

pubspec_path="$PROJECT_ROOT/pubspec.yaml"
version_line=$(grep "^version:" $pubspec_path)

if [[ -z "$version_line" ]]; then
    log_error "Version not found in pubspec.yaml ❌"
    exit 1
fi

version=$(echo "$version_line" | cut -d "+" -f 1 | awk '{print $2}')
build_number=$(echo "$version_line" | cut -d "+" -f 2)

if [[ -z "$build_number" ]]; then
    log_error "Build number not found in pubspec.yaml ❌"
    exit 1
fi

current_branch=$(git rev-parse --abbrev-ref HEAD)
if [[ -z "$current_branch" ]]; then
    log_error "Failed to get current branch name ❌"
    exit 1
fi

# Check if there are any changes to commit
if git diff-index --quiet HEAD --; then
    log_info "No changes detected in the repository."
    exit 0
fi
git add .
git commit -m "Version bump: $version"

tag=""
if [[ "$need_deploy" == true ]]; then
    tag+="deploy"
fi

git push -u origin $current_branch

if [[ -n "$tag" ]]; then
    tag+="-$flavor"
    tag+="-$version+$build_number"
    git tag "$tag"
    git push origin --tags
fi