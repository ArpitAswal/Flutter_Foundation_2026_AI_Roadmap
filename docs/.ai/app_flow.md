# Application Flow Documentation

## 1. Primary Learning Journey

```
[PhasesScreen] ──▶ [ModulesScreen] ──▶ [DaysScreen] ──▶ [LessonScreen]
       │                                                       │
       ├─ (Global Search) ─────────────────────────────────────┘
       │
       ▼ (Double-Back Tap)
   [Exit App]
```

### Step 1: Phases & Curriculum Overview (`PhasesScreen`)
1. User opens the application and views the root curriculum phases.
2. `CurriculumBloc` loads phase definitions and checks completed lesson IDs from Hive.
3. Unlocked phases display vibrant accent colors; locked phases display lock badges until preceding phases are completed.
4. **Debounced Search**:
   - Typing into the search bar initiates a 500ms debounce timer.
   - Search filters all nested days across all phases and modules in real-time.
   - Tapping a search result executes `context.pushNamed(...)`, keeping the search state intact when the user navigates back.
5. **Double-Back Exit**:
   - System back gestures are intercepted by `PopScope(canPop: false)`.
   - First back tap displays a bottom SnackBar prompting the user to tap again within 2 seconds to exit.
   - Second tap within 2 seconds exits the app cleanly via `SystemNavigator.pop()`.

### Step 2: Modules & Days Navigation (`ModulesScreen`, `DaysScreen`)
1. User taps an unlocked phase to open its module list.
2. Grid layout displays 1 column on mobile portrait, or 2 columns on tablets and landscape orientations.
3. User selects an unlocked module to view the day-by-day roadmap.
4. Each day card indicates lesson status: Completed (green checkmark), Unlocked (accessible), or Locked (greyed out with lock icon).

### Step 3: Interactive Lesson Reading (`LessonScreen`)
1. User opens an unlocked lesson.
2. Markdown reader renders theoretical concepts with customized typography (Hanken Grotesk, Inter).
3. Code snippets are rendered with syntax highlighting using `JetBrains Mono`.
4. User explores expandable accordion sections (Architecture, Comparisons, Common Mistakes, Interview Prep).
5. **Sticky Completion Bar**: Bottom action bar remains visible above the viewport, enabling instant completion toggle.
6. **Scroll-to-Top FAB**: Automatically fades in once the user scrolls beyond 400px.

---

## 2. AI Tutor & BYOK Journey

```
[Floating Action Button]
          │
          ▼
[AiTutorBottomSheet Opened]
          │
          ├──▶ If No Key Configured ──▶ [Locked Banner] ──▶ [AiAssistantSettingsScreen]
          │                                                            │
          └──▶ If Key Configured                                       │ (Save Key)
                    │                                                  ▼
                    ├─ Contextual Greeting & Starter Chips ◀───────────┘
                    │
                    ▼
          [User Submits Question]
                    │
                    ▼
          [QuestionScopePolicy Evaluation]
          ├──▶ Refused ─────────────▶ Local Refusal Text (0 Tokens)
          ├──▶ Clarification ───────▶ Local Clarification Text (0 Tokens)
          └──▶ Allowed ─────────────▶ [ConversationContextBuilder]
                                                │
                                                ▼
                                    [Provider API Streaming]
                                    (Gemini 3.5 Flash / GPT-5 Mini / Claude 3.5 Haiku)
                                                │
                                                ▼
                                    [80ms Throttled Markdown Stream]
                                    (Stop / Retry / New Chat Controls)
```

### Step 1: Locked State & Initial Setup
1. User taps the floating `AiTutorFab`.
2. If no valid API key has been saved, the bottom sheet opens in a locked state, displaying instructions and a direct button to **AI Assistant Settings**.

### Step 2: Bring Your Own Key Configuration (`AiAssistantSettingsScreen`)
1. User opens Settings. `no_screenshot` immediately disables screen capture and recording.
2. User chooses their preferred AI model:
   - **Google Gemini**: `gemini-3.5-flash`
   - **OpenAI**: `gpt-5-mini`
   - **Anthropic Claude**: `claude-3-5-haiku-20241022`
3. User enters their personal API key and taps **Save key**.
4. The system validates the key against live provider endpoints:
   - **Valid**: Key is encrypted into Keychain/KeyStore; field changes to masked representation (`AIza••••••••0XYZ`) with verified badge.
   - **Invalid / Quota Exceeded / Network Error**: Displays descriptive `KeyValidationResult` feedback.

### Step 3: Contextual Chat Session
1. When a key is active, tapping `AiTutorFab` on any screen opens the bottom sheet with active screen context (e.g. current lesson title).
2. The sheet generates a personalized greeting and up to 3 contextual starter chips (e.g., "Explain variables", "Give a code example").
3. Tapping a chip or typing in the text field submits the question.

### Step 4: Deterministic Scope Policy Enforcement
1. `QuestionScopePolicy` evaluates the input locally:
   - **Refused**: Off-topic queries or standalone native platform instruction (e.g. "how to write Swift without Flutter") receive an immediate refusal without calling provider APIs or consuming tokens.
   - **Clarification**: Vague questions prompt the user for specific details.
   - **Allowed**: Standard Flutter/Dart queries and explicit Flutter vs. native comparisons proceed to the provider.

### Step 5: Bounded Multi-Turn Streaming
1. `ConversationContextBuilder` gathers recent turns (max 6 turns / 4k characters) and relevant lesson theory summary.
2. Provider streams tokens with immediate first chunk emission and subsequent 80ms throttling.
3. User controls:
   - **Stop**: Halts active streaming and finalizes current partial text.
   - **Retry**: Re-submits the last question if a network or provider error occurs.
   - **New Chat**: Clears in-memory conversation and resets contextual chips.
   - Preserves conversation across screens during the app lifecycle session.

---

## 3. Tablet & iPad Responsive Experience Flow

1. **Orientation Detection**:
   - In portrait mode, cards and lists adjust padding and typography for larger screen real estate.
   - In landscape mode, grids switch from 1 column to 2 balanced columns, preventing stretched horizontal cards.
2. **Bottom Sheet Adaptation**:
   - On mobile, the sheet expands to full width.
   - On tablets in landscape mode, the sheet is constrained to `maxWidth: screenWidth * 0.75`, providing an optimized, comfortable reading line length.
3. **Dynamic FAB Sizing**:
   - Floating Action Button scales smoothly between phone and tablet sizes, ensuring comfortable touch targets across all device categories.
