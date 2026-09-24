---
trigger: always_on
---

# Learning Content Rules

## Curriculum Integrity

- Always inspect `curriculum_index.json` before generating or modifying curriculum content.
- Treat the existing curriculum sequence as authoritative.
- Consider previously completed learning before adding new content.
- Never invent missing curriculum requirements.
- Never reorder existing curriculum items without explicit instruction.

## Source Integrity

- Prefer user-provided curriculum rules and source documents.
- Verify potentially changed technical information using current official documentation.
- Do not present outdated information as current.
- Do not silently override project-specific requirements.

## Data Integrity

- Inspect the existing JSON schema before modification.
- Preserve existing IDs and relationships.
- Never create duplicate curriculum/day identifiers.
- Validate modified JSON before proceeding.

## Automation Boundary

- One automation run processes exactly one module.
- Multiple days may be completed automatically within that module.
- Never begin the next module automatically.
- After the module README files are successfully generated and verified, stop.
- The next module requires explicit user confirmation.

## Repository Safety

- Modify only files required by the learning-content workflow.
- Do not modify unrelated application functionality.
- Do not perform unrelated refactoring.

## Curriculum Evolution

- Completed phases, modules, days, and their learning content are immutable by default.
- The agent may extend the curriculum only by adding new future phases, modules, days, and associated learning files.
- Existing curriculum entries must not be renamed, reordered, deleted, or rewritten during normal automation.
- New curriculum entries must use continuous numbering and the repository's established naming convention.
- New days must be added to `curriculum_index.json` without modifying existing completed entries.
- A completed module becomes part of the protected curriculum history.
- Changes to completed curriculum are allowed only when explicitly requested by the user.

## Asset Integration

- Whenever the automation creates a new curriculum asset directory or adds curriculum JSON, ensure the corresponding directory is declared in `pubspec.yaml` under `flutter.assets`.
- Preserve all existing asset declarations.

## Dynamic Curriculum Sizing

- The number of days in a module and modules in a phase must be determined by the complexity and breadth of the topic, not by a fixed number.
- Do not default to 3 days per module or 3 modules per phase.
- A complex topic (e.g., State Management) may require 5–8+ days across multiple modules to cover its breadth adequately.
- A simple topic may need only 1–2 days.
- If in doubt about scope, present the list of sub-topics to the user and ask which should be included before structuring the module.

## Broad Topic Protocol & Dynamic Lesson Partitioning

- **Phase-Agnostic Broad Topics**: Broad concepts are not restricted to any single phase or hardcoded to State Management. A Broad Topic is any curriculum subject that encompasses multiple distinct paradigms, libraries, or architectural techniques in Flutter, such as:
  - **State Management**: Built-in Primitives (`setState`, `InheritedWidget`, `ValueNotifier`), `Provider`, `Riverpod`, `GetX`, `BLoC` / `Cubit`, `MobX`, `Signals`.
  - **Network Requests & APIs**: `http` (REST), `dio` (interceptors, caching, retry), `graphql_flutter`, `web_socket_channel` (real-time streaming), `grpc`.
  - **Local & Cloud Storage / Data Persistence**: `shared_preferences` (key-value), `hive` (NoSQL box), `sqflite` / `drift` (relational SQL), `cloud_firestore` / Firebase, `supabase_flutter`.
  - **Navigation & Routing**: Declarative `go_router`, `Navigator 2.0`, `auto_route`, deep linking.
  - **Testing & Quality**: Unit tests, Widget tests, Integration tests, golden tests, mocking.
- **Never Force Phase Assignment**: Do not hardcode or assume which phase must cover which topic. The topic appears wherever the curriculum roadmap naturally places it.
- **The 3-Step Selection & Structuring Workflow**:
  1. **Option Enumeration**: When planning any broad topic, the agent must identify and present the complete list of recognized approaches/libraries to the user.
  2. **User Selection**: The user selects which specific approaches they want covered in their curriculum.
  3. **Agent Partitioning (Standalone Day vs. Sub-Lesson)**:
     - Based on the user's chosen options, the agent intelligently decides the curriculum layout:
       - **Standalone Lesson Day**: Allocated for foundational framework concepts, major architectural paradigms, or deep topics that serve as prerequisites for other lessons (e.g., Built-in Primitives, Provider, or BLoC pattern).
       - **Sub-Lesson (`custom_route`)**: Allocated when multiple alternative libraries or specialized approaches naturally group under a relative comparative anchor day (e.g., an anchor day on "Alternative Reactive Frameworks" branching into `riverpod.json` and `getx.json`; or an anchor day on "Local Persistence Engines" branching into `hive.json` and `sqflite.json`).
     - The agent structures the modules, days, and `custom_route` lists based on this architectural division.


