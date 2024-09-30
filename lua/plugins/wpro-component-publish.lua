local uv = vim.loop

-- Function to expand ~ to the full path
local function expand_home_directory(path)
  if path:sub(1, 1) == "~" then
    return vim.fn.expand("~") .. path:sub(2)
  end
  return path
end

local script_path_dir = expand_home_directory("~/workspace/raw/wpro-component-publisher-agnostic/")
local script_path = expand_home_directory(script_path_dir .. "publish.js")
local env_path = expand_home_directory(script_path_dir .. ".env")

-- Function to get the latest YAML file from the dist directory
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

-- Function to run a command asynchronously with progress feedback
local function run_command_async(cmd, on_output, on_exit)
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)

  local handle, pid
  handle, pid = uv.spawn("bash", {
    args = { "-i", "-c", cmd },
    stdio = { nil, stdout, stderr },
  }, function(code, signal)
    stdout:read_stop()
    stderr:read_stop()
    stdout:close()
    stderr:close()
    handle:close()

    -- Safely call the exit callback
    vim.schedule(function()
      if on_exit then
        on_exit(code, signal)
      end
    end)
  end)

  if not handle then
    vim.schedule(function()
      vim.api.nvim_err_writeln("Error running command: " .. cmd)
    end)
    return
  end

  uv.read_start(stdout, function(err, data)
    assert(not err, err)
    if data then
      vim.schedule(function()
        if on_output then
          on_output(data)
        end
      end)
    end
  end)

  uv.read_start(stderr, function(err, data)
    assert(not err, err)
    if data then
      vim.schedule(function()
        if on_output then
          on_output(data)
        end
      end)
    end
  end)
end

-- Async function to build the component
local function npm_run_build_comp_async(build_dir, on_build_complete)
  if not build_dir or build_dir == "" then
    build_dir = vim.fn.getcwd()
  end

  if not build_dir or build_dir == "" then
    return
  end

  local command = "nvm use 14 && npm run build"
  vim.schedule(function()
    vim.api.nvim_out_write("Running npm run build...\n")
  end)

  run_command_async(command, function(output)
    vim.schedule(function()
      vim.api.nvim_out_write(output)
    end)
  end, function(exit_code)
    vim.schedule(function()
      if exit_code == 0 then
        vim.api.nvim_out_write("Npm run build executed successfully in: " .. build_dir .. "\n")
        -- Only run the publish script after build is complete and successful
        if on_build_complete then
          on_build_complete()
        end
      else
        vim.api.nvim_err_writeln("Failed to run build command. Check your script and file path.")
      end
    end)
  end)
end

-- Async function to run the publish script
local function run_publish_script_async(yaml_file_path)
  -- Determine the YAML file path to use
  if not yaml_file_path or yaml_file_path == "" then
    yaml_file_path = get_latest_yaml_file()
  else
    yaml_file_path = yaml_file_path .. "/dist"
  end

  -- Check if the file path is valid
  if not yaml_file_path or yaml_file_path == "" then
    return
  end

  local quoted_yaml_file_path = vim.fn.shellescape(yaml_file_path)
  vim.schedule(function()
    vim.api.nvim_out_write(string.format("Using dist yaml file: %s \n", quoted_yaml_file_path))
  end)

  local cmd = string.format(
    "nvm use 20 && node %s %s %s",
    "--env-file=" .. vim.fn.shellescape(env_path),
    vim.fn.shellescape(script_path),
    quoted_yaml_file_path
  )

  vim.schedule(function()
    vim.api.nvim_out_write("Running publish script...\n")
  end)

  run_command_async(cmd, function(output)
    vim.schedule(function()
      vim.api.nvim_out_write(output)
    end)
  end, function(exit_code)
    vim.schedule(function()
      if exit_code == 0 then
        vim.api.nvim_out_write("Publish script executed successfully.\n")
      else
        vim.api.nvim_err_writeln("Failed to run publish script.")
      end
    end)
  end)
end

-- Modified Neovim command to use async functions
vim.api.nvim_create_user_command("PublishWellmoComponent", function(opts)
  vim.schedule(function()
    vim.api.nvim_out_write("Executing publish wellmo component command.\n")
  end)
  -- First, build the component asynchronously
  npm_run_build_comp_async(opts.args, function()
    -- Then, after build completion, run the publish script
    run_publish_script_async(opts.args)
  end)
end, {
  nargs = "?", -- Make the argument optional
  complete = "file",
})

vim.api.nvim_set_keymap("n", "<leader>pwc", ":PublishWellmoComponent", { noremap = true, silent = false })
