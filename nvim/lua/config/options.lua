-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
vim.opt.wrap = true
vim.opt.foldmethod = "manual"

-- Codeium's AI-completion backend ships per-platform binaries. Hardcoding
-- "Darwin"/"arm64" here silently breaks the plugin on Windows and x86_64
-- Linux, so detect the platform at runtime instead.
local uname = vim.fn.system("uname -s"):gsub("%s+$", "")
local uname_m = vim.fn.system("uname -m"):gsub("%s+$", "")
vim.g.codeium_os = (uname:match("Darwin") and "Darwin")
  or (uname:match("MSYS") or uname:match("MINGW") or uname:match("CYGWIN") and "Windows")
  or "Linux"
vim.g.codeium_arch = (uname_m:match("aarch64") or uname_m:match("arm64")) and "arm64" or "x64"
