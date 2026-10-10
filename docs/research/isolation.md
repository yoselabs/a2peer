# Advisor isolation — research

Date: 2026-10-10. Confidence tags: **[P]** verified from primary source (vendor docs, repo, local `--help`), **[S]** secondary source, **[I]** inference, **[L]** observed locally.

## Local state and CLI constraints

- Mac [L]: macOS 26.6.2 arm64; Docker 29.4.0 via **OrbStack** 2.2.3; `sandbox-exec` present; no Apple `container`, `srt`, `bwrap`; codex 0.162.1, grok 1.0.50.
- No `~/.codex/auth.json` → Codex login sits in the macOS keychain [I]. `~/.grok` has no `auth.json`/`sessions/` → Grok not logged in yet [L].
- Grok sessions are stored under `$GROK_HOME/sessions/<url-encoded-cwd>/<id>/` [P]; whether `-r <uuid>` is cwd-scoped is not stated [I]. Either way **mount the repo at the same absolute path in every call**: it also keeps relative paths identical to the caller's.
- Grok: a session keeps its `--sandbox` profile; resuming with a different one is refused [P]. Pick the profile once.
- Grok docs advise a read-only `~/.grok` for containers, but then "session persistence fails silently" [P]. Multi-turn needs `GROK_HOME` **writable**.
- Codex `--sandbox read-only | workspace-write | danger-full-access`; the last is "intended solely for running in environments that are externally sandboxed" [P, `codex exec --help`].

## Approaches (Q1 + Q2)

| Approach | RO repo, no copy | Scratch writes | Persistent session + auth | Network allowlist | Per-call overhead | stdio child of MCP | OS | Maturity |
|---|---|---|---|---|---|---|---|---|
| Docker/OrbStack container | ✅ `-v repo:repo:ro` | ✅ volume/tmpfs | ✅ named volumes for `CODEX_HOME`/`GROK_HOME` | via egress-proxy sidecar on an internal network | low with `docker exec` into a long-lived container [I] | ✅ `docker exec -i` | both | high |
| Docker + gVisor (`runsc`) | ✅ | ✅ | ✅ | same as Docker | low–medium [I] | ✅ | Linux only | high |
| Apple `container` | bind mounts likely, `:ro` not documented [P/I] | ✅ | ✅ | not documented [P] | lightweight VM [P]; per-container not stated [I] | probably [I] | macOS 26 only | young, product versions [P] |
| Docker Sandboxes (`sbx`) | primary workspace is RW; `:ro` only for extra mounts; clone mode = copy [S/P] | ✅ | state persists until `sbx rm` [P] | ✅ host proxy policies [P] | microVM [P] | unclear (`sbx exec` only in 3rd-party docs) [S] | mac/Win; Linux unclear [S] | new (2026) |
| `srt` (Seatbelt / bwrap) | ✅ path allowlist | ✅ `allowWrite` | ✅ host home | ✅ domain allowlist proxy [P] | ~0 [I] | ✅ prefix the command [P] | both | "Beta Research Preview" [P] |
| Codex built-in sandbox | ✅ (runs on host) | `workspace-write` + `--add-dir` | ✅ | ✅ with `features.network_proxy` profile [P] | 0 | ✅ | both | permission profiles are Beta [P] |
| Grok built-in sandbox | ✅ (runs on host) | `~/.grok`, `/tmp` | ✅ | ❌ on/off only, and **no-op on macOS** [P] | 0 | ✅ | both | built-in profiles fail **open** [P] |
| bwrap / nsjail / Firecracker / devcontainers | Linux-only or Docker-adjacent; see verdicts | | | | | | | |

### Vendor sandbox details

