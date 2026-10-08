---
name: handoff
description: Generate a context handoff prompt for starting a new session when the context limit is nearly reached
argument-hint: "[--with-snippets] [additional_instructions]"
---

# Session Handoff Generator

Generate a concise handoff prompt that captures the essential context for continuing work in a new Claude Code session.

## Arguments

$ARGUMENTS

**Flags:**
- `--with-snippets` - Include critical code snippets in the handoff

**Additional Instructions:**
Any other text in the arguments will be treated as additional context or instructions for generating the handoff (e.g., "focus on the authentication refactor" or "emphasize the performance issues").

---

## Instructions for Claude

### Step 0: Parse Arguments

Check if the arguments contain:
- `--with-snippets` flag - if yes, include code snippets in Step 3
- Any additional instructions - if yes, incorporate them when generating the handoff (give extra attention to those areas)

### Step 1: Gather Current State

**Run these commands in parallel** to understand the current state:

```bash
git branch --show-current
git status --short
git diff --stat
```

### Step 2: Review Recent Context

- Scroll through the **last 10-15 user messages** and your responses
- Identify the specific task currently being worked on
- Note any errors, test failures, or blockers encountered
- Identify which files are central to the current work (3-5 max)
- Check if there's an active TodoWrite list with incomplete items

### Step 3: Generate Handoff Prompt

Create a handoff following this **exact format**. Be ruthlessly concise - new sessions need actionable context, not verbose history.

**Length targets:**
- Current Task: max 2 sentences (40 words)
- Progress bullets: max 15 words each
- Next Steps bullets: max 20 words each
- Important Notes: max 3 bullets, 25 words each

---

## Session Handoff

### Current Task
[1-2 sentences: What specific feature/bug/refactor is being worked on? What's the immediate goal?]

### Git State
- **Branch**: [branch name]
- **Uncommitted changes**: [brief summary from git status, or "none"]
- **Modified files**: [list from git status --short, or "none"]

### Key Files
[List 3-5 most relevant files with brief context]
- `path/to/file.ts` - [one-line description of relevance]

### Recent Progress
[2-3 bullets max - what was just completed or attempted]
-
-

### Active Blockers
[Current errors, test failures, or pending decisions - include key error messages if debugging]
-

### Next Steps
[2-3 actionable bullets - what to do first when resuming]
1.
2.

### Important Context
[Critical info that can't be re-discovered: architectural decisions, gotchas, why certain approaches were tried/rejected]
-

### TODO List Status
[If TodoWrite list exists, include incomplete items. Otherwise write "No active TODO list"]

### Resume Command
[Optional: specific command to run first, like `/test-vitest path/to/test.ts` or `yarn build`]

---

**If `--with-snippets` was provided**, append this section with the most critical 2-3 code snippets (5-10 lines each) showing current implementation state:

```
### Critical Code Snippets

\`\`\`typescript
// path/to/file.ts:123-130
[snippet showing current state of key function/component]
\`\`\`
```

---

### Step 4: Copy to Clipboard

After generating the handoff, copy it to the clipboard using the platform-appropriate command:

```bash
# Detect platform and copy
if command -v pbcopy >/dev/null 2>&1; then
  # macOS
  cat <<'HANDOFF_END' | pbcopy
[YOUR GENERATED HANDOFF CONTENT HERE]
HANDOFF_END
  echo "✅ Handoff copied to clipboard (macOS)"
elif command -v xclip >/dev/null 2>&1; then
  # Linux with xclip
  cat <<'HANDOFF_END' | xclip -selection clipboard
[YOUR GENERATED HANDOFF CONTENT HERE]
HANDOFF_END
  echo "✅ Handoff copied to clipboard (Linux/xclip)"
elif command -v xsel >/dev/null 2>&1; then
  # Linux with xsel
  cat <<'HANDOFF_END' | xsel --clipboard
[YOUR GENERATED HANDOFF CONTENT HERE]
HANDOFF_END
  echo "✅ Handoff copied to clipboard (Linux/xsel)"
elif command -v clip.exe >/dev/null 2>&1; then
  # Windows (WSL or Git Bash)
  cat <<'HANDOFF_END' | clip.exe
[YOUR GENERATED HANDOFF CONTENT HERE]
HANDOFF_END
  echo "✅ Handoff copied to clipboard (Windows)"
else
  echo "ℹ️  No clipboard utility found. Copy the handoff manually."
fi
```

### Step 5: Display Summary

After attempting clipboard copy, display:
1. ✅ Confirmation that handoff was generated
2. 📋 Clipboard status (copied or manual copy needed)
3. 💡 Reminder: "Paste this at the start of your next Claude Code session"

---

## Critical Guidelines

- **Concise over comprehensive**: Err on the side of brevity. Details can be re-discovered; current state cannot.
- **Actionable first**: The new session should know exactly what command to run or file to open first.
- **Error context is gold**: If debugging, include the actual error message text (not full stack traces).
- **No project background**: Don't explain what the overall project does - focus only on the current work.
- **Git state is critical**: Any uncommitted changes MUST be clearly noted.
- **Respect length targets**: If you can't fit something in the word limit, it's not essential enough.

---

## Example Output Quality

❌ **Too verbose**: "The current task involves implementing a new feature for user authentication that will allow users to log in using OAuth providers like Google and GitHub. This is part of a larger effort to modernize the authentication system."

✅ **Concise**: "Adding OAuth login (Google/GitHub) to auth system. Currently implementing callback handler."

---

❌ **Vague**: "Need to fix some tests and make sure everything works"

✅ **Actionable**: "Fix 3 failing Vitest tests in `auth.test.ts:45,67,89` - all TypeError: Cannot read property 'user' on undefined"
