// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_footer.dart'; // Import for the custom footer widget.
import 'package:google_fonts/google_fonts.dart';

// Key used to save and retrieve the theme mode preference from SharedPreferences.
const String kThemeModeKey = 'theme_mode';

// --- Language Data Model ---

/// Represents a language with its code and name.
///
/// This class is used to structure language data, for example, when loading
/// languages from a JSON file.
class Language {
    /// The language code (e.g., "en", "es").
    final String code;
    /// The display name of the language (e.g., "English", "Spanish").
    final String name;

    /// Creates a [Language] instance.
    ///
    /// Both [code] and [name] are required.
    Language({required this.code, required this.name});

    /// Creates a [Language] instance from a JSON map.
    ///
    /// This factory constructor is useful for parsing language data from
    /// external sources like a JSON file.
    ///
    /// The [json] map is expected to contain 'code' and 'name' keys.
    factory Language.fromJson(Map<String, dynamic> json) {
        return Language(
            code: json['code'] as String,
            name: json['name'] as String,
        );
    }
}

// --- Modified Language Service to load from JSON ---

/// Service class for managing and providing lists of supported and target languages.
///
/// This service loads language data from a JSON asset file.
class LanguageService {
    // Static lists to cache loaded languages, preventing redundant loads.
    static List<Language>? _supportedLanguages;
    static List<Language>? _targetLanguages;

    /// Path to the JSON asset file containing language data.
    static const String _languagesAssetPath = 'assets/lang.json';

    /// Loads languages from the JSON asset file.
    ///
    /// This method is called internally to populate [_supportedLanguages] and
    /// [_targetLanguages]. It ensures that languages are loaded only once.
    ///
    /// If loading fails, it falls back to a minimal default set of languages
    /// and prints an error message in debug mode.
    /// If languages are already loaded, this method does nothing.

    static Future<void> _loadLanguages() async {
        // Prevent redundant loading if languages are already loaded.
        if (_supportedLanguages != null && _targetLanguages != null) return;

        try {
            // Load the JSON string from the asset.
            final String jsonString = await rootBundle.loadString(_languagesAssetPath);
            // Decode the JSON string into a list of dynamic objects.
            final List<dynamic> jsonList = jsonDecode(jsonString);
            // Map the JSON objects to Language instances.
            _supportedLanguages = jsonList.map((jsonItem) => Language.fromJson(jsonItem)).toList();
            // Derive target languages from supported languages, excluding 'auto' (auto-detect).
            _targetLanguages = _supportedLanguages?.where((lang) => lang.code != 'auto').toList();

            // Print success message in debug mode.
            if (kDebugMode) {
                print("Languages loaded successfully: ${_supportedLanguages?.length} languages.");
            }
        }
        catch (e) {
            // Print error message in debug mode.
            if (kDebugMode) {
                print("Error loading lang.json from $_languagesAssetPath: $e");
            }
            // Fallback to minimal defaults on error.
            _supportedLanguages = [
                Language(code: 'auto', name: 'Auto Detect (Error)'),
                Language(code: 'en', name: 'English (Error)'),
            ];
            _targetLanguages = [Language(code: 'en', name: 'English (Error)')];
        }
    }

    /// Returns a list of supported languages.
    ///
    /// If languages haven't been loaded yet, this method will trigger loading.
    /// Returns an empty list if loading fails or no languages are available.

    static Future<List<Language>> getSupportedLanguages() async {
        if (_supportedLanguages == null) {
            await _loadLanguages();
        }
        return _supportedLanguages ?? [];
    }

    /// Returns a list of target languages (excluding 'auto-detect').
    ///
    /// If languages haven't been loaded yet, this method will trigger loading.
    /// Returns an empty list if loading fails or no target languages are available.

    static Future<List<Language>> getTargetLanguages() async {
        if (_targetLanguages == null) {
            await _loadLanguages();
        }
        return _targetLanguages ?? [];
    }
}

