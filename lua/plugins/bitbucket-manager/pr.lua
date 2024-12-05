local Job = require("plenary.job")
local utils = require("plugins.bitbucket-manager.utils")

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

        if return_val == 0 then
          print("Pull Requests:")
          -- Use vim.json.decode on the string
          local pr_data = vim.json.decode(result)
          if pr_data and pr_data.values then
            local pr_list = {}
            -- Create a list of pull request titles and IDs for the picker
            for _, pr in ipairs(pr_data.values) do
              table.insert(pr_list, { pr.title, pr.id }) -- Proper format with 'title' and 'id'
            end

            -- Schedule the Telescope picker UI outside the job callback
            vim.schedule(function()
              -- Open a Telescope picker with the PR titles
              require("telescope.pickers")
                .new({}, {
                  prompt_title = "Bitbucket Pull Requests",
                  finder = require("telescope.finders").new_table({
                    results = pr_list,
                  }),
                  sorter = require("telescope.sorters").get_generic_fuzzy_sorter(),
                  attach_mappings = function(prompt_bufnr, map)
                    map("i", "<CR>", function()
                      local selection = require("telescope.actions.state").get_selected_entry()
                      print("Opening PR ID: " .. selection[2]) -- Use selection[2] for the PR ID
                      -- Here, you could open the PR URL or display more details if needed
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

-- View details of a specific PR
function M.view_pr(pr_id)
  local repo_slug = get_git_repo_slug()
  if not repo_slug then
    print("Unable to get the repository slug.")
    return
  end

  local url = string.format("https://api.bitbucket.org/2.0/repositories/%s/pullrequests/%s", repo_slug, pr_id)

  local headers = {
    Authorization = "Bearer " .. utils.get_api_token(),
  }

  Job:new({
    command = "curl",
    args = { "-s", "-H", "Authorization: " .. headers.Authorization, url },
    on_exit = function(j, return_val)
      local result = j:result()
      if return_val == 0 then
        local pr_data = vim.fn.json_decode(result)
        print(
          string.format(
            "Title: %s\nDescription: %s\nCreated by: %s",
            pr_data.title,
            pr_data.description,
            pr_data.author.display_name
          )
        )
        print("Reviewers:")
        for _, reviewer in ipairs(pr_data.reviewers) do
          print("- " .. reviewer.display_name)
        end
      else
        print("Failed to fetch PR details.")
      end
    end,
  }):start()
end

-- Comment on a PR
function M.comment_on_pr(pr_id, comment)
  local repo_slug = get_git_repo_slug()
  if not repo_slug then
    print("Unable to get the repository slug.")
    return
  end

  local url = string.format("https://api.bitbucket.org/2.0/repositories/%s/pullrequests/%s/comments", repo_slug, pr_id)

  local headers = {
    Authorization = "Bearer " .. utils.get_api_token(),
    Content_Type = "application/json",
  }

  local body = string.format('{"content": {"raw": "%s"}}', comment)

  Job:new({
    command = "curl",
    args = {
      "-X",
      "POST",
      "-s",
      "-H",
      "Authorization: " .. headers.Authorization,
      "-H",
      "Content-Type: " .. headers.Content_Type,
      "-d",
      body,
      url,
    },
    on_exit = function(j, return_val)
      if return_val == 0 then
        print("Comment posted successfully.")
      else
        print("Failed to post comment.")
      end
    end,
  }):start()
end

-- Merge a PR
function M.merge_pr(pr_id)
  local repo_slug = get_git_repo_slug()
  if not repo_slug then
    print("Unable to get the repository slug.")
    return
  end

  local url = string.format("https://api.bitbucket.org/2.0/repositories/%s/pullrequests/%s/merge", repo_slug, pr_id)

  local headers = {
    Authorization = "Bearer " .. utils.get_api_token(),
    Content_Type = "application/json",
  }

  Job:new({
    command = "curl",
    args = {
      "-X",
      "POST",
      "-s",
      "-H",
      "Authorization: " .. headers.Authorization,
      "-H",
      "Content-Type: " .. headers.Content_Type,
      url,
    },
    on_exit = function(j, return_val)
      if return_val == 0 then
        print("PR merged successfully.")
      else
        print("Failed to merge PR.")
      end
    end,
  }):start()
end

return M
