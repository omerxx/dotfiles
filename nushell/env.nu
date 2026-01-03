# Nushell Environment Config File
#
# version = "0.95.0"

def create_left_prompt [] {
    let dir = match (do --ignore-errors { $env.PWD | path relative-to $nu.home-path }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($dir)"

    $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}

def create_right_prompt [] {
    # create a right prompt in magenta with green separators and am/pm underlined
    let time_segment = ([
        (ansi reset)
        (ansi magenta)
        (date now | format date '%x %X') # try to respect user's locale
    ] | str join | str replace --regex --all "([/:])" $"(ansi green)${1}(ansi magenta)" |
        str replace --regex --all "([AP]M)" $"(ansi magenta_underline)${1}")

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    ([$last_exit_code, (char space), $time_segment] | str join)
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = {|| create_left_prompt }
# FIXME: This default is not implemented in rust code as of 2023-09-08.
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {|| "> " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

# If you want previously entered commands to have a different prompt from the usual one,
# you can uncomment one or more of the following lines.
# This can be useful if you have a 2-line prompt and it's taking up a lot of space
# because every command entered takes up 2 lines instead of 1. You can then uncomment
# the line below so that previously entered commands show with a single `🚀`.
# $env.TRANSIENT_PROMPT_COMMAND = {|| "🚀 " }
# $env.TRANSIENT_PROMPT_INDICATOR = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = {|| "" }
# $env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = {|| "" }
# $env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# Directories to search for scripts when calling source or use
# The default for this is $nu.default-config-dir/scripts
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
    ($nu.data-dir | path join 'completions') # default home for nushell completions
]

# Directories to search for plugin binaries when calling register
# The default for this is $nu.default-config-dir/plugins
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')

if 'IN_NIX_SHELL' not-in $env and 'DEVBOX_SHELL_ENABLED' not-in $env {
    $env.PATH = ($env.PATH | append [
        /opt/homebrew/bin
        /run/current-system/sw/bin
        /Users/klaudioz/.local/bin
        /opt/homebrew/opt/ruby/bin
        /opt/homebrew/sbin
        /opt/homebrew/opt/libpq/bin
        /Users/klaudioz/.opencode/bin
        /Users/klaudioz/.npm-global/bin
        /Users/klaudioz/.bun/bin
        /Users/klaudioz/go/bin
        /Users/klaudioz/.cargo/bin
        "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
        /Applications/Cursor.app/Contents/Resources/app/bin
        /Applications/Windsurf.app/Contents/Resources/app/bin
    ])
}

# Load devbox environment if devbox is available
if (which devbox | is-not-empty) {
  devbox global shellenv --format nushell --preserve-path-stack -r
    | lines
    | parse "$env.{name} = \"{value}\""
    | where name != null
    | transpose -r
    | into record
    | load-env
}


# To load from a custom file you can use:
# source ($nu.default-config-dir | path join 'custom.nu')

def _ensure_cached_init [
  tool: string
  init_file: path
  stamp_file: path
  generator: closure
] {
  if (which $tool | is-empty) {
    return
  }

  let tool_path = (which $tool | get 0.path)
  let tool_info = (ls -l $tool_path | get 0)
  let tool_fingerprint = if $tool_info.type == "symlink" {
    $tool_info.target
  } else {
    $"($tool_info.name)@($tool_info.modified)"
  }

  let cached_fingerprint = if ($stamp_file | path exists) {
    open $stamp_file | str trim
  } else {
    ""
  }

  if ($init_file | path exists) and ($cached_fingerprint == $tool_fingerprint) {
    return
  }

  let init_dir = ($init_file | path dirname)
  if not ($init_dir | path exists) {
    mkdir $init_dir
  }

  let tmp_file = $"($init_file).tmp"
  try {
    do $generator | save --force $tmp_file
    mv -f $tmp_file $init_file
    $tool_fingerprint | save --force $stamp_file
  } catch {
    rm -f $tmp_file
  }
}

let cache_home = ($nu.home-path | path join ".cache")

_ensure_cached_init starship ($cache_home | path join "starship" "init.nu") ($cache_home | path join "starship" "init.stamp") {|| starship init nu }
_ensure_cached_init zoxide ($cache_home | path join "zoxide" "init.nu") ($cache_home | path join "zoxide" "init.stamp") {|| zoxide init nushell }
_ensure_cached_init carapace ($cache_home | path join "carapace" "init.nu") ($cache_home | path join "carapace" "init.stamp") {|| carapace _carapace nushell }
_ensure_cached_init atuin ($cache_home | path join "atuin" "init.nu") ($cache_home | path join "atuin" "init.stamp") {|| atuin init nu }

$env.STARSHIP_CONFIG = "/Users/klaudioz/.config/starship/starship.toml"
$env.NIX_CONF_DIR = "/Users/klaudioz/.config/nix"
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional

$env.EDITOR = "nvim"

let opencode_bin = ($nu.home-path | path join ".config" "opencode" "bin")
if ($opencode_bin | path exists) {
  $env.PATH = ($env.PATH | prepend $opencode_bin)
}

const opencode_secrets = ($nu.home-path | path join ".config" "opencode" "secrets.nu")
if ($opencode_secrets | path exists) {
  source $opencode_secrets
}

# Force Quotio models even when a project has its own `opencode.json` / `.opencode/` config.
$env.OPENCODE_CONFIG_CONTENT = '{"model":"quotio/gemini-claude-sonnet-4-5","small_model":"quotio/gemini-3-flash-preview"}'

# Ensure the Homebrew `opencode` launcher always runs our wrapper (for consistent env injection).
$env.OPENCODE_BIN_PATH = ($nu.home-path | path join ".config" "opencode" "bin" "opencode-wrapper")

# CLI Proxy API endpoint
$env.CLIPROXYAPI_ENDPOINT = "http://localhost:8317/v1"
