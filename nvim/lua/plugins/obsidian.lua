require("obsidian").setup({
  workspaces = {
    -- {
    --   name = "OmerVault",
    --   path = "/Users/omerhamerman/Obsidian/Omervault",
    -- },
    {
      name = "workshopvault",
      path = "~/Obsidian/workshopvault",
    }
  },
  completion = {
    nvim_cmp = true,
    -- Trigger completion at 2 chars.
    min_chars = 2,
    --  * "current_dir" - put new notes in same directory as the current buffer.
    --  * "notes_subdir" - put new notes in the default notes subdirectory.
    new_notes_location = "current_dir",
    -- 1. Whether to add the note ID during completion.
    -- E.g. "[[Foo" completes to "[[foo|Foo]]" assuming "foo" is the ID of the note.
    prepend_note_id = true,
  },
  mappings = {
    -- "Obsidian follow"
    ["<leader>of"] = {
      action = function()
        return require("obsidian").util.gf_passthrough()
      end,
      opts = { noremap = false, expr = true, buffer = true },
    },
    -- Toggle check-boxes "obsidian done"
    ["<leader>od"] = {
      action = function()
        return require("obsidian").util.toggle_checkbox()
      end,
      opts = { buffer = true },
    },
  },

  note_frontmatter_func = function(note)
    -- This is equivalent to the default frontmatter function.
    local out = { id = note.id, aliases = note.aliases, tags = note.tags, area = "", project = "" }

    -- `note.metadata` contains any manually added fields in the frontmatter.
    -- So here we just make sure those fields are kept in the frontmatter.
    if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
      for k, v in pairs(note.metadata) do
        out[k] = v
      end
    end
    return out
  end,

  templates = {
      subdir = "Templates",
      date_format = "%Y-%m-%d-%a",
      time_format = "%H:%M",
      tags = "",
  },
})
