// Worktrunk activity tracking plugin for OpenCode (OpenCode v2 plugin API).
//
// Tracks OpenCode session activity per branch, showing status markers in `wt list`:
//   🤖 — agent is working
//   💬 — agent is waiting for input
//
// Ported from the v1 plugin installed by: wt config plugins opencode install
// (worktrunk v0.71.0 still ships the v1 shape, which OpenCode v2 refuses to load).

import type { Plugin } from "@opencode/plugin";
import { execFile } from "node:child_process";

function marker(...args: string[]): Promise<void> {
  return new Promise((resolve) => {
    // Errors are ignored on purpose, matching the v1 `|| true` behaviour.
    execFile("wt", ["config", "state", "marker", ...args], { timeout: 5_000 }, () => resolve());
  });
}

type StatusEvent = { data?: { status?: { type?: string } } };

export default {
  id: "worktrunk",
  async setup(ctx) {
    const controller = new AbortController();

    void (async () => {
      try {
        for await (const event of ctx.event.subscribe({ signal: controller.signal })) {
          switch (event.type) {
            case "session.status": {
              const status = (event as StatusEvent).data?.status?.type;
              await marker("set", status === "idle" ? "💬" : "🤖");
              break;
            }
            case "session.idle":
              await marker("set", "💬");
              break;
            case "session.deleted":
              await marker("clear");
              break;
          }
        }
      } catch {
        // Subscription ends when the controller aborts or the server shuts down.
      }
    })();

    return () => controller.abort();
  },
} satisfies Plugin.Plugin;
