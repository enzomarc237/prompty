# prompty

A new Flutter project.

## Getting Started

# Prompty - AI-Powered Prompt Enhancement macOS App

Prompty is a native macOS application built with Flutter that helps users improve their prompts by generating three enhanced versions in different styles: Professional, Creative, and Technical.

## Features

### Core Functionality
- **Prompt Enhancement**: Takes user input and generates three improved versions
  - Professional/Formal style: Clear, business-oriented language
  - Creative/Brainstorming style: Imaginative and innovative approaches  
  - Technical/Structured style: Precise, detailed specifications
                                                                                                                                                                              
### User Interface
- **Native macOS Design**: Built with `macos_ui` for authentic macOS look and feel
- **Multi-Tab Interface**: Enhance, History, and Settings screens
- **Dark/Light Mode Support**: Follows system appearance preferences
- **Responsive Layout**: Clean, minimal design optimized for productivity

### Data Management
- **Local SQLite Database**: Stores prompts and enhancements locally
- **Search & Filter**: Find prompts by content, favorites, or date
- **Favorites System**: Mark important prompts for quick access
- **History Tracking**: Keep track of all enhanced prompts with timestamps

### System Integration
- **Clipboard Support**: Copy enhanced prompts with one click
- **Window Management**: Native macOS window controls and behavior
- **System Tray**: (Planned) Quick access from menu bar

## Technology Stack

- **Framework**: Flutter with Dart
- **UI Components**: macos_ui package for native macOS design
- **Database**: SQLite with sqflite_common_ffi
- **State Management**: Provider pattern
- **AI Integration**: Supports OpenAI GPT and Google Gemini APIs
- **Local Storage**: shared_preferences for app settings

## Architecture

The app follows a clean architecture pattern:

```
lib/
├── models/          # Data models (Prompt, AppSettings)
├── services/        # Business logic (Database, AI, Settings)
├── providers/       # State management
├── screens/         # UI screens
└── main.dart        # App entry point
```

## Setup & Installation

### Prerequisites
- macOS 10.15 or later
- Flutter SDK
- Xcode (for building)

### Configuration
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure your AI API key in Settings:
   - OpenAI: Get API key from OpenAI platform
   - Gemini: Get API key from Google AI Studio

### Building
```bash
flutter build macos --release
```

## Usage

1. **Enhance Prompts**: Enter your initial prompt in the main screen and click "Enhance"
2. **View History**: Browse all your enhanced prompts in the History tab
3. **Manage Settings**: Configure API providers and app preferences in Settings
4. **Copy Results**: Click the copy button next to any enhanced prompt

## API Integration

The app supports multiple AI providers:
- **OpenAI GPT**: Uses gpt-3.5-turbo for prompt enhancement
- **Google Gemini**: Uses gemini-pro model for enhancement

Each style uses specialized system prompts to guide the AI in generating appropriate enhancements.

## Roadmap

See [ROADMAP_MERGED.md](ROADMAP_MERGED.md) for detailed development phases and planned features including:
- System tray popup modal
- Speech-to-text input
- Community sharing platform
- Export functionality
- Advanced customization options

## License

This project is private and proprietary.

## Contributing

This is a personal project. If you find issues or have suggestions, please create an issue in the repository.
