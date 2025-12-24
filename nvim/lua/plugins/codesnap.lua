return {
  "mistricky/codesnap.nvim",
  build = "make",
  lazy = true,
  cmd = { "CodeSnap", "CodeSnapSave", "CodeSnapHighlight", "CodeSnapSaveHighlight" },
  opts = {
    watermark = "",
  },
}
