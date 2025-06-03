# Refactoring Plan: UI Update to Match Design Image

## 1. Executive Summary & Goals

This plan outlines the steps to refactor the application's UI, primarily focusing on the `MainScreen` and `HistoryScreen`, to align with the visual design provided in the reference image. The update will involve changes to layouts, colors, borders, icons, fonts, and component styling, adhering to macOS design principles and leveraging the `macos_ui` Flutter package.

**Key Goals:**

1.  Achieve visual fidelity with the provided design image for the application's main window, sidebar, toolbar, and History screen (prompt list and detail panes).
2.  Ensure UI consistency and adherence to macOS Human Interface Guidelines.
3.  Refine the usage of `macos_ui` components and themes for an authentic macOS look and feel.

## 2. Current Situation Analysis

The application currently uses `macos_ui` and has a structure that includes a `MainScreen` with a sidebar and a `HistoryScreen` with a two-pane layout for prompts and details.

Key areas for improvement to match the image:

- **Global Toolbar:** The image shows a global search bar and a filter icon. The current search is in `main_screen.dart`'s toolbar, but the filter icon needs to be added. The `HistoryScreen` has a redundant search bar that needs removal.
- **Sidebar Styling:** Background color and selected item appearance need adjustment.
- **Prompt List (History Screen):** Item styling (background, borders, rounded corners), header content (prompt count, bookmark filter icon), and removal of tags from list view.
- **Prompt Detail (History Screen):** Header icons (bookmark, share) and card styling (background, borders).
- **Color Palette:** Consistent use of grays, blues, and accent colors as per the image.
- **Iconography:** Update icons to match those in the image, preferring `CupertinoIcons` or suitable `MacosIcon` equivalents.
- **Component Styling:** Replace `GlassCard` with opaque containers in the History screen for consistency with the image's solid appearance.

## 3. Proposed Solution / Refactoring Strategy

### 3.1. High-Level Design / Architectural Overview

The refactoring will primarily involve modifying existing Flutter widgets within the `screens` and `widgets` directories. We will adjust `MacosThemeData` and inline styles to achieve the target look. The core application logic and state management (Providers) will largely remain unchanged, with modifications focused on the presentation layer.

### 3.2. Key Components / Modules

- `main.dart`: Adjust `MacosThemeData`.
- `screens/main_screen.dart`: Modify `MacosWindow`, `Sidebar`, `ToolBar`.
- `screens/history_screen.dart`: Overhaul `_buildSearchHeader`, `_buildPromptListItem`, `_buildPromptDetailHeader`, and card styling within `_buildOriginalPrompt` and `_buildEnhancementSection`.
- Icons: Replace Material Design icons with `CupertinoIcons` or `MacosIcons` where appropriate.

### 3.3. Detailed Action Plan / Phases

**Phase 1: Global Styles & Main Layout Adjustments**

- Objective(s): Update the main application theme, window background, sidebar, and global toolbar.
- **Priority:** High
- **Task 1.1: Theme & Window Background**
  - **Rationale/Goal:** Establish base colors.
  - **File(s):** `main.dart`
  - **Actions:**
    - In `PromptyApp`'s `MacosApp`, ensure `MacosThemeData.light()` and `dark()` are configured.
    - Set `primaryColor` in `MacosThemeData` to the blue accent color seen in the image (e.g., a standard `MacosColors.systemBlueColor`).
    - The `MainScreen`'s background `LinearGradient` currently results in `0xFFF2F2F2` for light mode. This is a suitable light gray for the main window background and can be kept.
  - **Deliverable/Criteria for Completion:** Main window background and accent color match the image's intent.
- **Task 1.2: Sidebar Styling**
  - **Rationale/Goal:** Match sidebar appearance (background, item selection).
  - **File(s):** `screens/main_screen.dart`
  - **Actions:**
    - Modify the `Sidebar` in `MacosWindow`.
    - Set its background color to a distinct light gray, slightly darker than the main window background (e.g., `MacosColors.underPageBackgroundColor` or a custom `BoxDecoration`).
    - Ensure `SidebarItems` `selectedColor` (or theme equivalent) makes the selected item background blue and text/icon white. `MacosThemeData`'s `primaryColor` should influence this.
    - Verify sidebar icons: Enhance (lightbulb - `CupertinoIcons.sparkles`), History (clock - `CupertinoIcons.time`), Settings (gear - `CupertinoIcons.gear`). These are acceptable.
  - **Deliverable/Criteria for Completion:** Sidebar background, selected item style, and icons match the image.