/// The main entry point of the application.
///
/// Initializes Flutter bindings, pre-loads language data, and runs the app.

void main() async {
    // Ensure that Flutter bindings are initialized before calling async code.
    WidgetsFlutterBinding.ensureInitialized();
    // Pre-load language data before the app starts.
    await LanguageService._loadLanguages();
    // Run the main application widget.
    runApp(const MyTranslatorApp());
}

/// Enum to represent the available theme modes for the application.

enum AppThemeMode {
    /// Light theme mode.
    light,
    /// Dark theme mode.
    dark,
}

/// The root widget of the translator application.
///
/// This widget is a [StatefulWidget] because it manages the current theme mode.

class MyTranslatorApp extends StatefulWidget {
    /// Creates a [MyTranslatorApp] instance.
    const MyTranslatorApp({super.key});

    @override
    _MyTranslatorAppState createState() => _MyTranslatorAppState();
}

/// State class for [MyTranslatorApp].
///
/// Manages the current theme mode and provides methods to load, save, and toggle the theme.

class _MyTranslatorAppState extends State<MyTranslatorApp> {
    /// The current theme mode of the application. Defaults to dark mode.
    AppThemeMode _currentThemeMode = AppThemeMode.dark;

    @override
    void initState() {
        super.initState();
        // Load the saved theme mode when the app starts.
        _loadThemeMode();
    }

    /// Loads the saved theme mode from [SharedPreferences].
    ///
    /// If no theme mode is saved, it defaults to dark mode.
    /// Updates the state with the loaded theme mode.

    Future<void> _loadThemeMode() async {
        final prefs = await SharedPreferences.getInstance();
        final themeModeString = prefs.getString(kThemeModeKey);
        AppThemeMode newMode = AppThemeMode.dark; // Default if nothing is saved
        if (themeModeString == 'light') {
            newMode = AppThemeMode.light;
        }
        // Ensure the widget is still mounted before calling setState.
        if (mounted) {
            setState(() {
                    _currentThemeMode = newMode;
                }
            );
        }
    }

    /// Toggles the current theme mode between light and dark.
    ///
    /// Saves the new theme mode to [SharedPreferences].

    void _toggleTheme() {
        setState(() {
                _currentThemeMode = _currentThemeMode == AppThemeMode.dark
                    ? AppThemeMode.light
                    : AppThemeMode.dark;
                _saveThemeMode(_currentThemeMode);
            }
        );
    }

    /// Saves the given [AppThemeMode] to [SharedPreferences].

