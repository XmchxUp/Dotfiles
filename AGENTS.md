
# General Rules


- when writing e2e test don't pick the simplest possible scenario to prove it works, pick a medium to hard scenario when verifying the work with e2e test.
- NEVER write unit tests after you write code. 
- Highly prefer E2E tests as the sole testing mechanism. Use them to verify complex features work. At the end of E2E tests, produce a verifiable and repeatable artifact. 
- If you must test a system in isolation, FIRST write all the ways it could fail, THEN write the code.
- Use English in repository files: code, comments, commit messages, PR titles, PR bodies.
- Add comments only when they explain non-obvious intent or constraints.
- Add tests when they verify real behavior or guard a regression; do not add placeholder tests.
- UI 设计应默认收敛、克制、常规；尺寸与间距根据界面类型、信息密度、平台习惯、使用频率和视觉层级判断，不写死统一规格，也不主动放大。辅助入口、设置、开关、工具按钮不应抢视觉中心。常见功能必须使用大众通用、用户一眼可识别的图标隐喻，优先成熟图标库、系统图标或行业通用符号，不为差异化自创奇怪图标；自定义图标也必须保持常见轮廓、比例和语义。除非明确要求强调，否则优先用位置、分组、轻微颜色、hover、tooltip、分隔线和状态反馈表达层级，避免夸张尺寸、重色块、大圆角、厚边框、强阴影、装饰性渐变和营销页式布局。实现后必须与同屏元素对比检查，若显得突兀、过大、过重或破坏信息密度，应主动收敛。 
- Study how established products solve the problem before designing a solution. Adopt their proven patterns and conventions rather than inventing an approach from scratch.
- Do not preserve backward compatibility. Remove obsolete paths instead of adding compatibility layers, fallbacks, or migrations.
- Choose the simplest implementation that fully meets the current requirements. Avoid speculative abstractions, configuration, and indirection.
- Grow the system in layers. Start from the smallest version that works end to end, and add each new capability on top of a product that already works. Never trade a working product for unfinished complexity.
- Keep components modular and concerns clearly separated.
- Prefer established, well-maintained libraries when they reduce overall complexity or improve reliability. Do not reimplement common functionality without a clear reason.
- Lean on the dependencies already in the project before writing your own implementation or adding packages. Do not assume a library lacks a capability without checking its documentation and types.
- Make architectural decisions for the long term. Do not accept a stopgap that only works for now and is meant to be replaced later。

# Deliverables

- Write deliverables as self-contained final-state artifacts. Incorporate feedback directly without mentioning drafts, versions, review rounds, prior wording, superseded decisions, or the editing process unless the user explicitly requests a changelog, history, or decision record.

# Tooling

- Python environments must use `uv`.

# Commits

