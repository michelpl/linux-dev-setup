# Project Guidelines

This document defines the implementation standards for this repository.
All contributors (human or AI) must follow these guidelines in every change.

## 1) Language and Communication

- **All project artifacts must be written in English**, including:
  - source code;
  - comments;
  - commit messages;
  - pull request titles/descriptions;
  - documentation and README updates;
  - scripts, logs, and user-facing messages.

## 2) Security and Development Best Practices

- Follow secure-by-default development practices.
- Validate input and fail fast with clear error messages.
- Use least-privilege principles (avoid unnecessary elevated permissions).
- Never hardcode secrets, tokens, passwords, or private keys.
- Prefer official package sources and verify remote assets whenever possible.
- Keep scripts idempotent whenever practical (safe to re-run).
- Add defensive checks for operating system compatibility and dependencies.

## 3) Post-Implementation Review (Mandatory)

After every implementation or modification, contributors must:

1. Verify that all requested requirements were implemented.
2. Run appropriate checks/tests (lint, syntax check, unit/integration tests when available).
3. Validate the expected behavior manually when automation is insufficient.
4. Review the diff for regressions, accidental changes, and security issues.
5. Confirm that documentation reflects the new behavior.

## 4) Documentation Standards

- Document what changed, why it changed, and how to use it.
- Keep examples accurate and executable.
- Update setup instructions when new scripts or dependencies are introduced.
- Avoid ambiguous wording; prefer explicit and actionable instructions.

## 5) Code Quality Standards

- Favor readability over cleverness.
- Keep functions/scripts focused and small.
- Use consistent naming conventions.
- Remove dead code and unused assets.
- Add comments only when they provide context that is not obvious from the code.

## 6) Change Management

- Keep changes scoped to a single objective whenever possible.
- Ensure backward compatibility unless a breaking change is intentional and documented.
- Include a clear validation section in pull requests with executed commands.

## 7) AI Contributor Rules

When an AI agent contributes to this repository, it must:

- strictly follow this guideline document;
- avoid assumptions when requirements are unclear;
- explicitly validate outputs before finalizing changes;
- report limitations, risks, or unverified behavior transparently.

---

By contributing to this project, you agree to follow these standards.
