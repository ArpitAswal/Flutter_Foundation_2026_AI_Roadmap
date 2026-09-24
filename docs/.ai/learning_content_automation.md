# Flutter AI Tutor — Learning Content Automation Workflow

## 1. Purpose

This document defines the autonomous workflow for researching, planning, generating, integrating, validating, and documenting the day-wise learning content for the Flutter AI Tutor application.

This workflow is separate from the application's software-engineering implementation rules.

The existing project documentation remains authoritative for application architecture, implementation standards, technology choices, security, responsiveness, testing, and application behavior.

This document governs only the **learning-content generation and integration workflow**.

## 2. Primary Objective

The objective is to continuously build the structured Flutter/Dart learning curriculum defined by the project while ensuring that:

1. Learning is generated one day at a time.
2. The sequence of learning is determined from the complete curriculum, source documents, prerequisites, and existing completed content.
3. Source PDFs and supplied documentation are analyzed before generating learning content.
4. Current official documentation is checked when the relevant technology or API may have changed.
5. Previously generated learning is considered before generating the next day.
6. Learning content is generated in the application's required JSON structure.
7. Generated JSON is directly integrated into the project.
8. The generated content is validated before being considered complete.
9. A module is processed from its first required day through its final required day without requiring manual approval between individual days.
10. README files are generated only after the entire module has been completed and validated.
11. The autonomous workflow MUST STOP after one complete module and its README generation.
12. The workflow MUST NOT automatically continue to the next module.
13. The next module may only be started after explicit user confirmation.

## 3. Authority Hierarchy

When making learning-content decisions, use the following authority order.

### Priority 1 — User-provided curriculum rules

Explicit instructions provided by the user always take precedence.

### Priority 2 — Current official documentation

When a technology, API, language feature, framework behavior, or recommended practice has changed, current official documentation takes precedence over outdated material.

### Priority 3 — User-provided source documents

PDFs and other supplied learning/reference documents are primary curriculum sources.

### Priority 4 — Existing curriculum structure

Existing `curriculum_index.json`, module definitions, day definitions, and previously generated learning content must be respected.

### Priority 5 — Existing application implementation

The current repository structure and JSON schema must be inspected before modifying learning data.

### Priority 6 — General model knowledge

General model knowledge may be used only when the higher-priority sources do not provide the required information.

Never silently replace authoritative project material with assumptions.

If an important conflict or ambiguity cannot be resolved from the available sources, stop and request clarification rather than inventing curriculum requirements.

## 4. Existing Project Documentation

Before performing learning-content automation, understand and preserve the existing project documentation.

At minimum, inspect:

* `agent.md`
* `architecture.md`
* `app_flow.md`
* `implementation_rules.md`
* `project_context.md`
* `skills.md`
* `curriculum_index.json`
* Existing learning-content JSON files
* Source PDFs/documents
* Any existing README-generation scripts or commands

The application currently follows a Clean Architecture + Feature-First structure, and the learning system is organized as:

`CurriculumIndex → LessonModule → LessonDay`.

The existing project defines linear progression through phases, modules, and days.

Do not modify application architecture merely to support content generation.

## 5. Curriculum Evolution Model

The curriculum is append-only during normal automation.

Completed curriculum content is protected historical content.

The agent may analyze and plan future curriculum structure and may
extend the curriculum by adding new phases, modules, days, directories,
and learning-content JSON files.

The agent must not modify existing completed phases, modules, days, or
their learning-content files during normal automation.

When extending `curriculum_index.json`, preserve all existing entries
and add only the newly planned curriculum entries.

## 6. Curriculum Asset Integration

After adding or updating learning-content JSON files under `assets/curriculum/`,
the agent must ensure that the corresponding curriculum directory is declared
in `pubspec.yaml` under `flutter.assets`.

When a new phase or module directory is created, add its directory path to
the `assets:` list in `pubspec.yaml`.

Example:

```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/curriculum/
    - assets/curriculum/phase1/module1/
    - assets/curriculum/phase1/module2/
    - assets/curriculum/phase1/module3/
    - assets/curriculum/phase2/module1/
    - assets/images/

```  

## 7. Module-Based Execution Model