- **Codex** [P]: Seatbelt on macOS; bwrap + seccomp (Landlock fallback) on Linux. If it cannot enforce, it "refuses to run the command" → **fails closed**. Permission profiles support filesystem `deny` (e.g. `~/.ssh`, `**/*.env`) and domain allow/deny, but only when `features.network_proxy = true`. Without the proxy, domain rules do nothing.
- **Grok** [P]: Seatbelt on macOS; Landlock + seccomp, plus bwrap for read-deny, on Linux. Profiles: `workspace`, `read-only`, `strict`, `devbox`. Only `strict` limits home reads (cwd, system, `~/.grok`). Child-network blocking is a no-op on macOS. A built-in profile that can't apply → "warns and continues unenforced" → **fails open**. A custom profile in `sandbox.toml` refuses to start instead (fails closed).
- Both also have tool-level rules that work without any kernel support: Grok `--deny`/`--disallowed-tools`; Codex profile `deny` entries [P]. Policy, not a boundary.

## Verdicts

| Option | Verdict | Reason |
|---|---|---|
| Docker container (OrbStack on Mac, Docker on Linux), long-lived per advisor | ✅ use | Only option that meets every rule on both hosts: RO bind at the same path, writable auth/session volumes, no host home visible at all. Mature. |
| + gVisor on homelab, untrusted harness only | ✅ use | Containers share a kernel. gVisor adds a syscall boundary for the DeepSeek-class harness. |
| Codex `--sandbox read-only` / Grok `--sandbox strict` inside the container | untested | Probably can't nest: bwrap needs user namespaces, which Docker's default seccomp blocks [I]. Codex would then refuse every command; Grok would run unenforced. Spike 1. |
| Codex / Grok built-in sandbox alone on the host | ❌ reject | No built-in Grok profile meets both rules: `read-only` keeps the repo RO but reads all of `~`; `strict` limits reads but lets the agent write CWD, which is the repo [P]. Grok also has no macOS network control and fails open. Codex profiles are Beta. Two policies for two vendors, none for a third. |
| `srt` | ❌ reject (as primary) | Reads allowed by default (deny-list model): a missed path leaks. Seatbelt can't nest, so the vendor sandboxes go off [I]. Keychain-based Codex auth would need mach/securityd holes [I]. Beta. Plan B for the Mac if Docker is ever absent. |
| Raw `sandbox-exec` | ❌ reject | Hand-written SBPL on a deprecated API, macOS only, no domain allowlist. |
| Docker Sandboxes (`sbx`) | ❌ reject | Primary workspace is RW and clone mode is a copy (copy was rejected). Docs describe proxy credential injection; subscription OAuth not covered [I]. Linux host support unclear. |
| Apple `container` | ❌ reject | macOS only → no parity with the homelab. Read-only mounts and network policy not documented. Not installed. |
| bwrap / nsjail | ❌ reject | Linux only → no parity. Docker already gives the same namespaces. |
| Firecracker | ❌ reject | Needs a block-device or virtiofs setup for the live repo; heavy for one advisor; Linux only. gVisor covers the threat for less. |
| Devcontainers | ❌ reject | A spec for IDEs on top of Docker; adds nothing for a headless child process. |

## Recommended design

Same mechanism on both hosts: **one long-lived Docker container per advisor vendor**, with the Python MCP server running `docker exec -i <advisor> codex exec resume …` per call.

- Repo: `-v /abs/repo:/abs/repo:ro`, the same absolute path (Grok session lookup, relative paths). Mask in-repo secrets with an empty bind over `.env*` files.
- Scratch: per-advisor volume at `/scratch`, `TMPDIR=/scratch`, working dirs for advisor scripts.
- State: named volume per vendor for `CODEX_HOME` / `GROK_HOME`, writable. Never mount the host `~/.codex` or `~/.grok`.
- Run as a non-root uid with `--read-only` rootfs, `--cap-drop ALL`, `--security-opt no-new-privileges`, and a pids/memory limit.
- Network: an internal Docker network with no default route. A small egress proxy container on it allows CONNECT only to vendor domains. Set `HTTPS_PROXY` in the advisor container. A CLI that ignores the proxy fails closed.
- On the Mac, OrbStack's Linux VM is a second wall between the advisor and macOS [I].
- **Untrusted harness:** homelab only, `--runtime=runsc`. OrbStack bind mounts are how Mac files enter its VM, so a container→VM escape reaches the Mac [I]. The owner already treats that harness as unsafe on the host, which is consistent.
- Overhead: `docker exec` adds roughly 50–150 ms per call [I]; there is no boot per call.

