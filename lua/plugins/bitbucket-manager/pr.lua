local Job = require("plenary.job")
local utils = require("plugins.bitbucket-manager.utils")

function tprint(tbl, indent)
  if not indent then
    indent = 0
  end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent + 1)
    elseif type(v) == "boolean" then
      print(formatting .. tostring(v))
    else
      print(formatting .. v)
    end
  end
end

local function define_state_highlights()
  vim.api.nvim_set_hl(0, "StateApproved", { fg = "#00FF00", ctermfg = 2 }) -- Green
  vim.api.nvim_set_hl(0, "StateRequestedChanges", { fg = "#FFFF00", ctermfg = 3 }) -- Yellow
  vim.api.nvim_set_hl(0, "StateDeclined", { fg = "#FF0000", ctermfg = 1 }) -- Red
  vim.api.nvim_set_hl(0, "StateUnknown", { fg = "#0000FF", ctermfg = 4 }) -- Blue
end
define_state_highlights()

-- Format the state text with highlight
local function format_state(state)
  -- If the state is nil or invalid, treat it as "Unknown"
  if not state then
    state = "Unknown"
  end

  local highlight_group
  local symbol

  if state == "Approved" then
    highlight_group = "StateApproved"
    symbol = "✓"
  elseif state == "Requested Changes" then
    highlight_group = "StateRequestedChanges"
    symbol = "⚠"
  elseif state == "Declined" then
    highlight_group = "StateDeclined"
    symbol = "✘"
  else
    highlight_group = "StateUnknown"
    symbol = "🥶"
  end

  -- Use the highlight group dynamically
  return string.format("%s %s", highlight_group, state, symbol)
end

-- Test the format_state function with some examples
print(format_state("Approved")) -- Should show green with ✓
print(format_state("Requested Changes")) -- Should show yellow with ⚠
print(format_state("Declined")) -- Should show red with ✘
print(format_state("Unknown")) -- Should show blue with 🥶
print(format_state(nil)) -- Should show blue with 🥶 (since it's treated as Unknown)

--PReviewer
local previewer = require("telescope.previewers").new_buffer_previewer({
  define_preview = function(self, entry, status)
    -- Schedule the preview update to run safely within Neovim's event loop
    vim.schedule(function()
      -- Extract the relevant information from the entry table
      local title = entry.value[1] or "No title" -- PR title
      local pr_id = entry.value[2] or "N/A" -- PR ID
      local description = entry.value[3] or "No description available" -- PR description (markdown content)
      local author_display_name = entry.value[4] or "Unknown author" -- PR author
      local pr_state = entry.value[5] or "Unknown state" -- PR state
      local pr_url = entry.value[6] or "N/A" -- PR URL
      local source_branch = entry.value[7] or "Unknown source branch" -- Source branch
      local destination_branch = entry.value[8] or "Unknown destination branch" -- Destination branch

      -- Metadata content with better formatting and separation
      local metadata = string.format(
        "PR Metadata\n=====================\n\n\n\n"
          .. "Title: %s\n"
          .. "ID: %s\n"
          .. "State: %s\n\n"
          .. "Author: %s\n"
          .. "Source Branch: %s\n"
          .. "Destination Branch: %s\n\n"
          .. "PR Link: %s\n\n\n\n"
          .. "Description\n=====================\n\n"
          .. "%s\n\n",
        title,
        pr_id,
        format_state(pr_state),
        author_display_name,
        source_branch,
        destination_branch,
        pr_url,
        description
      )

      -- Convert the metadata string into lines
      local metadata_lines = {}
      for line in metadata:gmatch("[^\n]+") do
        table.insert(metadata_lines, line)
      end

      -- Insert the formatted metadata into the buffer
      local bufnr = self.state.bufnr
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, metadata_lines)
    end)
  end,
})
--
-- local pr_list = {
--   { "Test2", 1, "Initial PR for testing." },
--   { "PR with special char å", 2, "This PR contains a special character." },
--   { "Fix issue with zero-width characters", 3, "Fixes zero-width space issue in PR titles." },
--   { "Update documentation", 4, "Improves the README file and updates doc links." },
--   { "Feature: New functionality", 5, "Adds a new feature for user authentication." },
-- }