The fundamental unit of autonomous execution is a **module**, not an individual day.

The workflow is:

```text
Module
   │
   ├── Day 1
   ├── Day 2
   ├── Day 3
   ├── ...
   └── Final Day
          │
          ▼
    Module Validation
          │
          ▼
    README Generation
          │
          ▼
     STOP EXECUTION
```

The agent may internally process multiple days without requesting user confirmation between them.

However, it must never cross the module boundary automatically.

## 8. Start-of-Run Procedure

Every time the user starts the automation workflow, perform the following sequence.

## Step 1 — Inspect Current State

Determine:

* Current phase
* Current module
* Completed modules
* Current/incomplete module
* Completed days
* Next required day
* Remaining days in the current module
* Whether the current module has already been completed
* Whether README generation has already occurred

Never assume the next day from the user's message alone.

Inspect the actual project state first.

## Step 2 — Inspect Curriculum Structure

Read the current `curriculum_index.json` and related curriculum files.

Determine:

```text
Current Phase
    ↓
Current Module
    ↓
Completed Days
    ↓
Next Required Day
    ↓
Remaining Days
    ↓
Module Completion Boundary
```

The curriculum index is the source of truth for the current learning sequence.

Do not reorder modules or days merely because another sequence appears more convenient.

## Step 3 — Analyze Existing Learning

Before generating a day, inspect the relevant previously completed days.

Determine:

* What has already been taught?
* Which concepts are prerequisites?
* Which concepts have already been explained?
* Which concepts should be introduced next?
* Which concepts should be postponed?
* Is the planned day consistent with the learner's progression?
* Would the new content unnecessarily duplicate an earlier lesson?

The agent must reason about the curriculum as a continuous learning journey rather than treating each day as an isolated document.

## 9. Source Research Procedure

Before generating each day, research the relevant source material.

Use:

1. Relevant supplied PDFs/documents
2. Relevant official documentation
3. Existing curriculum material
4. Existing project rules
5. Current official release/change information when applicable

For technology that changes over time, verify the current behavior before writing the lesson.

Examples include:

* Dart language features
* Flutter framework APIs
* Flutter architecture recommendations
* Package APIs
* Deprecated APIs
* CLI commands
* Recommended project structures
* Platform integration behavior

Do not rely solely on model memory for potentially changed technical information.

## 10. Determine Day Scope

For each day, determine its exact learning scope before writing the JSON.

The scope must answer:

* Why does this topic belong on this day?
* What prerequisite knowledge is required?
* Was the prerequisite already covered?
* What should the learner understand by the end of the day?
* Which concepts belong to this day?
* Which related concepts should intentionally be postponed?
* Does this day fit the current module objective?

The agent must not add advanced topics merely because they are related.

Avoid scope expansion that causes later days to become redundant.

## 10.1. Broad Topic Protocol & Dynamic Lesson Partitioning

### Universal Broad Topic Scope (Phase-Agnostic)
Broad concepts are not restricted to any single phase or hardcoded to State Management. A Broad Topic is any curriculum subject in Flutter that encompasses multiple recognized paradigms, libraries, or architectural techniques, including:
- **State Management**: Built-in Primitives, Provider, Riverpod, GetX, BLoC/Cubit, MobX, Signals.
- **Network Requests & APIs**: `http` (REST), `dio` (interceptors, caching, retry), `graphql_flutter`, `web_socket_channel` (real-time streaming), `grpc`.
- **Local & Cloud Storage / Data Persistence**: `shared_preferences` (key-value), `hive` (NoSQL box), `sqflite` / `drift` (relational SQL), `cloud_firestore` / Firebase, `supabase_flutter`.
- **Navigation & Routing**: Declarative `go_router`, `Navigator 2.0`, `auto_route`, deep linking.
- **Testing & Quality Assurance**: Unit testing, Widget testing, Integration testing, Golden testing, Mockito/Mocktail.

Never force or hardcode which phase must cover which topic. The topic is introduced wherever the curriculum roadmap naturally places it.

### The 3-Step Selection & Structuring Protocol

