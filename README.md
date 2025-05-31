# Fast Translator App

A Flutter-based mobile application designed for seamless and intuitive text translation. This application allows users to translate text between a wide variety of languages, featuring a clean user interface with support for both light and dark themes.

## Features

*   **Real-time Text Translation:** Utilizes the `translator` package (leveraging Google Translate) for accurate and fast translations.
*   **Multi-language Support:**
    *   Loads an extensive list of supported and target languages from a local JSON configuration (`assets/lang.json`).
    *   Includes an "Auto Detect" feature for the source language.
*   **Dual Theme System:**
    *   Offers both light and dark themes for user preference.
    *   Theme selection is persisted across app sessions using `SharedPreferences`.
    *   Custom-defined `ThemeData` for a polished look and feel in both modes.
*   **User-Friendly Interface:**
    *   **Introduction Page:** Welcomes users with the app logo, a brief description, and easy navigation to the translation screen.
    *   **Translation Page:** Provides intuitive controls for language selection, text input, and viewing translated output.
    *   Visual feedback for loading states and error messages.
*   **Custom Styling:** Incorporates Google Fonts for enhanced typography.
*   **Error Handling:** Implements mechanisms to manage and display errors during translation or language data loading.

## Core Components

*   **Language Service (`LanguageService`):** Manages the loading and caching of language lists from `assets/lang.json`, optimizing performance.
*   **Theme Management (`_MyTranslatorAppState`):** Handles theme state, persistence, and toggling logic.
*   **UI Widgets:**
    *   `MyTranslatorApp`: The root widget, setting up `MaterialApp` and theme configurations.
    *   `IntroductionPage`: The initial landing screen.
    *   `TranslationPage`: The primary interface for all translation tasks.
    *   `AppFooter`: A consistent footer element.

## Technologies Used

*   **Flutter:** For cross-platform mobile application development.
*   **Dart:** The programming language for Flutter.
*   **Packages:**
    *   `translator`: For core translation functionality.
    *   `shared_preferences`: For persisting theme preferences.
    *   `google_fonts`: For custom font integration.
    *   `flutter/services` (rootBundle): For loading local asset files (e.g., `lang.json`).

## Getting Started

### Prerequisites

*   Flutter SDK: [Installation Guide](https://flutter.dev/docs/get-started/install)
*   An IDE like Android Studio or VS Code with Flutter plugins.

### Installation

1.  **Clone the repository:**
2.  **Ensure `assets/lang.json` is present:**
    This file should contain a JSON array of language objects, each with a `code` and `name`. Example:
3. **Add `assets/logo.png`** to the `assets` folder.
4.  **Update `pubspec.yaml`** to include your assets:
5.  **Get dependencies:**
6.  **Run the application:**

## Usage

1.  Upon launching the app, you will be greeted by the **Introduction Page**.
2.  Tap the "Lets Translate" button to navigate to the **Translation Page**.
3.  On the Translation Page:
    *   Select the source language from the "From" dropdown (or leave as "Auto Detect").
    *   Select the target language from the "To" dropdown.
    *   Enter the text you wish to translate in the input field.
    *   Tap the "Translate" button.
    *   The translated text will appear in the designated area below.
4.  Toggle between light and dark themes using the theme icon in the AppBar on either page.

## Project Updates

### Version 0.2

*   Refined light theme color palette.
*   Integrated Google Fonts for improved text presentation.
*   Enhanced code comments for better maintainability and developer understanding.

### Version 0.1

*   Initial application setup.
*   Implementation of core light and dark mode functionality.
*   Development of the translation engine and basic error handling.
*   Addition of app footers and foundational code commenting.

## Future Enhancements (Optional)

*   Offline translation capabilities.
*   Voice input for translation.
*   Saving translation history.
*   More robust error reporting and retry mechanisms.




Here are some screenshots of the application:

<p align="center">
  <img src="/screenshots/introduction_white.jpg" alt="Introduction page in light theme" width="300"/>
  <img src="/screenshots/main_white.jpg" alt="Main translation page in light theme" width="300"/>
</p>
<p align="center">
  <img src="/screenshots/introduction_dark.jpg" alt="Introduction page in dark theme" width="300"/>
  <img src="/screenshots/main_dark.jpg" alt="Main translation page in dark theme" width="300"/>
</p>