    Future<void> _saveThemeMode(AppThemeMode mode) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            kThemeModeKey, mode == AppThemeMode.light ? 'light' : 'dark');
    }

    /// Defines the light theme for the application.
    ///
    /// Configures colors, text styles, and other theme properties for light mode.

    ThemeData get lightTheme {
        return ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.red,
                brightness: Brightness.light,
                primary: Colors.red,
                secondary: Colors.deepOrangeAccent,
                surface: Colors.grey[100]!, // Light surface for cards, dialogs
                background: Colors.white,   // Overall background
                onPrimary: Colors.white,    // Text on primary color
                onSecondary: Colors.orange,  // Text on secondary color
                onSurface: Colors.black,  // Main text color for footer and dropdown text
                onBackground: Colors.black87, // Main text color on background
            ),
            // Specific colors for the introduction page in light theme.
            scaffoldBackgroundColor: Color(0xFFC5E8E4), // Body background color
            appBarTheme: AppBarTheme(
                backgroundColor: Color(0xFF2F8BF5), // AppBar background color
                foregroundColor: Colors.black, // Text/icons color on AppBar
                elevation: 2,
            ),
            // Text styles for light theme.
            textTheme: TextTheme(
                bodyLarge: TextStyle(color: Colors.black), // For main translation text area.
                bodyMedium: TextStyle(color: Colors.black), // For paragraph text on the introduction page.
                headlineSmall: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), // For header text on the introduction page.
                titleMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.w700), // For "Translation" text above the translation box.
                labelLarge: TextStyle(color: Color(0xFF2FF59D)), // For button labels, interactive element highlights.
                bodySmall: TextStyle(color: Colors.black54) // For footer text.
            ),
            // Input decoration theme for text fields and dropdowns in light theme.
            inputDecorationTheme: InputDecorationTheme(
                labelStyle: TextStyle(color: Colors.black), // Label text color for dropdowns.
                hintStyle: TextStyle(color: Colors.grey[400]), // Hint text color for input fields.
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.pink, width: 2.0), // Border color when focused.
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.pink[400]!), // Border color when enabled.
                ),
                filled: true,
                fillColor: Colors.grey[200], // Background color of input fields.
            ),
            // ElevatedButton theme for light mode.
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                    ),
                ),
            ),
            // PopupMenuTheme for dropdown menus in light theme.
            popupMenuTheme: PopupMenuThemeData(
                textStyle: TextStyle(color: Colors.black87), // Text color for dropdown items.
                color: Colors.grey[50], // Background color of the dropdown menu.
            ),
        );
    }

    /// Defines the dark theme for the application.
    ///
    /// Configures colors, text styles, and other theme properties for dark mode.

    ThemeData get darkTheme {
        return ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.red, // Base seed color
                brightness: Brightness.dark,
                primary: Colors.black, // Example: Black primary for dark theme
                secondary: Colors.lightGreen, // Accent color
                surface: Colors.grey[850]!, // Dark surface for cards, dialogs
                background: Colors.grey[900]!, // Overall background
                onPrimary: Colors.orange,      // Text on primary color
                onSecondary: Colors.orange,    // Text on secondary color
                onSurface: Colors.orange,      // Text color for dropdown menu items
                onBackground: Colors.white,   // Main text color on background
            ),
            scaffoldBackgroundColor: Colors.grey[900], // Body background color
            appBarTheme: AppBarTheme(
                backgroundColor: Colors.black, // Dark AppBar background
                foregroundColor: Colors.white, // Text/icons on AppBar
                elevation: 2,
            ),
            // Text styles for dark theme.
            textTheme: TextTheme(
                bodyLarge: TextStyle(color: Colors.orange), // For main translation text area.
                bodyMedium: TextStyle(color: Colors.white70), // For paragraph text.
                headlineSmall: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),// For header text on the introduction page.
                titleMedium: TextStyle(color: Colors.green, fontWeight: FontWeight.w600), // For "Translation" text above the translation box.
                labelLarge: TextStyle(color: Colors.white70), // For button labels.
                bodySmall: TextStyle(color: Colors.white70) // For footer text.
            ),
            // Input decoration theme for text fields and dropdowns in dark theme.
            inputDecorationTheme: InputDecorationTheme(
                labelStyle: TextStyle(color: Colors.white70), // Label text color for dropdowns.
                hintStyle: TextStyle(color: Colors.white54), // Hint text color for input fields.
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.green, width: 2.0),// Border color when focused.
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey[700]!), // Border color when enabled.
                ),
                filled: true,
                fillColor: Colors.grey[800],// Background color of input fields.
            ),
            // ElevatedButton theme for dark mode.
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Button background color
                    foregroundColor: Colors.white,// Button text color
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                    ),
                ),
            ),
            // PopupMenuTheme for dropdown menus in dark theme.
            popupMenuTheme: PopupMenuThemeData(
                textStyle: TextStyle(color: Colors.white), // Text color for dropdown items.
                color: Colors.grey[800], // Background color of the dropdown menu.
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            debugShowCheckedModeBanner: false, // Hides the debug banner.
            title: 'Fast Translator', // Title of the application.
            theme: lightTheme, // Applies the light theme.
            darkTheme: darkTheme, // Applies the dark theme.
            // Controls the active theme based on the current state.
            themeMode: _currentThemeMode == AppThemeMode.light
                ? ThemeMode.light
                : ThemeMode.dark,
            // Sets the initial page of the app.
            home: IntroductionPage(
                themeMode: _currentThemeMode,
                onThemeChanged: _toggleTheme, // Passes the theme toggle callback.
            ),
        );
    }
}