1. **Option Enumeration**: When the curriculum reaches a broad topic, the agent must identify and present the complete list of recognized approaches/libraries in the Flutter ecosystem to the user.
2. **User Selection**: The user selects which specific approaches they want covered in their curriculum.
3. **Agent Partitioning (Standalone Lesson vs. Sub-Lesson)**:
   - Based on the user's selected list, the agent decides which items become standalone **Lesson Days** and which become **Sub-Lessons** (`custom_route`) under relative anchor days:
     - **Standalone Lesson Day**: Allocated for foundational framework concepts, core architectural pillars, or topics with large dedicated mental models that serve as prerequisites for subsequent learning.
     - **Sub-Lesson (`custom_route`)**: Allocated when multiple alternative libraries or specialized implementation techniques naturally group under a relative comparative anchor day.

#### Concrete Example: State Management Selection
Suppose the user selects:
1. *Built-in Primitives* (`setState`, `InheritedWidget`, `InheritedModel`, `ChangeNotifier`, `ValueNotifier`, `InheritedNotifier`)
2. *Scoped Tree Management* (`Provider`)
3. *Modern Compile-Time Reactive* (`Riverpod`)
4. *Micro-Framework / Service Locator* (`GetX`)
5. *Enterprise Event-Driven* (`Cubit` & `BLoC`)

The Agent intelligently structures the curriculum:
- **Standalone Days**:
  - Day: Built-in Primitives (`InheritedWidget`, `ChangeNotifier`, `ValueNotifier`) — foundational to understanding Flutter reactivity.
  - Day: Scoped State & Provider Architecture — standard dependency injection and tree-scoped state.
  - Day: Cubit & Lightweight UI State Binding.
  - Day: BLoC Pattern: Event-Driven Architecture & Concurrency Transformers.
- **Multi-Technique Anchor Day with Sub-Lessons (`custom_route`)**:
  - Anchor Day: *Modern Reactive State Management: Declarative Approaches & Frameworks* (`content_path` provides architectural overview and comparative taxonomy).
  - Sub-Lessons in `custom_route`:
    - `assets/curriculum/phase3/module2/dayX/riverpod.json` (dedicated deep dive on Riverpod).
    - `assets/curriculum/phase3/module2/dayX/getx.json` (dedicated deep dive on GetX).
- **Synthesis Day**:
  - Day: *State Management Decision Matrix & Live Multi-Engine Benchmarking* — synthesizing trade-offs across all selected approaches.

#### Concrete Example: Network Requests & Storage
- If user selects `http`, `dio`, and `graphql`:
  - Standalone Day: REST fundamentals with `http`.
  - Anchor Day with Sub-Lessons: Advanced Client Architecture with `dio.json` and `graphql.json`.
- If user selects `shared_preferences`, `hive`, `sqflite`, and `cloud_firestore`:
  - Anchor Day with Sub-Lessons: Local Key-Value & NoSQL Persistence with `shared_preferences.json` and `hive.json`.
  - Standalone Day: Relational SQL Persistence with `sqflite`.
  - Standalone Day: Real-Time Cloud Persistence with `cloud_firestore`.


## 10.2. Sub-Lesson and `custom_route` Architecture Protocol

### Core Purpose of `custom_route`
`custom_route` is Flutter AI Tutor's architectural mechanism for **multi-technique branching within a single curriculum day**. It allows a day to act as a parent anchor that introduces a broad topic, while providing dedicated, full-featured sub-lesson screens for each distinct technique, approach, or library.

### Crucial Anti-Pattern to Avoid: Self-Referencing Tautology
A day must **NEVER** define a single-item `custom_route` that merely points to itself:
- ❌ **STRICTLY FORBIDDEN**: A day titled "GetX" with `custom_route: ["assets/.../day29/getx.json"]`. (Redundant tautology: the parent is GetX and the sub-lesson is also GetX).
- ❌ **STRICTLY FORBIDDEN**: A day titled "State Management Matrix" with `custom_route: ["assets/.../day33/state_management_matrix.json"]`.
- ✅ **CORRECT RULE**: If a day covers only a single topic or library, `custom_route` must be `null`.
- ✅ **CORRECT RULE**: `custom_route` must ONLY be used on **Multi-Technique Days** where the day branches into **two or more distinct sub-lessons** (minimum 2 items in the list).