## Custom Route & Sub-Lesson Usage

- **Purpose**: `custom_route` is strictly for **Multi-Technique Days** where a single curriculum day branches into **two or more distinct sub-lessons** (e.g., a day on "Modern Reactive State Management" branching into Riverpod, GetX, MobX, and Signals).
- **Prohibited Anti-Pattern (Self-Referencing Tautology)**: A day must NEVER define a single-item `custom_route` that merely points to itself (e.g., a day titled "GetX" with `custom_route: ["assets/.../day29/getx.json"]` is prohibited). If a day only covers one topic, `custom_route` must be `null`.
- **Minimum Sub-Lesson Count**: When `custom_route` is used, it MUST contain at least 2 distinct sub-lesson asset paths (`List<String>`).
- **Parent Day Overview Role (`content_path`)**:
  - The parent day's JSON file (`content_path`) must ALWAYS be created and fully populated.
  - It serves as the **Architectural Overview & Comparative Guide**: explains the overarching problem, core concepts, design trade-offs, taxonomy, selection criteria, and introduces the approaches covered in the sub-lessons.
  - In the UI, the parent screen renders the overview followed by interactive "Explore Approaches" navigation cards for each sub-lesson.
- **Sub-Lesson Content Depth (`custom_route`)**:
  - Each sub-lesson JSON file is a **dedicated, deep-dive learning module** that uses the standard `LessonContent` schema (`theory`, `implementation`, `comparisons`, `architecture`, `optimization`, `common_mistakes`, `interview_questions`, `prerequisites`, `last_updated`).
  - Sub-lessons are NOT stubs or brief summaries; each must provide comprehensive technical depth (typically 30KB–50KB) including:
    - Production-grade, fully runnable code with realistic domain models, dependency injection, and fine-grained UI consumer widgets.
    - Deep-dive sections: Architecture diagrams, comparison matrices, rebuild optimizations, common beginner/intermediate/senior mistakes, and scenario-based interview prep.
- **Directory Structure & Asset Declaration**:
  - Sub-lesson JSON files must be stored in a dedicated subfolder named after the day: `assets/curriculum/phase{P}/module{M}/day{D}/{approach_name}.json` (e.g., `assets/curriculum/phase3/module2/day29/riverpod.json`).
  - Whenever a new sub-lesson directory is created, that directory MUST immediately be declared in `pubspec.yaml` under `flutter.assets`.
- **Independent Exploration & Parent Completion**:
  - Completion tracking is recorded at the parent day level only. Sub-lessons are independently browsable learning resources accessible directly from the parent lesson screen.

## Autonomous Tool Operations

- Once a module automation run has been started by the user, all file operations required to complete that module are pre-approved.
- Do not ask for confirmation before editing curriculum JSON files, reading or editing `pubspec.yaml`, running `dart run tool/generate_readmes.dart`, or executing validation commands.
- The agent must perform all file reads, file edits, and bash commands autonomously within a single module run without pausing for individual tool-call approvals.
- The only required stop point is the module boundary defined in the Automation Boundary rules.

## New Line Integration
- Do not use \n\n---\n\n that is a computer text formatting code used to make new lines and draw a horizontal separator line.
- Only use \n\n to separate the line or section.

## Day Update
- In the days JSON data in the last_updated key, add a continuous date, not today or the system date. For instance, the last Day 29 has "2026-09-20"; then the next will have "2026-09-21" and so on until the month is finished. means the 09 month ends on the 30th day, so the next day JSON will have "2026-10-01". 

## Prerequisites
- Do not mention the previous prerequisited days. For instance Inheritance and InheritedModel Day28.