/// The introduction page of the application.
///
/// Displays a logo, app title, a brief description, and a button to navigate
/// to the [TranslationPage]. It also includes a theme toggle button in the AppBar.

class IntroductionPage extends StatelessWidget {
    /// The current theme mode.
    final AppThemeMode themeMode;
    /// Callback function to toggle the theme.
    final VoidCallback onThemeChanged;

    /// Creates an [IntroductionPage] instance.
    const IntroductionPage({
        super.key,
        required this.themeMode,
        required this.onThemeChanged,
    });

    @override
    Widget build(BuildContext context) {
        // Access theme data for styling.
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
            appBar: AppBar(
                title: const Text('Fast translator app'),
                centerTitle: true,
                actions: [
                    // Theme toggle button.
                    IconButton(
                        icon: Icon(themeMode == AppThemeMode.dark
                                ? Icons.light_mode // Show light mode icon in dark theme.
                                : Icons.dark_mode), // Show dark mode icon in light theme.
                        onPressed: onThemeChanged,
                        tooltip: 'Toggle Theme',
                    ),
                ],
            ),
            // Main content of the introduction page.
            body: SingleChildScrollView( // Allows scrolling if content overflows.
                child: Center(
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                                // Spacing from the top.
                                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                                // Logo container.
                                Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                        color: colorScheme.surface, // Background color from theme.
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                            // Shadow effect for the logo container.
                                            BoxShadow(
                                                color: themeMode == AppThemeMode.dark
                                                    ? Colors.black
                                                    : Colors.grey,
                                                spreadRadius: 2.5,
                                                blurRadius: 5,
                                                offset: const Offset(0, 3),
                                            ),
                                        ],
                                    ),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        // Application logo image.
                                        child: Image.asset(
                                            'assets/logo.png', // Path to the logo asset.
                                            fit: BoxFit.cover,
                                            // Error builder for when the image fails to load.
                                            errorBuilder: (context, error, stackTrace) {
                                                return Center(
                                                    child: Icon(
                                                        Icons.broken_image,
                                                        size: 50,
                                                        color: colorScheme.onSurface,
                                                    ),
                                                );
                                            },
                                        ),
                                    ),
                                ),
                                const SizedBox(height: 30),
                                // Application title text.
                                Text(
                                    'Fast Translator App',
                                    // Apply Google Fonts style.
                                    style: GoogleFonts.lato(
                                        textStyle: Theme.of(context).textTheme.headlineSmall,
                                        fontSize: 25.0,
                                        fontStyle: FontStyle.italic,
                                    ),
                                ),
                                const SizedBox(height: 15),
                                // Application subtitle/description.
                                Text(
                                    'Your free go-to translation tool for seamless language conversions.',
                                    style: GoogleFonts.adventPro(
                                        textStyle: Theme.of(context).textTheme.bodyLarge,
                                        fontSize: 15.0,
                                        fontStyle: FontStyle.italic,),
                                    textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 40),
                                // Button to navigate to the TranslationPage.
                                ElevatedButton(
                                    onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => TranslationPage(
                                                    // Pass theme information to the next page.
                                                    themeMode: themeMode,
                                                    onThemeChanged: onThemeChanged,
                                                )),
                                        );
                                    },
                                    child: const Text('Lets Translate'),
                                ),
                                // Spacing before the footer.
                                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                                // Application footer widget.
                                const AppFooter(),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}

// --- End of Introduction Page ---

// --- Translation Page ---

/// The main translation page of the application.
///
/// Allows users to input text, select source and target languages,
/// and view the translated text. Includes a theme toggle button.