### Parent Day Overview Responsibilities (`content_path`)
The parent day's JSON file (`content_path`) must ALWAYS be created and fully populated with comprehensive overview content:
1. **Conceptual Taxonomy**: The problem space, architectural category, shared patterns, and mental model.
2. **Comparison Matrix**: Comparative evaluation across the different techniques covered by the sub-lessons.
3. **When to Use Which**: Definitive guidance helping the learner choose between the sub-lesson approaches.
4. **UI Presentation**: The parent `LessonScreen` automatically renders interactive "Explore Approaches" navigation cards for each sub-lesson declared in `custom_route`.

### Sub-Lesson Deep-Dive Responsibilities (`custom_route`)
Each sub-lesson in `custom_route` is a **complete, full-depth learning module** adhering to the standard `LessonContent` schema:
1. **Schema Integrity**: Must populate all standard keys: `theory`, `implementation`, `comparisons`, `architecture`, `optimization`, `common_mistakes`, `interview_questions`, `prerequisites`, `last_updated`.
2. **Production-Grade Implementation Code**: Full, runnable code demonstrating domain entities, controller/store/notifier implementation, dependency injection registration, fine-grained UI binding, and error handling.
3. **Deep Technical Dives**: ASCII data flow diagrams, memory optimization, rebuild guards, beginner/intermediate/senior common mistakes, and 5-8 scenario-based architectural interview questions.
4. **File Organization**: Place sub-lessons in a subfolder named after the day: `assets/curriculum/phase{P}/module{M}/day{D}/{approach_name}.json`.
5. **Asset Declaration in `pubspec.yaml`**: Ensure `assets/curriculum/phase{P}/module{M}/day{D}/` is declared under `flutter.assets`.


## 11. Generate Daily Learning Content

Generate the day's content according to the existing learning-content schema and established curriculum rules.

The content must preserve the project's learning philosophy.

Every major topic should, where applicable, establish:

1. What is it?
2. Why is it needed?
3. When should it be used?
4. When should it not be used?
5. What are the alternatives?
6. How is it implemented in production?

These principles are part of the application's defined learning philosophy.

Learning content should be designed to build understanding rather than encourage memorization or copy-paste usage.

## 12. JSON Integration

The generated learning content must be written directly into the project's actual JSON files.

Do not merely output JSON in the agent conversation.

Before modifying a JSON file:

1. Inspect the existing file.
2. Understand its schema.
3. Preserve existing content.
4. Insert the new day at the correct location.
5. Preserve IDs and relationships.
6. Maintain valid JSON formatting.
7. Avoid duplicate day IDs.
8. Avoid accidental modification of unrelated curriculum data.

After modification:

1. Parse/validate the JSON.
2. Verify the new day exists.
3. Verify its module/phase relationship.
4. Verify the day ordering.
5. Verify required fields.
6. Verify there are no duplicate identifiers.

## 13. Daily Validation

Every generated day must pass validation before the workflow proceeds to the next day.

Validation must cover:

## Curriculum validation

* Correct module
* Correct day
* Correct sequence
* Correct prerequisites
* No unintended duplication
* Appropriate difficulty

## Technical validation

* Current official behavior
* Correct API names
* Correct syntax
* Correct code examples
* No obsolete APIs unless explicitly taught as historical/deprecated material

## Content validation

* Learning objectives are satisfied
* Explanations are technically accurate
* Examples support the concept
* Production relevance is clear
* Trade-offs are not omitted where relevant
* Common mistakes are accurately described

## JSON validation

* Valid JSON
* Correct schema
* Correct IDs
* Required properties present
* No duplicate entries
* Correct nesting

If validation fails, fix the content and validate again.

Do not proceed with known validation failures.

## 14. Day-to-Day Automation

Once a day has passed validation:

```text
Day X
  ↓
Generate
  ↓
Integrate JSON
  ↓
Validate
  ↓
Complete
  ↓
Proceed to Day X+1
```

Do not ask the user for confirmation between days within the same module.

The user confirmation boundary is the **module boundary**.

## 15. Module Completion Detection

After each completed day, determine whether the current module has reached its final required day.

Every day listed in `curriculum_index.json` for the current module must have its `content_path` JSON file generated, regardless of whether `custom_route` is null or non-null.

