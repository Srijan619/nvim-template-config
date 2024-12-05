local M = {}

-- Command to list PRs
function M.list_prs()
  require("plugins.bitbucket-manager.pr").list_prs()
end

-- Command to view a PR
function M.view_pr()
  local pr_id = vim.fn.input("Enter PR ID: ")
  require("plugins.bitbucket-manager.pr").view_pr(pr_id)
end

-- Command to comment on a PR
function M.comment_on_pr()
  local pr_id = vim.fn.input("Enter PR ID: ")
  local comment = vim.fn.input("Enter comment: ")
  require("plugins.bitbucket-manager.pr").comment_on_pr(pr_id, comment)
end

-- Command to merge a PR
function M.merge_pr()
  local pr_id = vim.fn.input("Enter PR ID: ")
  require("plugins.bitbucket-manager.pr").merge_pr(pr_id)
end

-- Register commands in Neovim
vim.api.nvim_create_user_command("ListBitbucketPRs", M.list_prs, {})
vim.api.nvim_create_user_command("ViewBitbucketPR", M.view_pr, {})
vim.api.nvim_create_user_command("CommentBitbucketPR", M.comment_on_pr, {})
vim.api.nvim_create_user_command("MergeBitbucketPR", M.merge_pr, {})

return M
