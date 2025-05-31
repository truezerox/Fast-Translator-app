import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_footer.dart'; // here is your copywright footer widget


// Key for saving theme preference
const String kThemeModeKey = 'theme_mode';

// --- Language Data Model ---
class Language {
    final String code;
    final String name;

    Language({required this.code, required this.name});

    factory Language.fromJson(Map<String, dynamic> json) {
        return Language(
            code: json['code'] as String,
            name: json['name'] as String,
        );
    }
}

// --- Modified Language Service to load from JSON ---
class LanguageService {
    static List<Language>? _supportedLanguages;
    static List<Language>? _targetLanguages;

    static const String _languagesAssetPath = 'assets/lang.json';

    static Future<void> _loadLanguages() async {
        // Check if both are already loaded to prevent redundant loading.
        if (_supportedLanguages != null && _targetLanguages != null) return;

        try {
            final String jsonString = await rootBundle.loadString(_languagesAssetPath);
            final List<dynamic> jsonList = jsonDecode(jsonString);
            _supportedLanguages = jsonList.map((jsonItem) => Language.fromJson(jsonItem)).toList();
            // Ensure target languages are derived after supported languages are loaded
            _targetLanguages = _supportedLanguages?.where((lang) => lang.code != 'auto').toList();
            print("Languages loaded successfully: ${_supportedLanguages?.length} languages.");
        }
        catch (e) {
            print("Error loading lang.json from $_languagesAssetPath: $e");
            // Fallback to minimal defaults on error
            _supportedLanguages = [
                Language(code: 'auto', name: 'Auto Detect (Error)'),
                Language(code: 'en', name: 'English (Error)'),
            ];
            _targetLanguages = [Language(code: 'en', name: 'English (Error)')];
        }
    }

    static Future<List<Language>> getSupportedLanguages() async {
        if (_supportedLanguages == null) {
            await _loadLanguages();
        }
        return _supportedLanguages ?? [];
    }

    static Future<List<Language>> getTargetLanguages() async {
        // Ensure _loadLanguages is called if target is null, which also loads supported
        if (_targetLanguages == null) {
            await _loadLanguages();
        }
        return _targetLanguages ?? [];
    }
}

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await LanguageService._loadLanguages(); // Pre-load languages
    runApp(const MyTranslatorApp());
}

// Enum to represent theme modes
enum AppThemeMode {
    light,
    dark,
}

class MyTranslatorApp extends StatefulWidget {
    const MyTranslatorApp({super.key});

    @override
    _MyTranslatorAppState createState() => _MyTranslatorAppState();
}

class _MyTranslatorAppState extends State<MyTranslatorApp> {
    AppThemeMode _currentThemeMode = AppThemeMode.dark; // Default theme

    @override
    void initState() {
        super.initState();
        _loadThemeMode();
    }

    Future<void> _loadThemeMode() async {
        final prefs = await SharedPreferences.getInstance();
        final themeModeString = prefs.getString(kThemeModeKey);
        AppThemeMode newMode = AppThemeMode.dark; // Default if nothing is saved
        if (themeModeString == 'light') {
            newMode = AppThemeMode.light;
        }
        // Check if the widget is still in the tree (mounted) before calling setState
        if (mounted) {
            setState(() {
                    _currentThemeMode = newMode;
                }
            );
        }
    }

    void _toggleTheme() {
        setState(() {
                _currentThemeMode = _currentThemeMode == AppThemeMode.dark
                    ? AppThemeMode.light
                    : AppThemeMode.dark;
                _saveThemeMode(_currentThemeMode);
            }
        );
    }