A day with a `custom_route` value is a normal curriculum day that requires the same learning-content JSON generation as any other day.

### If the module is incomplete:

Continue automatically with the next required day.

### If the module is complete:

Do NOT begin the next module.

Instead:

```text
Final Day
   ↓
Full Module Review
   ↓
Module Validation
   ↓
README Generation
   ↓
README Validation
   ↓
STOP
```

## 16. Full Module Review

Before generating README files, review the complete module as a unit.

Check:

* Every required day exists.
* Every required day has valid JSON.
* Day ordering is correct.
* No required topic is accidentally missing.
* No major topic is unnecessarily duplicated.
* Prerequisites flow correctly from earlier days.
* Difficulty progresses appropriately.
* Terminology remains consistent.
* Examples remain consistent.
* References to earlier lessons are valid.
* The module achieves its intended learning objective.
* No unfinished placeholder content remains.

If a problem is found, correct it before README generation.

## 17. README Generation

Only after the complete module passes review, execute the project's established README-generation command/process.

Do not invent a new README generation mechanism if the project already contains one.

The agent must:

1. Identify the established README generation command.
2. Execute it.
3. Verify successful completion.
4. Inspect the generated/updated Markdown files.
5. Confirm that they correspond to the completed module.
6. Ensure no unrelated modules are accidentally regenerated or modified.

If the README-generation command fails:

* Diagnose the failure.
* Fix the relevant issue if it is within the automation workflow.
* Run the command again.
* Validate the result.

Do not declare module completion while README generation remains broken.

## 18. Mandatory Automation Stop Point

This is a critical requirement.

After:

1. All days in the current module are completed.
2. The complete module has passed validation.
3. README generation has successfully completed.
4. Generated Markdown files have been verified.

**STOP THE AUTOMATED WORKFLOW.**

Do not:

* Start the next module.
* Generate the next module's first day.
* Modify the next module.
* Pre-research the next module for integration.
* Automatically continue because another module remains.

The workflow must terminate at this exact boundary.

### 18.1. Batch Continuation Mode

If the user explicitly grants batch permission (e.g., "Continue until the end of this phase" or "Process all remaining modules"), the agent may process multiple modules sequentially without stopping between them.

The agent must still:

* Perform full validation after each module.
* Generate READMEs after each module.
* Stop at the phase boundary if not explicitly told otherwise.
* Report a combined completion summary at the end.

## 19. User Confirmation Boundary

After stopping, report the completed module to the user.

The completion report should include:

* Phase
* Module
* Days completed
* Source/documentation research performed
* JSON files modified
* Validation status
* README files generated
* Any notable issues or decisions
* Confirmation that the workflow has intentionally stopped

The agent may state what the next module is, but must not begin it.

The next module can only be started after the user explicitly confirms continuation.

Example:

```text
Module completed successfully.

Phase: Phase 1
Module: Module 3
Days completed: Day 11–Day 15

Learning JSON:
✓ Generated
✓ Integrated
✓ Validated

Module review:
✓ Passed

README:
✓ Generated
✓ Verified

Automation status:
STOPPED

The next module has NOT been started.

Waiting for user confirmation before continuing.
```

## 20. Restart Behavior

When the user later confirms continuation, treat that as a new automation run.

Example user instruction:

```text
Continue with the next module.
```

At the beginning of the new run, inspect the actual repository state again.

Do not rely solely on the previous run's final message.

Determine:

```text
Last completed module
        ↓
Next incomplete module
        ↓
First required day
        ↓
Execute one-module workflow
```

The same stop boundary applies again.

## 21. Failure Handling

If an error occurs during a module:

### Recoverable error

Attempt to resolve it automatically when the correction is unambiguous.

Examples:

* JSON formatting issue
* Schema mismatch
* Generated file placement error
* Sub-lesson directory missing from pubspec.yaml asset declarations
* Single-item / tautological custom_route detected (must expand to multi-technique or set null)
* Unwanted \n\n---\n\n horizontal rule code in JSON content (replace with \n\n)
* README command failure caused by an obvious local issue
* Validation failure caused by generated content

After correction, rerun the relevant validation.