- **Task 1.3: Global Toolbar Update**
  - **Rationale/Goal:** Implement the global search and filter icon as shown in the image.
  - **File(s):** `screens/main_screen.dart`
  - **Actions:**
    - The `ToolBar` already contains a `CustomToolbarItem` for `MacosSearchField`. Ensure its placeholder is "Search prompts...".
    - Add a `ToolBarIconButton` to the `actions` list of the `ToolBar` for the filter icon (sliders, e.g., `MacosIcon(CupertinoIcons.slider_horizontal_3)`). Position it to the right of the search field, potentially using `ToolBarSpacer` if needed for far-right alignment.
  - **Deliverable/Criteria for Completion:** Toolbar contains the search field and filter icon as per the image.

**Phase 2: History Screen - Prompt List Pane UI**

- Objective(s): Refactor the left pane of the History screen (prompt list).
- **Priority:** High
- **Task 2.1: Prompt List Header (`_buildSearchHeader`)**
  - **Rationale/Goal:** Match the header content below the global toolbar.
  - **File(s):** `screens/history_screen.dart`
  - **Actions:**
    - Remove the `MacosSearchField` from `_buildSearchHeader` (global search is now in `main_screen.dart`'s toolbar).
    - Modify the `Row` in `_buildSearchHeader`:
      - Keep the `Text` widget displaying "X prompts".
      - Replace export and favorite filter `MacosIconButton`s with a single `MacosIconButton` for a bookmark/filter icon (e.g., `MacosIcon(CupertinoIcons.bookmark)`). This icon will act as the filter toggle.
    - Adjust padding and alignment to match the image. The background of this header should be the pane background.
  - **Deliverable/Criteria for Completion:** Prompt list header shows prompt count and a bookmark filter icon.
- **Task 2.2: Prompt List Item Styling (`_buildPromptListItem`)**
  - **Rationale/Goal:** Update individual prompt item appearance.
  - **File(s):** `screens/history_screen.dart`
  - **Actions:**
    - Modify the `BoxDecoration` of the `Container` for each list item:
      - Add `borderRadius: BorderRadius.circular(6.0)` (or similar small radius).
      - **Selected State (`isSelected`):**
        - Background color: Light blue (e.g., `MacosTheme.of(context).primaryColor.withOpacity(0.2)`).
        - Border: `Border.all(color: MacosTheme.of(context).primaryColor, width: 1.5)`.
      - **Unselected State:**
        - Background color: Light gray (e.g., `MacosTheme.of(context).brightness == Brightness.dark ? MacosColors.controlBackgroundColor.darkColor.withOpacity(0.5) : MacosColors.controlBackgroundColor.color.withOpacity(0.5)` or a color slightly different from the pane background).
        - Border: `Border.all(color: MacosColors.separatorColor.withOpacity(0.5))` or `Border.all(color: Colors.transparent)` if no border for unselected. The image suggests a very subtle separation or just background change.
    - Remove the existing `border: Border(bottom: ...)` if full rounded rectangle items are used.
    - Remove the `Wrap` displaying `prompt.tags` to match the image.
    - Ensure the "more options" icon is `MacosIcon(CupertinoIcons.ellipsis)`.
    - Ensure the favorite icon (if `prompt.isFavorite`) is `MacosIcon(CupertinoIcons.heart_fill, color: MacosColors.systemRedColor)`.
  - **Deliverable/Criteria for Completion:** Prompt list items are styled with rounded corners, correct backgrounds/borders for selected/unselected states, and content matches the image.
- **Task 2.3: Vertical Divider**
  - **Rationale/Goal:** Ensure the divider between panes is styled correctly.
  - **File(s):** `screens/history_screen.dart`
  - **Actions:**
    - Verify `VerticalDivider(width: 1)` uses `MacosColors.separatorColor`.
  - **Deliverable/Criteria for Completion:** Divider is present and subtly styled.

**Phase 3: History Screen - Prompt Detail Pane UI**

- Objective(s): Refactor the right pane of the History screen (prompt details).
- **Priority:** High
- **Task 3.1: Prompt Detail Header (`_buildPromptDetailHeader`)**
  - **Rationale/Goal:** Update title and action icons.
  - **File(s):** `screens/history_screen.dart`
  - **Actions:**
    - Ensure "Prompt Details" `Text` uses `MacosTheme.of(context).typography.largeTitle.copyWith(fontWeight: FontWeight.w700)` or adjust to match image's prominence.
    - Update action icons in the `Row`:
      - Favorite toggle: `MacosIconButton` with `MacosIcon(_selectedPrompt!.isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart, color: _selectedPrompt!.isFavorite ? MacosColors.systemRedColor : MacosColors.secondaryLabelColor)`.
      - Bookmark toggle icon: Add `MacosIconButton` with `MacosIcon(CupertinoIcons.bookmark_fill / CupertinoIcons.bookmark)`. (Functionality to be decided, for now, UI element).
      - Share/Upload icon: Add `MacosIconButton` with `MacosIcon(CupertinoIcons.share)`. (Functionality to be decided).
      - Remove the current copy icon from this header.
  - **Deliverable/Criteria for Completion:** Detail header title style and icons match the image.
- **Task 3.2: Content Card Styling (`_buildOriginalPrompt`, `_buildEnhancementSection`)**
  - **Rationale/Goal:** Style the content cards for original prompt and enhancements.
  - **File(s):** `screens/history_screen.dart`
  - **Actions:**
    - For the main `Container` of each card:
      - Background color: A light gray, slightly distinct from the pane background (e.g., `MacosTheme.of(context).controlBackgroundColor` or `MacosTheme.of(context).canvasColor` if configured to be different from the main window).
      - `borderRadius: BorderRadius.circular(8.0)`.
      - `border: Border.all(color: MacosColors.separatorColor.withOpacity(0.7), width: 1.0)`.
    - For enhancement card headers (e.g., "PROFESSIONAL"):
      - The background color `_getStyleColor(style).withOpacity(0.1)` can be kept if subtle, or changed to a solid light gray matching the card body but with a top border. The image suggests the header is part of the card.
      - Ensure the copy icon within the enhancement card header is `MacosIcon(CupertinoIcons.doc_on_doc)`.
    - Ensure font for card titles ("Original Prompt", "Professional") is `MacosTheme.of(context).typography.headline.copyWith(fontWeight: FontWeight.w600)`.
  - **Deliverable/Criteria for Completion:** Content cards are styled with rounded corners, appropriate backgrounds, and borders.

**Phase 4: Iconography & Typography Review**

- Objective(s): Ensure all icons and typography are consistent with macOS guidelines and the image.
- **Priority:** Medium
- **Task 4.1: Global Icon Review**
  - **Rationale/Goal:** Standardize icons across the updated screens.
  - **File(s):** All modified `.dart` files.
  - **Actions:**
    - Systematically replace any remaining Material `Icons` with `CupertinoIcons` or `MacosIcon` equivalents in the refactored areas.
    - Refer to the thought process for specific icon suggestions (e.g., `CupertinoIcons.slider_horizontal_3` for filter, `CupertinoIcons.bookmark` for bookmark, `CupertinoIcons.share` for share, `CupertinoIcons.doc_on_doc` for copy).
  - **Deliverable/Criteria for Completion:** Consistent use of macOS-style icons.
- **Task 4.2: Typography Consistency Check**
  - **Rationale/Goal:** Ensure font sizes and weights match the hierarchy implied by the image.
  - **File(s):** All modified `.dart` files.
  - **Actions:**
    - Review `MacosTheme.of(context).typography` usage (e.g., `largeTitle`, `title2`, `title3`, `headline`, `body`, `caption1`). Adjust `copyWith` for `fontWeight` where needed to match visual hierarchy in the image.
  - **Deliverable/Criteria for Completion:** Typography is clear, legible, and follows macOS conventions.

**Phase 5: Refinement & Testing**

- Objective(s): Final polish, cross-theme testing, and addressing any visual inconsistencies.
- **Priority:** Medium
- **Task 5.1: Light/Dark Mode Testing**
  - **Rationale/Goal:** Ensure the UI looks correct in both light and dark themes.
  - **Actions:**
    - Test all refactored screens in both light and dark mode.
    - Adjust colors if any element does not adapt well (e.g., using `MacosTheme.brightnessOf(context)` for conditional styling if `MacosColors` don't adapt automatically).
  - **Deliverable/Criteria for Completion:** UI is visually appealing and functional in both themes.
- **Task 5.2: Pixel Perfection Review**
  - **Rationale/Goal:** Compare implemented UI against the image for minor adjustments.
  - **Actions:**
    - Fine-tune padding, margins, border widths, corner radii.
  - **Deliverable/Criteria for Completion:** Implemented UI closely matches the reference image.
- **Task 5.3: Performance Check**
  - **Rationale/Goal:** Ensure UI changes haven't introduced performance issues.
  - **Actions:**
    - Briefly check for smooth scrolling and transitions.
  - **Deliverable/Criteria for Completion:** UI remains responsive.

### 3.4. Data Model Changes

No data model changes are anticipated for this UI-focused refactoring.

### 3.5. API Design / Interface Changes

No API or internal interface changes are anticipated.

## 4. Key Considerations & Risk Mitigation

### 4.1. Technical Risks & Challenges

- **Exact Color Matching:** Achieving exact color matches from an image can be tricky. Will use standard `MacosColors` and visual approximation.
  - **Mitigation:** Use a color picker tool on the image for guidance. Prioritize adherence to macOS palette over exact RGB values if they conflict with system feel.
- **`macos_ui` Limitations:** Some very specific styling details might be constrained by the `macos_ui` package's capabilities.
  - **Mitigation:** Work within the package's features. If a critical style is unachievable, document it and propose the closest alternative.
- **Styling `GlassCard` vs. Opaque:** The image shows opaque elements in History. If `GlassCard` is used elsewhere (e.g., Enhance tab), ensure changes to History don't negatively impact those, or decide if `GlassCard` should be replaced globally for consistency if the new style is preferred. This plan focuses on History screen to be opaque.

### 4.2. Dependencies

- Internal: Tasks within phases are generally sequential. Phases can be worked on with some overlap once foundational elements (like theme) are set.
- External: Relies on the `macos_ui` package. Ensure it's updated to a recent version.

### 4.3. Non-Functional Requirements (NFRs) Addressed

- **Usability:** Improved visual clarity and adherence to platform conventions should enhance usability.
- **Maintainability:** Using `MacosThemeData` and standard `macos_ui` components promotes maintainable UI code.
- **Consistency:** The changes aim for better visual consistency with macOS applications.

## 5. Success Metrics / Validation Criteria

- **Visual Comparison:** The updated UI, particularly the History screen, closely matches the provided design image when compared side-by-side.
- **Component Checklist:** All specified UI elements (sidebar, toolbar, list items, detail cards, icons, etc.) are updated as per the plan.
- **Light/Dark Mode Functionality:** The UI is correctly rendered and usable in both light and dark macOS themes.
- **User Feedback (if applicable):** Positive feedback on the new design's aesthetics and usability.

## 6. Assumptions Made

- The provided image is the single source of truth for the target design of the History screen and its surrounding chrome.
- The "Enhance" and "Settings" screens' content styling is out of scope for this specific task, though their container (sidebar, toolbar interaction) will be affected by global changes.
- Functionality of new icons (e.g., detail pane bookmark, share, global filter) will be implemented separately or is already planned; this task focuses on adding the UI elements.
- The `macos_ui` package is capable of achieving the required styling.
- Standard macOS fonts (San Francisco) will be used as provided by `macos_ui`.

## 7. Open Questions / Areas for Further Investigation

- **Functionality of New Icons:**
  - What is the exact behavior of the new filter icon (sliders) in the global toolbar?
  - What is the exact behavior of the new bookmark icon in the prompt detail header?
  - What is the exact behavior of the new share/upload icon in the prompt detail header?
  - What is the exact behavior of the bookmark icon in the prompt list sub-header (is it a filter for favorited/bookmarked items)?
- **`GlassCard` Usage:** Should `GlassCard` be removed from other parts of the app (e.g., Enhance tab) for overall visual consistency with the more opaque style shown in the History screen image, or is it acceptable to have mixed styles? This plan assumes opaque for History, leaving others as-is unless specified.
- **Specific Gray Shades:** While `MacosColors` will be used, precise shades for sidebar vs. card backgrounds vs. pane backgrounds might need slight adjustments during implementation for optimal visual hierarchy.
