// codegraph OpenCode plugin
// Injects a CodeGraph reminder before bash tool calls when the CodeGraph index exists.
import { existsSync } from "fs";
import { join } from "path";

export const CodegraphPlugin = async ({ directory }) => {
  let reminded = false;

  return {
    "tool.execute.before": async (input, output) => {
      if (reminded) return;
      if (!existsSync(join(directory, ".codegraph", "codegraph.db"))) return;

      if (input.tool === "bash") {
        output.args.command =
          'echo "[codegraph] CodeGraph index available. Prefer codegraph_search/codegraph_node/codegraph_callers before broad file scans." && ' +
          output.args.command;
        reminded = true;
      }
    },
  };
};