### Unresolvable ambiguity

Stop and ask the user.

Examples:

* Conflicting curriculum requirements
* Missing required source material
* Unclear module boundary
* Multiple conflicting JSON schemas
* Official documentation contradicts a user rule and the intended priority is unclear
* Required command does not exist and no replacement is defined
* Topic has multiple well-known approaches where user preference is unknown
* Phase scope is too broad to fit into a symmetric fixed-count structure

Do not invent a decision simply to keep automation running.

## 21.1. Autonomous Tool Operations During a Module Run

Once the user starts a module automation run, all file operations required to complete that module are pre-approved and must be executed without individual confirmation prompts.

Pre-approved operations include:

* Reading any project file (JSON, YAML, Dart, Markdown).
* Editing curriculum JSON files and `curriculum_index.json`.
* Editing `pubspec.yaml` to add asset declarations.
* Running `dart run tool/generate_readmes.dart`.
* Running validation commands (`dart analyze`, JSON parse checks).
* Creating new directories and files under `assets/curriculum/`.

The agent must not pause mid-module to ask "May I edit this file?" or "May I run this command?" for any curriculum-related operation.

The only required stop point remains the module boundary defined in Section 18.

## 22. Scope of Autonomous Modification

The agent may autonomously modify files required to complete the learning-content workflow, including:

* Curriculum JSON
* Daily learning JSON
* Module learning data
* Generated Markdown/README files
* Supporting generated content required by the established workflow

Do not modify unrelated application functionality.

Do not refactor application architecture merely because the agent believes it could be improved.

The application follows Clean Architecture + Feature-First organization, and application engineering changes must continue to follow the existing architecture and implementation rules.

## 23. Application Engineering Boundary

This automation workflow does not override the application's engineering standards.

When executing commands or modifying project files, continue to respect:

* Clean Architecture
* Feature-First organization
* Centralized constants
* Responsive design requirements
* Secure API-key handling
* BLoC/Cubit responsibilities
* Existing navigation rules
* Existing testing requirements

The project's existing engineering rules require static analysis with zero issues and passing Flutter tests, and specify when `build_runner` must be executed.

Do not weaken these requirements to make content automation succeed.

## 24. Completion Criteria

A module is considered **COMPLETE** only when all of the following are true:

```text
[✓] Correct module identified
[✓] All required days generated
[✓] All days integrated into project JSON
[✓] JSON validated
[✓] Curriculum sequence validated
[✓] Technical content reviewed
[✓] Module reviewed as a complete learning unit
[✓] README generation completed
[✓] README output verified
[✓] No known blocking errors remain
[✓] Workflow STOPPED
```

If any required condition is false, the module is not complete.

## 25. High-Level Execution Algorithm

```text
START AUTOMATION RUN
        │
        ▼
Inspect repository and documentation
        │
        ▼
Inspect curriculum_index.json
        │
        ▼
Identify current incomplete module
        │
        ▼
Identify next required day
        │
        ▼
Research source documents
        │
        ▼
Research current official documentation
        │
        ▼
Determine day scope
        │
        ▼
Generate learning JSON
        │
        ▼
Integrate JSON
        │
        ▼
Validate day
        │
        ├── FAIL ──▶ Fix ──▶ Validate again
        │
        ▼
Is module complete?
        │
        ├── NO ──▶ Next day
        │             │
        │             └──────────────┐
        │                            │
        │                            ▼
        │                       Research
        │                       Generate
        │                       Integrate
        │                       Validate
        │                            │
        │                            └──▶ ...
        │
        ▼ YES
Full module review
        │
        ▼
Generate README files
        │
        ▼
Validate README output
        │
        ▼
REPORT COMPLETION
        │
        ▼
       STOP
        │
        X
        │
        │  USER CONFIRMS
        ▼
NEW AUTOMATION RUN
```

## 26. Final Operating Principle

The agent should behave as an autonomous **curriculum-content engineer**, not merely as a text generator.

Its responsibility is to:

**Understand → Research → Plan → Generate → Integrate → Validate → Complete Module → Generate Documentation → Stop**

The human remains the approval boundary between modules.

**One automation run = exactly one module.**

Never cross that boundary automatically.
