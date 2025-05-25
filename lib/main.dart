import 'dart:ui' as ui;
import 'services/api_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictionary App',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
      ),
      home: HomeScreen(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

// HomeScreen WITH theme toggle and gradient title
class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();

  List<String> _definitions = [];
  bool _isLoading = false;
  String _error = '';

  void _searchWord() async {
    final word = _controller.text.trim();
    if (word.isEmpty) return;

    setState(() {
      _isLoading = true;
      _definitions = [];
      _error = '';
    });

    try {
      final result = await _apiService.fetchDefinition(word);
      setState(() {
        _definitions = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not find the word.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dictionary More Like \n A Describer',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = ui.Gradient.linear(
                const Offset(0, 20),
                const Offset(150, 20),
                <Color>[
                  const ui.Color.fromARGB(255, 54, 143, 244),
                  const ui.Color.fromARGB(255, 216, 33, 233),
                ],
              ),
          ),
        ),
        actions: [
          Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
          Switch(
            value: widget.isDarkMode,
            onChanged: (_) => widget.onToggleTheme(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onSubmitted: (_) => _searchWord(),
              decoration: InputDecoration(
                hintText: 'Enter a word...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchWord,
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (_error.isNotEmpty)
              Text(
                _error,
                style: const TextStyle(color: Colors.red),
              ),
            if (_definitions.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _definitions.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(_definitions[index]),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