-- Helper function to get the current repository slug (username/repo) from the current Git directory
local function get_git_repo_slug(callback)
  local repo_slug = nil

  -- Debug statement before job starts
  print("Starting git job to get URL...")

  Job:new({
    command = "git",
    args = { "remote", "get-url", "origin" },
    on_exit = function(j, return_val)
      if return_val == 0 then
        local url = j:result()[1]
        -- Debug statement to check URL
        print("URL retrieved: " .. url)
        -- Parse the URL to get the repo slug (username/repo)
        local _, _, username, repo = url:find("bitbucket.org[/:](.+)/(.+).git")
        if username and repo then
          repo_slug = username .. "/" .. repo
          -- Debug statement to check repo_slug
          print("Repo slug extracted: " .. repo_slug)
          -- Call the callback with the repo_slug once the job finishes
          callback(repo_slug)
        else
          print("Error: URL doesn't match the expected Bitbucket format.")
          callback(nil)
        end
      else
        print("Error: Not inside a Git repository or no origin remote configured.")
        callback(nil)
      end
    end,
  }):start()
end

local M = {}

-- List all PRs in the current Git repository
function M.list_prs()
  -- Debug statement before calling get_git_repo_slug
  print("Getting repo slug...")

  -- Use the callback to handle the result asynchronously
  get_git_repo_slug(function(repo_slug)
    -- Debug statement inside callback
    print("Callback called. Repo slug: " .. tostring(repo_slug))

    if not repo_slug then
      print("Unable to get the repository slug.")
      return
    end

    -- Construct the URL for the Bitbucket API
    local url = string.format("https://api.bitbucket.org/2.0/repositories/%s/pullrequests", repo_slug)

    -- Get the authorization token
    local headers = {
      Authorization = "Bearer " .. utils.get_api_token(),
    }

    -- Debugging: Print URL and headers
    print("Listing PRs... URL: " .. url .. " Headers: " .. vim.inspect(headers))

    -- Make the curl request to the Bitbucket API
    Job:new({
      command = "curl",
      args = { "-s", "-H", "Authorization: " .. headers.Authorization, url },
      on_exit = function(j, return_val)
        local result = j:result()

        -- Ensure the result is a string
        if type(result) == "table" then
          result = table.concat(result, "\n") -- Convert table to string
        end

        local pr_list = {}
        if return_val == 0 then
          -- Use vim.json.decode on the string
          local pr_data = vim.json.decode(result)
          if pr_data and pr_data.values then
            for _, pr in ipairs(pr_data.values) do
              -- Extract title, id, and description (default to "No description available" if description is nil)
              local title = pr.title
              local id = pr.id
              local description = pr.description or "No description available"
              local author_display_name = pr.author.display_name
              local pr_state = pr.state
              local source_branch = pr.source.branch.name
              local destination_branch = pr.destination.branch.name

              -- Insert the pr data into pr_list
              table.insert(
                pr_list,
                { id, title, description, author_display_name, pr_state, source_branch, destination_branch }
              )
            end
            print("Start here...")
            print(pr_list)
            print(format_state(pr_state))
            print("End here.....")
            -- Schedule the Telescope picker UI outside the job callback
            vim.schedule(function()
              -- Open a Telescope picker with the PR titles
              require("telescope.pickers")
                .new({}, {
                  prompt_title = "Bitbucket Pull Requests",

                  finder = require("telescope.finders").new_table({
                    results = pr_list,
                    entry_maker = function(entry)
                      return {
                        value = entry,
                        display = string.format(
                          "%s - %s %s",
                          entry[2], -- PR Title
                          entry[4], -- PR Author
                          format_state(entry[5]) -- Styled state
                        ),
                        ordinal = entry[2], -- Use the title for sorting
                      }
                    end,
                  }),

                  sorter = require("telescope.sorters").get_generic_fuzzy_sorter(),
                  previewer = previewer,
                  attach_mappings = function(prompt_bufnr, map)
                    map("i", "<CR>", function()
                      local selection = require("telescope.actions.state").get_selected_entry()
                      print("Selecting PR....")
                      print(vim.inspect(selection)) -- Use vim.inspect to print the selection table
                      -- Ensure you're accessing the PR ID and not an undefined index
                      print("PR ID: " .. selection.value[2]) -- Access PR ID from the selection value

                      -- Here, you could open the PR URL or display more details if needed
                      -- Example: You could open the PR URL using the PR ID
                      local pr_url = string.format(
                        "https://bitbucket.org/chapssrijan619/test_repo/pull-requests/%s",
                        selection.value[2]
                      )
                      print("Opening PR: " .. pr_url)
                      -- You can open the PR URL in a browser or perform other actions here
                    end)
                    return true
                  end,
                })
                :find()
            end)
          else
            print("No pull requests found.")
          end
        else
          print("Failed to fetch PRs.")
        end
      end,
    }):start()
  end)
end

return M