class TranslationPage extends StatefulWidget {
    /// The current theme mode.
    final AppThemeMode themeMode;
    /// Callback function to toggle the theme.
    final VoidCallback onThemeChanged;

    /// Creates a [TranslationPage] instance.
    const TranslationPage({
        super.key,
        required this.themeMode,
        required this.onThemeChanged,
    });

    @override
    _TranslationPageState createState() => _TranslationPageState();
}

/// State class for [TranslationPage].
///
/// Manages the input text, translated text, loading state, selected languages,
/// and handles the translation process.
///
// --- Translation Page ---

// ... (other parts of your TranslationPage and _TranslationPageState remain the same)

class _TranslationPageState extends State<TranslationPage> {
    /// Controller for the text input field.
    final TextEditingController _inputController = TextEditingController();
    /// Instance of the GoogleTranslator for performing translations.
    final GoogleTranslator _translator = GoogleTranslator();
    /// Stores the translated text.
    String _translatedText = '';
    /// Indicates if a translation is currently in progress.
    bool _isLoading = false;
    /// Default selected source language code ('auto' for auto-detect).
    String _sourceLanguage = 'auto';
    /// Default selected target language code ('en' for English).
    String _targetLanguage = 'en';

    /// Future for loading source languages.
    late Future<List<Language>> _sourceLanguagesFuture;
    /// Future for loading target languages.
    late Future<List<Language>> _targetLanguagesFuture;

    @override
    void initState() {
        super.initState();
        // Initialize futures for loading languages.
        _sourceLanguagesFuture = LanguageService.getSupportedLanguages();
        _targetLanguagesFuture = LanguageService.getTargetLanguages();

        // After target languages are loaded, ensure the default target language is valid.
        _targetLanguagesFuture.then((langs) {
            // Check if the widget is still mounted and languages are loaded.
            if (mounted && langs.isNotEmpty && !langs.any((l) => l.code == _targetLanguage)) {
                // If the default target language ('en') is not in the list,
                // set the target language to the first available language.
                setState(() {
                    _targetLanguage = langs.first.code;
                }
                );
            }
        }
        );
    }

    /// Translates the input text using the selected languages.
    ///
    /// Updates the UI with the translated text or an error message.

