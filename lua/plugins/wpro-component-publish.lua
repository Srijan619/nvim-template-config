-- Function to expand ~ to the full path
local function expand_home_directory(path)
  if path:sub(1, 1) == "~" then
    return vim.fn.expand("~") .. path:sub(2)
  end
  return path
end

local script_path = expand_home_directory("~/workspace/raw/wpro-component-publisher-agnostic/publish.js")

local function get_latest_yaml_file()
  local cwd = vim.fn.getcwd()
  local dist_path = cwd .. "/dist"
  local cmd =
    string.format("find %s -name '*.yaml' -type f -print0 | xargs -0 ls -t | head -n 1", vim.fn.shellescape(dist_path))

  local output = vim.fn.system(cmd)
  local exit_code = vim.v.shell_error

  if exit_code ~= 0 or output == "" then
    vim.api.nvim_err_writeln("Failed to find the latest YAML file in the dist directory.")
    return nil
  end

  -- Validate if output is an actual file path
  output = output:gsub("%s+$", "") -- Trim trailing newline

  -- Ensure the output points to a valid file
  if vim.fn.filereadable(output) == 0 then
    vim.api.nvim_err_writeln("No YAML file found at path: " .. output)
    return nil
  end

  return output
end

-- Lua function to run the Node.js script
local function run_publish_script(yaml_file_path)
  -- Determine the YAML file path to use
  if not yaml_file_path or yaml_file_path == "" then
    yaml_file_path = get_latest_yaml_file()
  end

  -- Check if the file path is valid
  if not yaml_file_path or yaml_file_path == "" then
    return
  end

  -- Ensure the file path is properly quoted
  local quoted_yaml_file_path = vim.fn.shellescape(yaml_file_path)
  local cmd = string.format("node %s %s", vim.fn.shellescape(script_path), quoted_yaml_file_path)

  -- Run the command
  local output = vim.fn.system(cmd)
  local exit_code = vim.v.shell_error

  if exit_code ~= 0 then
    vim.api.nvim_err_writeln("Failed to run publish script. Check your script and file path.\n" .. output)
  else
    vim.api.nvim_out_write("Publish script executed successfully.\n")
  end
end

-- Create a custom Neovim command to run the script
vim.api.nvim_create_user_command("PublishWellmoComponent", function(opts)
  run_publish_script(opts.args)
end, {
  nargs = "?", -- Make the argument optional
  complete = "file",
})

vim.api.nvim_set_keymap("n", "<leader>pwc", ":PublishWellmoComponent ", { noremap = true, silent = false })
