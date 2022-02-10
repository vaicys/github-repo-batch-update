# GitHub Repository Batch Update

Helper script for batch updating repositories in a single organization.
At the time of the creation of this script, there were no tools for multiple repository policy management at organization or team level.

Instructions:

1. Review and update variables (lines 1-5)
2. Review JSON files, these parameters will be applied to all repositories/branches
3. `$ .\repo-batch-update.ps1`

Note: due to limitation of GitHub API, protection settings can only be applied to existing branches.