    Future<void> _translateText() async {
        // Ensure the widget is still mounted.
        if (!mounted) return;

        final inputText = _inputController.text.trim();
        // If input text is empty, clear the translated text.
        if (inputText.isEmpty) {
            if (mounted) {
                setState(() {
                    _translatedText = '';
                }
                );
            }
            return;
        }

        // Set loading state to true.
        if (mounted) {
            setState(() {
                _isLoading = true;
                _translatedText = ''; // Clear previous translation.
            }
            );
        }

        try {
            // Perform the translation.
            final translation = await _translator.translate(
                inputText,
                from: _sourceLanguage,
                to: _targetLanguage,
            );
            // Update UI with the translated text.
            if (mounted) {
                setState(() {
                    _translatedText = translation.text;
                }
                );
            }
        }
        // Handle translation errors.
        catch (e) {
            if (kDebugMode) {
                print("Translation error: $e");
            }
            if (mounted) {
                setState(() {
                    _translatedText =
                    "Error: Could not translate text.\nPlease check your internet connection or language pair.";
                }
                );
                // Show a SnackBar with the error message.
                if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                // Display a shortened error message if it's too long.
                                'Translation Error: ${e.toString().substring(0, (e.toString().length > 100) ? 100 : e.toString().length)}...')),
                    );
                }
            }
        }
        // Ensure loading state is set to false, regardless of success or failure.
        finally {
            if (mounted) {
                setState(() {
                    _isLoading = false;
                }
                );
            }
        }
    }

    @override
    void dispose() {
        // Dispose the text controller when the widget is removed from the tree.
        _inputController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        // Access theme data for styling.
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;
        // Determine dropdown item text color based on the current theme.
        Color dropdownItemColor = colorScheme.onSurface;

        return Scaffold(
            appBar: AppBar(
                title: const Text('Translate'), // Title of the translation page.
                centerTitle: true,
                actions: [
                    // Theme toggle button.
                    IconButton(
                        icon: Icon(widget.themeMode == AppThemeMode.dark
                            ? Icons.light_mode
                            : Icons.dark_mode),
                        onPressed: widget.onThemeChanged, // Callback to toggle theme.
                        tooltip: 'Toggle Theme',
                    ),
                ],
            ),
            // Main content of the translation page.
            body: Padding(
                // Padding for the body content, excluding bottom padding to accommodate AppFooter.
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                // FutureBuilder to handle asynchronous loading of language lists.
                child: FutureBuilder<List<List<Language>>>(
                    future: Future.wait([_sourceLanguagesFuture, _targetLanguagesFuture]),
                    builder: (context, snapshot) {
                        // Show loading indicator while waiting for data.
                        if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                        }
                        // Show error message if loading languages fails.
                        else if (snapshot.hasError) {
                            if (kDebugMode) {
                                print("Error in TranslationPage FutureBuilder: ${snapshot.error}");
                            }
                            return Center(child: Text('Error loading languages: ${snapshot.error}'));
                        }
                        // Show error message if data is not available or empty.
                        else if (!snapshot.hasData ||
                            snapshot.data == null ||
                            snapshot.data!.length < 2 || // Expecting two lists (source and target)
                            snapshot.data![0].isEmpty ||
                            snapshot.data![1].isEmpty) {
                            return const Center(child: Text('Could not load language data. Please try again.'));
                        }

                        // Extract loaded languages.
                        final List<Language> sourceLanguages = snapshot.data![0];
                        final List<Language> targetLanguages = snapshot.data![1];

                        // Ensure currently selected languages are still valid after loading.
                        // If not, default to the first available language or a predefined default.
                        if (!sourceLanguages.any((lang) => lang.code == _sourceLanguage)) {
                            _sourceLanguage = sourceLanguages.isNotEmpty ? sourceLanguages.first.code : 'auto';
                        }
                        if (!targetLanguages.any((lang) => lang.code == _targetLanguage)) {
                            _targetLanguage = targetLanguages.isNotEmpty ? targetLanguages.first.code : 'en';
                        }

                        // Main layout for translation controls.
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                                // Row for language selection dropdowns and swap button.
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                        // Dropdown for selecting source language.
                                        Expanded(
                                            child: DropdownButtonFormField<String>(
                                                decoration: const InputDecoration(
                                                    labelText: 'From', // Label for the dropdown.
                                                    filled: false, // Ensure consistent with theme.
                                                ),
                                                isExpanded: true, // Allow dropdown to expand.
                                                value: _sourceLanguage, // Current selected value.
                                                dropdownColor: colorScheme.surface, // Background color of dropdown.
                                                style: TextStyle(color: dropdownItemColor), // Text style for items.
                                                items: sourceLanguages.map((lang) {
                                                    return DropdownMenuItem(
                                                        value: lang.code,
                                                        // Use TextOverflow.ellipsis for long language names.
                                                        child: Text(lang.name, overflow: TextOverflow.ellipsis, style: TextStyle(color: dropdownItemColor)),
                                                    );
                                                }
                                                ).toList(),
                                                onChanged: (value) {
                                                    if (value != null) {
                                                        setState(() {
                                                            _sourceLanguage = value;
                                                        }
                                                        );
                                                    }
                                                },
                                            ),
                                        ),
                                        // Swap languages button (visual only for now).
                                        Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: Icon(Icons.swap_horiz, color: colorScheme.onSurface),
                                        ),
                                        // Dropdown for selecting target language.
                                        Expanded(
                                            child: DropdownButtonFormField<String>(
                                                decoration: const InputDecoration(
                                                    labelText: 'To', // Label for the dropdown.
                                                    filled: false,
                                                ),
                                                isExpanded: true,
                                                value: _targetLanguage,
                                                dropdownColor: colorScheme.surface,
                                                style: TextStyle(color: dropdownItemColor),
                                                items: targetLanguages.map((lang) {
                                                    return DropdownMenuItem(
                                                        value: lang.code,
                                                        child: Text(lang.name, overflow: TextOverflow.ellipsis, style: TextStyle(color: dropdownItemColor)),
                                                    );
                                                }
                                                ).toList(),
                                                onChanged: (value) {
                                                    if (value != null) {
                                                        setState(() {
                                                            _targetLanguage = value;
                                                        }
                                                        );
                                                    }
                                                },
                                            ),
                                        ),
                                    ],
                                ),
                                const SizedBox(height: 20),
                                // Text field for inputting text to be translated.
                                TextField(
                                    controller: _inputController,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter text to translate', // Placeholder text.
                                    ),
                                    // Apply Google Fonts style to input text.
                                    style: GoogleFonts.lato(
                                        textStyle: textTheme.bodyLarge,
                                    ),
                                    minLines: 3, // Minimum lines for the text field.
                                    maxLines: 5, // Maximum lines for the text field.
                                ),
                                // START: ADDED CLEAR BUTTON

                                // Clear button to clear the input and translated text.
                                const SizedBox(height: 8), // Add some spacing
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                        icon: Icon(Icons.clear, color: colorScheme.secondary), // Use a color from your theme
                                        label: Text(
                                            'Clear',
                                            style: TextStyle(color: colorScheme.secondary), // Use a color from your theme
                                        ),
                                        onPressed: () {
                                            _inputController.clear();
                                            // Also clear the translated text when the input is cleared
                                            if (mounted) {
                                                setState(() {
                                                    _translatedText = '';
                                                });
                                            }
                                        },// Clear button action
                                        style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                        ),
                                    ),
                                ),
                                // END: ADDED CLEAR BUTTON


                                const SizedBox(height: 12), // Adjusted spacing if needed before Translate button
                                // Translate button.
                                ElevatedButton(
                                    // Disable button while loading.
                                    onPressed: _isLoading ? null : _translateText,
                                    child: _isLoading
                                    // Show loading indicator inside the button.
                                        ? SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            // Use theme color for the indicator.
                                            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onSecondary),
                                        ),
                                    )
                                        : const Text('Translate'), // Button text.
                                ),
                                const SizedBox(height: 20),
                                // Label for the translation output area.
                                Text(
                                    'Translation:',
                                    style: textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                // Container to display the translated text.
                                Expanded(
                                    child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                            color: colorScheme.surface, // Background color from theme.
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                                color: colorScheme.onSurface),
                                            boxShadow: [
                                                // Shadow effect for the translation box.
                                                BoxShadow(
                                                    color: widget.themeMode == AppThemeMode.dark
                                                        ? Colors.black
                                                        : Colors.grey,
                                                    spreadRadius: 0,
                                                    blurRadius: 3,
                                                    offset: const Offset(0, 1),
                                                ),
                                            ],
                                        ),
                                        // Display "Processing..." if loading and no text yet,
                                        // otherwise display the translated text or placeholder.
                                        child: _isLoading && _translatedText.isEmpty
                                            ? Center(
                                            child: Text("Processing...",
                                                style: textTheme.bodyMedium?.copyWith(
                                                    color: colorScheme.onSurface)))
                                        // Make translated text scrollable if it's long.
                                            : SingleChildScrollView(
                                            child: Text(
                                                _translatedText.isEmpty && !_isLoading
                                                    ? 'Your translation will appear here.' // Placeholder.
                                                    : _translatedText, // Translated text.
                                                style: textTheme.bodyLarge?.copyWith(
                                                    fontSize: 18, // Slightly larger font for readability.
                                                ),
                                            ),
                                        ),
                                    ),
                                ),
                            ],
                        );
                    },
                ),
            ),
            // Display the custom application footer.
            bottomNavigationBar: const AppFooter(),
        );
    }
}
