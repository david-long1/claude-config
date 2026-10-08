---
name: design-doc
description: Generate a technical design document (problem, current architecture, 2-4 options, decision matrix, recommendation). Use when the user asks for a design doc or RFC.
argument-hint: "[problem description]"
---

You are tasked with creating a technical design document. Follow the structure and requirements below.

## Input
Problem description: $ARGUMENTS

## Your Task

1. **If problem description is provided:**
   - Search the codebase to understand current implementation
   - Ask 1-2 clarifying questions if needed
   - Generate the design doc

2. **If no problem description provided:**
   - Ask: "What technical problem are you trying to solve?"
   - Search the codebase after user responds
   - Ask follow-up questions if needed
   - Generate the design doc

## Design Doc Structure

Create a document with these sections:

1. **Problem Statement** (2-3 sentences)
   - What's broken or needs improvement
   - Why it matters (security risk, performance, maintainability, etc.)
   - Root cause if known

2. **Current Architecture**
   - ASCII diagram showing current flow
   - Brief description of how it works today
   - Key files/modules involved (with line numbers)
   - Current permissions/configuration table

3. **Proposed Solutions** (2-4 approaches)
   For each approach:
   - **Concept:** One sentence explanation
   - **Why it works:** Key technical insight
   - **Implementation Overview:** High-level pseudo-code (not exact code)
   - **Files to Modify:** List with brief description of changes
   - **Pros:** Bullet points with ✅
   - **Cons:** Bullet points with ❌ or ⚠️
   - **Effort:** Estimate (lines changed, days of work)

4. **Decision Matrix**
   - Table comparing approaches across criteria:
     - Security
     - Maintainability
     - Testing Risk
     - Lines Changed
     - Whether it solves the root problem

5. **Recommendation**
   - Clear statement of recommended approach
   - Confidence level WITH reasoning:
     - ✅ What we know for certain
     - ⚠️ What requires validation
   - Fallback plan if recommendation fails
   - Next steps checklist

6. **Open Questions**
   - Numbered list of unknowns
   - Questions for stakeholders

## Critical Requirements

- **Be concise** - No verbose explanations
- **Be scannable** - Tables, bullets, diagrams
- **Back up claims** - Any percentage/estimate needs reasoning
- **High-level code** - Conceptual pseudo-code only, not exact line-by-line implementation
- **Be honest** - Call out uncertainties explicitly

## Audience Requirements

The doc will be read by Product and by engineers with zero project context.
Before finishing, run this checklist over the draft:

1. **Every coined or internal term is glossed at first use.** Fix codes,
   tier labels, project shorthand, acronyms — one-line
   definition or a link the first time each appears. If the doc invents a
   term, it says so ("named in this doc; renameable"). If tickets exist for
   a piece of work, link the tickets instead of using a codename.
2. **Every reference is a link with a title.** No "that doc" / "the mapping
   doc" / bare §N into other documents. In-doc §N references get re-checked
   whenever sections are added, removed, or reordered.
3. **No sentence carries more than one idea plus one qualifier.** Split
   dense sentences. Wherever a rule is abstract, add a concrete example —
   an example beats a second paragraph of explanation (e.g. don't just say "values are masked"; show
   `user.email → "j***@example.com"`).
4. **Structure runs decision-first.** What the doc decides comes before the
   background that informed it (audits, explorations, prior art go after,
   as supporting context). A reader stopping at the halfway point should
   have the design, not the history.
5. **Product-facing decisions are framed as customer experiences.** For any
   decision Product must ratify, show option A vs option B as what the
   customer sees ("an error page" vs "partial results with a warning"),
   not as mechanism ("fail-closed filter" vs "best-effort filter").
6. **Open questions state their resolution when resolved.** "[RESOLVED]"
   alone is not enough — append who decided, when, and what the decision
   was, and keep the original question text for context.

## Output

Generate the design doc in markdown format, ready to paste into a doc or GitHub.
