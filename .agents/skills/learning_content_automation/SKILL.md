---
name: learning-content-automation
description: Generates and integrates structured Flutter/Dart learning content from project curriculum state, supplied source documents, and current official documentation. Use when researching, planning, generating, validating, or completing curriculum learning content.
---

# Learning Content Automation Skill

This Skill provides the specialized capability for building the Flutter AI Tutor learning curriculum.

## Primary References

Follow:

`docs/.ai/learning_content_automation.md`

Also respect:

`.agents/rules/learning_content_automation/learning_content_rules.md`

Use these existing project documents as supporting context:

- `docs/.ai/project_context.md`
- `docs/.ai/architecture.md`
- `docs/.ai/app_flow.md`
- `docs/.ai/implementation_rules.md`
- `docs/.ai/skills.md`

## Required Project State

Before performing work, inspect:

- `curriculum_index.json`
- existing learning-content JSON
- relevant previous lessons
- source PDFs/documents (docs/sources)
- README-generation tooling

## Specialized Behavior

This Skill enables the agent to:

1. Analyze curriculum dependencies.
2. Research authoritative source material.
3. Verify current technical information.
4. Generate structured learning content.
5. Integrate content into the repository.
6. Validate the generated result.
7. Detect broad topics with multiple approaches (e.g. State Management covering Riverpod, BLoC, Provider, GetX, MobX, Signals) and present complete options to the user before structuring.
8. Use `custom_route` as a `List<String>` of asset paths for multi-technique sub-lesson branching within an anchor day (minimum 2 sub-lessons, never a single self-referencing item), ensuring full `LessonContent` depth for every sub-lesson.
9. Size modules and phases by topic complexity, not by fixed counts.
10. Execute all file operations autonomously within a module run without individual confirmation prompts.

The detailed execution sequence is defined by the workflow document.

The mandatory constraints are defined by the Rules file.

Do not duplicate those documents here.

## Output

The expected result is working content integrated into the repository and validated according to the project workflow.