    Future<void> _saveThemeMode(AppThemeMode mode) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            kThemeModeKey, mode == AppThemeMode.light ? 'light' : 'dark');
    }

    // Define Light Theme
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
                onSecondary: Colors.white,  // Text on secondary color
                onSurface: Colors.black87,  // Main text color on light surfaces
                onBackground: Colors.black87, // Main text color on background
            ),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white, // Text/icons on AppBar
                elevation: 2,
            ),
            textTheme: TextTheme( // Define text styles for light theme
                bodyLarge: TextStyle(color: Colors.black87),
                bodyMedium: TextStyle(color: Colors.black54),
                headlineSmall: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                titleMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                labelLarge: TextStyle(color: Colors.black54), // For button labels, etc.
                bodySmall: TextStyle(color: Colors.black54.withOpacity(0.7)) // For footer text
            ),
            inputDecorationTheme: InputDecorationTheme(
                labelStyle: TextStyle(color: Colors.black54),
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                ),
                filled: true,
                fillColor: Colors.grey[200],
            ),
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
            popupMenuTheme: PopupMenuThemeData( // For dropdown menus
                textStyle: TextStyle(color: Colors.black87), // Text color for dropdown items
                color: Colors.grey[50], // Background color of dropdown menu
            ),
        );
    }

    // Define Dark Theme
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
                onPrimary: Colors.orange,      // Text on primary
                onSecondary: Colors.orange,    // Text on secondary
                onSurface: Colors.orange,      //text color of the dropdown menu`s
                onBackground: Colors.white,   //
            ),
            scaffoldBackgroundColor: Colors.grey[900],
            appBarTheme: AppBarTheme(
                backgroundColor: Colors.black, // Dark AppBar
                foregroundColor: Colors.white, // Text/icons on AppBar
                elevation: 2,
            ),

            textTheme: TextTheme( // Define text styles for dark theme
                bodyLarge: TextStyle(color: Colors.orange), // text color of the translation text area.
                bodyMedium: TextStyle(color: Colors.white70),
                headlineSmall: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),// text color of the main text of introduction
                titleMedium: TextStyle(color: Colors.green, fontWeight: FontWeight.w600), // text color of the text *Translation* above the translation box
                labelLarge: TextStyle(color: Colors.white70),
                bodySmall: TextStyle(color: Colors.white70.withOpacity(0.7)) // For footer text
            ),
            inputDecorationTheme: InputDecorationTheme(
                labelStyle: TextStyle(color: Colors.white70),
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.green, width: 2.0),// dropdown menu`s selection color(border color)
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                filled: true,
                fillColor: Colors.grey[800],// fill color of the text field (enter text to translate)
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, //button color
                    foregroundColor: Colors.white,// text color button
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                    ),
                ),
            ),
            popupMenuTheme: PopupMenuThemeData( // For dropdown menus
                textStyle: TextStyle(color: Colors.white),
                color: Colors.grey[800], // Background color of dropdown menu
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Fast Translator', // app title
            theme: lightTheme, // Apply light theme
            darkTheme: darkTheme, // Apply dark theme
            themeMode: _currentThemeMode == AppThemeMode.light
                ? ThemeMode.light
                : ThemeMode.dark, // Control theme based on _currentThemeMode
            home: IntroductionPage(
                themeMode: _currentThemeMode,
                onThemeChanged: _toggleTheme,
            ),
        );
    }
}

class IntroductionPage extends StatelessWidget {
    final AppThemeMode themeMode;
    final VoidCallback onThemeChanged;

    const IntroductionPage({
        super.key,
        required this.themeMode,
        required this.onThemeChanged,
    });

    @override
    Widget build(BuildContext context) {
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
            appBar: AppBar(
                title: const Text('Free Translator App'),
                actions: [
                    IconButton(
                        icon: Icon(themeMode == AppThemeMode.dark
                                ? Icons.light_mode
                                : Icons.dark_mode),
                        onPressed: onThemeChanged,
                        tooltip: 'Toggle Theme',
                    ),
                ],
            ),
            //main body introduction page
            body: SingleChildScrollView(
                child: Center(
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                                SizedBox(height: MediaQuery.of(context).size.height * 0.05), // Add some top spacing
                                Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                        color: colorScheme.surface,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [

                                            //shadow of the logo img
                                            BoxShadow(
                                                color: themeMode == AppThemeMode.dark
                                                    ? Colors.black.withOpacity(0.3)
                                                    : Colors.grey.withOpacity(0.5),
                                                spreadRadius: 2.5,
                                                blurRadius: 5,
                                                offset: const Offset(0, 3),
                                            ),
                                        ],
                                    ),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                            'assets/logo.png', // path to your logo
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                                return Center(
                                                    //if image can`t be loaded add an stack image
                                                    child: Icon(
                                                        Icons.broken_image,
                                                        size: 50,
                                                        color: colorScheme.onSurface.withOpacity(0.5),
                                                    ),
                                                );
                                            },
                                        ),
                                    ),
                                ),
                                const SizedBox(height: 30),
                                Text(
                                    'Fast Translator App', //main text
                                    style: textTheme.headlineSmall,
                                    textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                    'Your free go-to translation tool for seamless language conversions.',//sub text
                                    style: textTheme.bodyLarge
                                        ?.copyWith(color: textTheme.bodyMedium?.color),
                                    textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 40),
                                ElevatedButton(
                                    onPressed: () {
                                        // Navigate to TranslationPage when button is pressed
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => TranslationPage(
                                                    themeMode: themeMode,
                                                    onThemeChanged: onThemeChanged,
                                                )),
                                        );
                                    },
                                    child: const Text('Lets Translate'),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height * 0.05), // Add some bottom spacing
                                const AppFooter(),//add the footer widget
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}