## Auth inside containers (Q3)

- **Codex** [P]: `codex login --device-auth` works headless, but device-code login must first be **enabled in ChatGPT security settings** (owner action). Inside the container, set `cli_auth_credentials_store = "file"` so `auth.json` lands in the volume. Tokens refresh during use. OpenAI also documents copying `auth.json` in via `docker cp`. The host keychain login can't be shared.
- **Grok** [P]: `grok login --device-auth` is documented explicitly "for headless environments (SSH sessions, Docker containers, remote VMs)". Credentials go to `$GROK_HOME/auth.json` (0600) and refresh in the background, with a 401 → refresh → retry. The volume must be writable.
- **Terms: unverified.** Both vendors document the container and remote case. I did not read the OpenAI or xAI consumer terms on automated or server use of a subscription login. OpenAI's auth docs recommend API keys for automation and say not to expose Codex execution in untrusted or public environments [P]. Open question for the owner.
- **Endpoints:** inferred (`chatgpt.com`, `auth.openai.com`, `api.openai.com`; `grok.com`, `auth.x.ai`, `api.x.ai`, `accounts.x.ai`) [I]. Spike 3 confirms them from proxy logs.

## Defense in depth (Q4)

| Layer | Stops | Status |
|---|---|---|
| Container: RO mount, no home, non-root, egress proxy | writes to repo or host, secret reads, roaming, exfil to arbitrary hosts | primary wall |
| gVisor (homelab, untrusted harness) | kernel exploits | second wall |
| Vendor sandbox inside the container | redundant on files; adds Codex domain rules | untested (spike 1). Fallback: `codex --sandbox danger-full-access`, `grok --sandbox off` (both vendors document this for external sandboxes) |
| Vendor tool rules (`--deny`, profile `deny`) | the agent *attempting* edits; cleaner errors | ✅ cheap, policy only |
| `git status --porcelain` + HEAD + stash hash before/after each call | tripwire if the RO mount is ever misconfigured | ✅ cheap; set `GIT_OPTIONAL_LOCKS=0` |

Git note: a RO repo owned by a different uid raises "dubious ownership". Run the container with the owner's uid, or set `safe.directory` in the container's gitconfig.

## Spikes, in order

1. **Nesting:** on OrbStack and on the homelab, in a plain container, does `codex exec --sandbox read-only` manage to run `ls`? Does `grok --sandbox strict` enforce or warn? Decides whether vendor sandboxes stay on.
2. **Auth + resume:** device-code login into the `CODEX_HOME` / `GROK_HOME` volumes, then two `docker exec` calls that resume the same session. Restart the container and resume again. Check Grok's leader daemon (`~/.grok/leader.sock`) in a long-lived container.
3. **Egress allowlist:** do both CLIs honor `HTTPS_PROXY` (Codex Rust, Grok Rust)? Log the domains each one hits. Confirm `curl example.com` from advisor bash is blocked.
4. **RO repo:** uid mismatch, `git log/diff/status` on the RO mount, `.env` masking, a write attempt fails, and relative paths in answers match the caller's.
5. **Latency:** time `docker exec` against a native call over 20 calls.
6. **gVisor** on the homelab with the untrusted harness: runs, network allowlist holds.

## Sources

- Grok: `github.com/xai-org/grok-build` user guide (auth, headless, sessions, sandbox); local copy `~/.grok/docs/user-guide/`.
- Codex: `learn.chatgpt.com` docs (auth, sandboxing, permissions); `codex exec --help`.
- srt: `github.com/anthropic-experimental/sandbox-runtime`. Docker Sandboxes: `docs.docker.com/ai/sandboxes/` + third-party guides. Apple: `github.com/apple/container`.
