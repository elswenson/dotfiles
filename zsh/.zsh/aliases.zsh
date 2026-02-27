# Shared aliases loaded by ~/.zshrc.
# Add one alias per line.
#
# Examples:
# alias gs='git status'
# alias gc='git commit'


alias update-main='git fetch origin main:main'
alias merge-main='git fetch origin main:main && git merge main --no-commit'

alias lint-changed='files="$( { git diff --name-only HEAD -- "*.ts" "*.tsx"; git ls-files --others --exclude-standard -- "*.ts" "*.tsx"; } | awk "NF" | sort -u )"; [ -z "$files" ] && echo "No changed TypeScript files found." || { echo "$files" | xargs npx eslint --fix && echo "$files" | xargs npx prettier --write; }'
alias lint-changed-origin-main='files="$(git diff --name-only origin/main...HEAD -- "*.ts" "*.tsx" | awk "NF")"; [ -z "$files" ] && echo "No TypeScript files changed against origin/main...HEAD." || { echo "$files" | xargs npx eslint --fix && echo "$files" | xargs npx prettier --write; }'

alias peacock='peacock_apply_random_profile'
alias peacock-list='peacock_list_profiles'
alias peacock-apply='peacock_apply_profile'