// end of introduction page
//changing of the themes

class TranslationPage extends StatefulWidget {
    final AppThemeMode themeMode;
    final VoidCallback onThemeChanged;

    const TranslationPage({
        super.key,
        required this.themeMode,
        required this.onThemeChanged,
    });

    @override
    _TranslationPageState createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
    final TextEditingController _inputController = TextEditingController();
    final GoogleTranslator _translator = GoogleTranslator();
    String _translatedText = '';
    bool _isLoading = false;
    //default selected languages for translation after loading
    String _sourceLanguage = 'auto';
    String _targetLanguage = 'en';

    late Future<List<Language>> _sourceLanguagesFuture;
    late Future<List<Language>> _targetLanguagesFuture;

    @override
    void initState() {
        super.initState();
        _sourceLanguagesFuture = LanguageService.getSupportedLanguages();
        _targetLanguagesFuture = LanguageService.getTargetLanguages();

        // Initialize default languages after futures complete, if necessary
        _targetLanguagesFuture.then((langs) {
                if (mounted && langs.isNotEmpty && !langs.any((l) => l.code == _targetLanguage)) {
                    // If 'en' is not in the loaded list (and list is not empty), default to first available
                    // This is a safeguard, assuming 'en' is generally available.
                    setState(() {
                            _targetLanguage = langs.first.code;
                        }
                    );
                }
            }
        );
    }

    Future<void> _translateText() async {
        if (!mounted) return;

        final inputText = _inputController.text.trim();
        if (inputText.isEmpty) {
            if (mounted) {
                setState(() {
                        _translatedText = '';
                    }
                );
            }
            return;
        }

        if (mounted) {
            setState(() {
                    _isLoading = true;
                    _translatedText = '';
                }
            );
        }

        try {
            final translation = await _translator.translate(
                inputText,
                from: _sourceLanguage,
                to: _targetLanguage,
            );
            if (mounted) {
                setState(() {
                        _translatedText = translation.text;
                    }
                );
            }
        }// error managment

        catch (e) {
            print("Translation error: $e");
            if (mounted) {
                setState(() {
                        _translatedText =
                        "Error: Could not translate text.\nPlease check your internet connection or language pair.";
                    }
                );
                if (context.mounted) { // Check context.mounted for ScaffoldMessenger
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Translation Error: ${e.toString().substring(0, (e.toString().length > 100) ? 100 : e.toString().length)}...')),
                    );
                }
            }
        }
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
        _inputController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;
        Color dropdownItemColor = colorScheme.onSurface; // Ensure this respects theme