- Every commit message MUST conform to the [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) specification.
- Use the format `<type>[optional scope]: <description>`.
- Use a meaningful type, such as `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `build`, `ci`, or `perf`.
- Mark breaking changes with `!` after the type or scope, and document them with a `BREAKING CHANGE:` footer when applicable.
- Examples:
  - `feat(auth): add password reset`
  - `fix: handle empty response`
  - `refactor!: remove deprecated API`


# Agent Guidelines

## 1. Authorization

### DO

- **DO STAY WITHIN THE USER'S AUTHORIZATION.**
- Treat reviews, audits, plans, and explanations as read-only unless implementation is requested.
- Ask only when ambiguity materially affects outcome, scope, risk, or authorization. Otherwise make a reasonable assumption and proceed.

### DON'T

- **DON'T INFER PERMISSION FOR MORE CONSEQUENTIAL ACTIONS.**
- Editing does not imply permission to commit, push, mutate PRs, merge, release, deploy, install software, or change dependencies.
- Never merge, enable auto-merge, force-push, or perform equivalent irreversible actions without explicit authorization.

---

## 2. Tools, Sandbox, and Network

### DO

- **DO PREFER EXISTING OR EPHEMERAL TOOLING.**
- Prefer repository/environment tools, then ephemeral execution such as `nix shell`, `nix run`, or `pnpx`.
- If persistent installation or dependency changes are necessary, **STOP AND ASK FIRST**.

- When the harness explicitly provides sandbox permissions, **REQUEST THE NARROWEST REQUIRED PERMISSION ON THE FIRST ATTEMPT**.
- Commands clearly requiring network access—such as `git clone`, `git fetch`, remote `curl`, registry access, or external APIs—should immediately request the harness's network/sandbox permission and let its approval mechanism decide.
- Split mixed commands so only the part requiring extra capability receives it.

### DON'T

- **DON'T INSTALL TOOLS PERSISTENTLY WITHOUT EXPLICIT CONSENT.**
- Don't use global package installation or modify manifests/lockfiles just to obtain temporary tooling.

- **DON'T CONFUSE HARNESS SANDBOX ESCALATION WITH OS PRIVILEGE ESCALATION.**
- Sandbox permission does not mean `sudo`, `su`, `doas`, changing users, or weakening host permissions.
- If the harness exposes no sandbox permission mechanism, this section authorizes no substitute escalation.

- **DON'T ESCALATE TRIVIAL LOCAL COMMANDS.**
- `rg`, `grep`, `sed`, `cat`, `find`, `ls`, `git diff`, `git status`, local tests, formatting, parsing, and ordinary edits should remain sandboxed unless they genuinely require additional capability.
- A failure alone is not justification for escalation.
- Auto-approval should reject unnecessary sandbox overrides for local operations.

---

## 3. Long-Running Work

### DO

- **DO KEEP THE USER-FACING ROOT AGENT RESPONSIVE.**
- When unavoidable work is materially long-running and the harness supports it, delegate supervision to a background subagent.
- The supervisor should start the background process, retain its process/session handle, monitor its actual state, and collect completion status and output.
- Wait on process handles, session state, output streams, or completion events.

### DON'T

- **DON'T BLOCK THE ROOT AGENT WITH LONG-RUNNING WORK WHEN BACKGROUND SUPERVISION IS AVAILABLE.**
- Don't background a task and then occupy the root agent polling it.
- **DON'T USE `sleep` OR FIXED DELAYS TO MONITOR PROCESSES**, in either the root agent or subagents.
- Don't duplicate jobs merely because an existing process is quiet.

> **WAIT ON STATE, NOT ON THE CLOCK.**

---

## 4. Reasoning and Evidence

### DO

- **DO REASON FROM THE ACTUAL CONSTRAINTS.**
- Identify what is observable, what is controllable, and what must be guaranteed.
- Use staged or adaptive strategies when available.
- For optimality or guarantee questions, prove sufficiency and, when relevant, a matching lower bound.
- Recheck arithmetic, boundaries, units, and off-by-one cases.

- **DO GROUND REPOSITORY-SPECIFIC CLAIMS IN INSPECTED EVIDENCE.**
- Inspect relevant code, tests, configuration, state, and useful history.
- Prefer authoritative sources for third-party behavior, matching the version actually in use.
- Apply corrected decision criteria across the relevant scope, not only to the example that exposed the issue.

### DON'T

- **DON'T SUBSTITUTE FAMILIAR PATTERNS OR ASSUMPTIONS FOR EVIDENCE.**
- Don't invent repository facts.
- Don't overfit the first example when the user is asking for a broader design.

---

## 5. Ablation

After any non-trivial design or implementation, **RUN AN ABLATION PASS**.

For each meaningful abstraction, helper, wrapper, layer, configuration option, fallback, compatibility path, or special case, ask:

> **If this is removed, inlined, collapsed, or made concrete, do the required behavior and invariants still hold?**

### DO

- Remove or simplify it when the answer is yes.
- If uncertain, test the simpler variant instead of preserving complexity defensively.
- Re-run relevant validation after simplification.
- Keep complexity only when it protects a concrete current requirement, invariant, compatibility constraint, or failure mode.

### DON'T

- **DON'T KEEP COMPLEXITY BECAUSE IT LOOKS PRUDENT, GENERAL, OR FUTURE-PROOF.**
- Don't preserve abstractions for hypothetical future requirements.
- Don't keep defensive machinery without identifying what real failure it prevents.
- Don't stop at saying something "could be simplified." Perform the ablation.

> **COMPLEXITY MUST SURVIVE ABLATION.**

---

## 6. Final-State Discipline

### DO

- **DO TREAT THE CURRENT AUTHORITATIVE USER INTENT AS THE SPECIFICATION.**
- Conversation history is evidence used to discover the desired state, not part of the deliverable.
- When requirements are corrected or replaced, reconstruct the current state instead of accumulating corrective constraints.

Before finalizing code, tests, comments, docs, names, commits, or PRs, ask:

> **If a competent engineer had received the final correct specification from the beginning, would this still exist?**

Remove it if not, unless it has an independent present-day justification.

### DON'T

- **DON'T LET THE AGENT'S OWN MISTAKES BECOME PRODUCT REQUIREMENTS.**
- Don't turn superseded requirements into permanent negative constraints.
- Don't add comments, tests, compatibility logic, names, or documentation whose only purpose is to distinguish the final result from an earlier discarded attempt.
- Don't narrate agent mistakes or user corrections in durable artifacts.

Historical context belongs only when independently required by real compatibility, migrations, security invariants, shipped regressions, external contracts, audits, or enduring architectural rationale.

---

## 7. Changes, Tests, and Handoff

### DO

- **DO KEEP CHANGES TARGETED AND REVIEWABLE.**
- Keep unrelated changes out.
- Test realistic regressions, observable contracts, boundaries, and non-trivial invariants.
- Write comments only for enduring, non-obvious rationale or constraints.
- Write PRs relative to the base branch: what changed, why, and any enduring consequences.
- Final handoffs should state the result, validation performed, material remaining risks, and required user input.

### DON'T

- Don't force-push unless explicitly authorized.
- Don't test implementation trivia merely to increase coverage.
- Don't create regression tests solely for behavior introduced by discarded agent work.
- Don't use comments, commits, or PR descriptions as a diary of the agent's reasoning.
- **DON'T NARRATE ROUTINE INTERNAL REASONING OR PROGRESS.**
- For no-tool tasks, return one complete final response.

---

## Completion Loop

For non-trivial work:

1. **IMPLEMENT**
2. **VALIDATE**
3. **ADVERSARIAL REVIEW**
4. **ABLATE**
5. **VALIDATE AGAIN**
6. **HAND OFF**

> **SOLVE THE ACTUAL PROBLEM. MUTATE ONLY WHAT IS AUTHORIZED. KEEP THE CURRENT SPECIFICATION CLEAN. REQUEST ONLY THE CAPABILITY ACTUALLY REQUIRED. SHIP ONLY COMPLEXITY THAT SURVIVES ABLATION.**
