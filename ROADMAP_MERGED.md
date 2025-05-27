# Prompty: AI-Powered Prompt Enhancement Application - Complete Roadmap

## Project Description

Prompty is a native macOS application that helps users improve their prompts. The application takes an initial prompt and generates three enhanced versions in different styles. This comprehensive roadmap merges detailed development phases with the broader product vision.

## Development Phases

### Phase 1 - Basic User Interface (2-3 weeks)

- [x] Initial project configuration
- [ ] Main interface:
  - Initial prompt input area
  - 3 result areas for different styles
  - Enhancement button
- [ ] Consistent macOS theme
- [ ] Use [tray_manager](https://github.com/leanflutter/tray_manager) for menu bar icon
- [ ] Use [window_manager](https://github.com/leanflutter/window_manager) for window management (border, size, position, etc.):
  - Main window with custom border and size
  - Window positioning under menu bar with popup look (no borders)
  - Handle close and minimize events
- [ ] Use most [LeanFlutter](https://github.com/leanflutter) packages for basic functionality implementation:
  - Menu bar
  - Window management
  - Native notifications
  - Clipboard management

### Phase 2 - Business Logic (3-4 weeks)

- [ ] Implementation of three enhancement styles:
  - Professional/formal style
  - Creative/brainstorming style
  - Technical/structured style
- [ ] API service integration for prompt enhancement
- [ ] Error handling and loading states management

### Phase 3 - Advanced Features (2-3 weeks)

- [ ] History of enhanced prompts
- [ ] Favorites system
- [ ] Results export
- [ ] Keyboard shortcuts

### Phase 4 - Polish and Distribution (2 weeks)

- [ ] Thorough testing
- [ ] Performance optimizations
- [ ] Mac App Store preparation
- [ ] User documentation

## Key Features (MVP)

The Minimum Viable Product (MVP) includes:

1. **Clean and Minimal UI:** Intuitive interface designed for non-technical users
2. **Prompt Enhancement:** Core functionality to enhance prompts in three different styles
3. **Prompt Suggestions:** AI-powered suggestions based on simple user queries
4. **Prompt History:** Log of previously entered and enhanced prompts
5. **Customizable Enhancement Styles:** Settings to define improvement styles (creative, formal, technical, etc.) and models (Gemini, OpenAI, Deepseek, etc.)
6. **Favorite Prompts:** Feature to save and manage favorite enhanced prompts
7. **Prompt Organization:** Options to organize prompts using categories, tags, models, and styles
8. **Field-Based Organization:** Organization by fields such as design, coding, summarization, role-playing, characters, and search
9. **Speech-to-Text Prompting:** Voice recording and parsing to text for prompt generation
10. **Prompt Generation:** Feature to generate prompts based on user queries
11. **System Tray Popup Modal:** Popup modal in the system tray for quick access and prompt enhancement
12. **Offline First:** The app should primarily function offline
13. **Community Sharing:** Community for users to share, discover, and download prompts

## Target Audience

- Writers
- Marketers
- Developers
- Designers
- General users interested in leveraging AI tools effectively

## Technology Stack

- **Flutter & Dart:** For cross-platform development (macOS, Windows, Web, Android, iOS)
- **AI Model/API:** To be determined, research and selection of suitable AI model or API for prompt enhancement
- **`macos_ui` Package:** For native macOS style using provided components
- **Turso:** For offline-first SQLite storage with cloud sync capabilities, using libSQL abstraction
- **Additional Dart/Flutter Packages:**
  - System tray integration
  - Clipboard manipulation (copy/paste prompts)
  - Screenshot capture and OCR (image to prompt)
  - App launch at user login
  - Window manipulation for popup creation
  - Voice recording for speech-to-text

## Design and Aesthetics

Prompty will feature a minimalist, clean, and modern user interface. The design will prioritize simplicity and ease of use, with a focus on light and dark themes and limited color palettes. Inspiration will be drawn from existing macOS applications known for their intuitive design.

## Next Steps

1. Set up basic user interface
2. Configure project architecture
3. Implement first interface components

## Business Model

Subscription-based business model with a free tier that offers limited features. Paid tiers will provide access to advanced functionalities, increased usage limits, and additional customization options.

## Initial Questions and Uncertainties

- What is the most effective AI model or API for prompt enhancement? (Gemini, OpenAI, Deepseek, etc.)
- How can we ensure the quality and relevance of community-shared prompts?
- What is the optimal pricing strategy for the subscription tiers?
- How can we effectively market Prompty to a broad audience?