        // main translator app page body
        return Scaffold(
            appBar: AppBar(
                title: const Text('Translate'),// title text
                actions: [
                    IconButton(
                        // Toggle theme button
                        icon: Icon(widget.themeMode == AppThemeMode.dark
                                ? Icons.light_mode
                                : Icons.dark_mode),
                        // MODIFIED: Added onPressed
                        onPressed: widget.onThemeChanged,
                        tooltip: 'Toggle Theme',
                    ),
                ],
            ),
            body: Padding(
                // MODIFIED: Changed padding to remove bottom padding for body
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                child: FutureBuilder<List<List<Language>>>(
                    future: Future.wait([_sourceLanguagesFuture, _targetLanguagesFuture]),
                    builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                        }
                        else if (snapshot.hasError) {
                            print("Error in TranslationPage FutureBuilder: ${snapshot.error}");
                            return Center(child: Text('Error loading languages: ${snapshot.error}'));
                        }
                        // error managment
                        else if (!snapshot.hasData ||
                            snapshot.data == null ||
                            snapshot.data!.length < 2 ||
                            snapshot.data![0].isEmpty ||
                            snapshot.data![1].isEmpty) {
                            return const Center(child: Text('Could not load language data. Please try again.'));
                        }
                        // Ensure the selected languages are still valid
                        final List<Language> sourceLanguages = snapshot.data![0];
                        final List<Language> targetLanguages = snapshot.data![1];

                        // Ensure the selected languages are still valid after loading
                        if (!sourceLanguages.any((lang) => lang.code == _sourceLanguage)) {
                            _sourceLanguage = sourceLanguages.isNotEmpty ? sourceLanguages.first.code : 'auto';
                        }
                        // Ensure the selected languages are still valid after loading
                        if (!targetLanguages.any((lang) => lang.code == _targetLanguage)) {
                            _targetLanguage = targetLanguages.isNotEmpty ? targetLanguages.first.code : 'en';
                        }

                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                        Expanded(
                                            child: DropdownButtonFormField<String>(
                                                decoration: const InputDecoration(
                                                    labelText: 'From',
                                                    filled: false, // Ensure this matches your theme design
                                                ),
                                                // MODIFIED: Added isExpanded
                                                isExpanded: true,
                                                value: _sourceLanguage,
                                                dropdownColor: colorScheme.surface, // Use theme color
                                                style: TextStyle(color: dropdownItemColor), // Ensure text color contrasts
                                                items: sourceLanguages.map((lang) {
                                                        return DropdownMenuItem(
                                                            value: lang.code,
                                                            // MODIFIED: Added TextOverflow.ellipsis
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
                                        // Swap button
                                        Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: Icon(Icons.swap_horiz, color: colorScheme.onSurface),
                                        ),
                                        Expanded(
                                            //expand to fill the space
                                            child: DropdownButtonFormField<String>(
                                                decoration: const InputDecoration(
                                                    labelText: 'To',
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
                                TextField(
                                    controller: _inputController,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter text to translate', // Fill text for textbox
                                    ),
                                    style: textTheme.bodyLarge
                                        ?.copyWith(color: colorScheme.onSurface),
                                    minLines: 3, //min lines for textbox
                                    maxLines: 5, //max lines for textbox
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                    //button action
                                    onPressed: _isLoading ? null : _translateText,
                                    child: _isLoading
                                        ? SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                AlwaysStoppedAnimation<Color>(colorScheme.onSecondary), // Use theme color
                                            ),
                                        )
                                        : const Text('Translate'),// text button translate
                                ),
                                const SizedBox(height: 20),
                                Text(
                                    'Translation:', // text above translation box
                                    style: textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                    child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                            color: colorScheme.surface, // Use theme color
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                                color: colorScheme.onSurface.withOpacity(0.12)),
                                            boxShadow: [
                                                BoxShadow(
                                                    //shadow of the translation box
                                                    color: widget.themeMode == AppThemeMode.dark
                                                        ? Colors.black.withOpacity(0.2)
                                                        : Colors.grey.withOpacity(0.4),
                                                    spreadRadius: 0,
                                                    blurRadius: 3,
                                                    offset: const Offset(0, 1),
                                                ),
                                            ],
                                        ),
                                        child: _isLoading && _translatedText.isEmpty
                                            ? Center(
                                                child: Text("Processing...",
                                                    style: textTheme.bodyMedium?.copyWith(
                                                        color:
                                                        colorScheme.onSurface.withOpacity(0.7))))
                                            : SingleChildScrollView( // Make translated text scrollable if it's very long
                                                child: Text(
                                                    _translatedText.isEmpty && !_isLoading
                                                        ? 'Your translation will appear here.'
                                                        : _translatedText,
                                                    style: textTheme.bodyLarge?.copyWith(
                                                        fontSize: 18,
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
            bottomNavigationBar: const AppFooter(),
        );
    }
}
