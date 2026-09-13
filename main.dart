import 'package:flutter/material.dart';

void main() {
  runApp(const OfflineBibleApp());
}

// ==========================================
// 1. DATA MODELS & LOCAL DATABASE (Mocked)
// ==========================================

class BibleBook {
  final int id;
  final String name;
  final String abbreviation;
  final String testament;
  final String category;
  final int totalChapters;
  final List<String> chapters; // Mocked verses for demonstration

  BibleBook({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.testament,
    required this.category,
    required this.totalChapters,
    required this.chapters,
  });
}

// This simulates the "Pre-loaded SQLite/Isar Database"
class LocalBibleDatabase {
  static final List<BibleBook> books = [
    // --- OLD TESTAMENT ---
    // Books of Law
    BibleBook(id: 1, name: 'Genesis', abbreviation: 'Ge', testament: 'Old', category: 'Books of Law', totalChapters: 50, chapters: List.generate(50, (i) => 'Genesis Chapter ${i + 1} text...')),
    BibleBook(id: 2, name: 'Exodus', abbreviation: 'Exo', testament: 'Old', category: 'Books of Law', totalChapters: 40, chapters: List.generate(40, (i) => 'Exodus Chapter ${i + 1} text...')),
    BibleBook(id: 3, name: 'Leviticus', abbreviation: 'Lev', testament: 'Old', category: 'Books of Law', totalChapters: 27, chapters: List.generate(27, (i) => 'Leviticus Chapter ${i + 1} text...')),
    BibleBook(id: 4, name: 'Numbers', abbreviation: 'Num', testament: 'Old', category: 'Books of Law', totalChapters: 36, chapters: List.generate(36, (i) => 'Numbers Chapter ${i + 1} text...')),
    BibleBook(id: 5, name: 'Deuteronomy', abbreviation: 'Deut', testament: 'Old', category: 'Books of Law', totalChapters: 34, chapters: List.generate(34, (i) => 'Deuteronomy Chapter ${i + 1} text...')),
    // Books of History
    BibleBook(id: 6, name: 'Joshua', abbreviation: 'Josh', testament: 'Old', category: 'Books of History', totalChapters: 24, chapters: List.generate(24, (i) => 'Joshua Chapter ${i + 1} text...')),
    BibleBook(id: 7, name: 'Judges', abbreviation: 'Judg', testament: 'Old', category: 'Books of History', totalChapters: 21, chapters: List.generate(21, (i) => 'Judges Chapter ${i + 1} text...')),
    BibleBook(id: 8, name: 'Ruth', abbreviation: 'Ruth', testament: 'Old', category: 'Books of History', totalChapters: 4, chapters: List.generate(4, (i) => 'Ruth Chapter ${i + 1} text...')),
    BibleBook(id: 9, name: '1 Samuel', abbreviation: '1 Sam', testament: 'Old', category: 'Books of History', totalChapters: 31, chapters: List.generate(31, (i) => '1 Samuel Chapter ${i + 1} text...')),
    BibleBook(id: 10, name: '2 Samuel', abbreviation: '2 Sam', testament: 'Old', category: 'Books of History', totalChapters: 24, chapters: List.generate(24, (i) => '2 Samuel Chapter ${i + 1} text...')),

    // --- NEW TESTAMENT ---
    BibleBook(id: 40, name: 'Matthew', abbreviation: 'Matt', testament: 'New', category: 'The Gospels', totalChapters: 28, chapters: List.generate(28, (i) => 'Matthew Chapter ${i + 1} text...')),
    BibleBook(id: 41, name: 'Mark', abbreviation: 'Mark', testament: 'New', category: 'The Gospels', totalChapters: 16, chapters: List.generate(16, (i) => 'Mark Chapter ${i + 1} text...')),
    BibleBook(id: 42, name: 'Luke', abbreviation: 'Luke', testament: 'New', category: 'The Gospels', totalChapters: 24, chapters: List.generate(24, (i) => 'Luke Chapter ${i + 1} text...')),
    BibleBook(id: 43, name: 'John', abbreviation: 'John', testament: 'New', category: 'The Gospels', totalChapters: 21, chapters: List.generate(21, (i) => 'John Chapter ${i + 1} text...')),
    BibleBook(id: 44, name: 'Acts', abbreviation: 'Acts', testament: 'New', category: 'History', totalChapters: 28, chapters: List.generate(28, (i) => 'Acts Chapter ${i + 1} text...')),
    BibleBook(id: 45, name: 'Romans', abbreviation: 'Rom', testament: 'New', category: 'Pauline Epistles', totalChapters: 16, chapters: List.generate(16, (i) => 'Romans Chapter ${i + 1} text...')),
  ];

  // Simulated "Continue Reading" state (normally stored in SharedPreferences)
  static int lastReadBookId = 9; // 1 Samuel
  static int lastReadChapter = 10; // Chapter 10
}

// ==========================================
// 2. APP STATE MANAGEMENT
// ==========================================

class AppState extends ChangeNotifier {
  String _selectedTestament = 'Old';
  String _searchQuery = '';
  bool _isDarkMode = false;

  String get selectedTestament => _selectedTestament;
  String get searchQuery => _searchQuery;
  bool get isDarkMode => _isDarkMode;

  void setTestament(String testament) {
    _selectedTestament = testament;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

// ==========================================
// 3. MAIN APP & THEME
// ==========================================

class OfflineBibleApp extends StatefulWidget {
  const OfflineBibleApp({super.key});

  @override
  State<OfflineBibleApp> createState() => _OfflineBibleAppState();
}

class _OfflineBibleAppState extends State<OfflineBibleApp> {
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, child) {
        return MaterialApp(
          title: 'Offline Bible',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: _appState.isDarkMode ? Brightness.dark : Brightness.light,
            ),
            scaffoldBackgroundColor: _appState.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9F9F9),
            appBarTheme: AppBarTheme(
              backgroundColor: _appState.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: _appState.isDarkMode ? Colors.white : Colors.blue),
              titleTextStyle: TextStyle(
                color: _appState.isDarkMode ? Colors.white : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          home: MainNavigationScreen(appState: _appState),
        );
      },
    );
  }
}

// ==========================================
// 4. NAVIGATION & SCAFFOLD
// ==========================================

class MainNavigationScreen extends StatefulWidget {
  final AppState appState;
  const MainNavigationScreen({super.key, required this.appState});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      BibleScreen(appState: widget.appState),
      const LocalAIChatScreen(),
      const DailyVersesScreen(),
      const AudioBibleScreen(),
      const ReadingPlanScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: widget.appState.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Bible'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: 'Daily Verses'),
          BottomNavigationBarItem(icon: Icon(Icons.volume_up), label: 'Audio Bible'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Reading Plan'),
        ],
      ),
    );
  }
}

// ==========================================
// 5. SCREEN 1: BIBLE LIBRARY (Matches Screenshot)
// ==========================================

class BibleScreen extends StatelessWidget {
  final AppState appState;
  const BibleScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            // Open Settings Modal
            showModalBottomSheet(
              context: context,
              builder: (context) => Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      value: appState.isDarkMode,
                      onChanged: (val) {
                        appState.toggleTheme();
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('About Offline Bible'),
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        title: const Text('Bible'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: BibleSearchDelegate(LocalBibleDatabase.books),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // THE LIBRARY Section
                  Text(
                    'THE LIBRARY',
                    style: TextStyle(
                      color: appState.isDarkMode ? Colors.amber : const Color(0xFF8B5A2B),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${appState.selectedTestament} Testament',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: appState.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The books of law, history, poetry, and prophecy.',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Continue Reading Card
                  _buildContinueReadingCard(context),
                  const SizedBox(height: 16),

                  // Filter Bar
                  _buildFilterBar(context),
                  const SizedBox(height: 24),

                  // Dynamic Book List
                  _buildBookList(context),
                ],
              ),
            ),
          ),
          // Sticky Testament Toggle
          _buildTestamentToggle(context),
        ],
      ),
    );
  }

  Widget _buildContinueReadingCard(BuildContext context) {
    // Simulate fetching the last read book
    final lastBook = LocalBibleDatabase.books.firstWhere(
      (b) => b.id == LocalBibleDatabase.lastReadBookId,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReadingScreen(
              book: lastBook,
              initialChapter: LocalBibleDatabase.lastReadChapter,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: appState.isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Continue Reading',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${lastBook.name} Chapter ${LocalBibleDatabase.lastReadChapter}',
                    style: TextStyle(
                      color: appState.isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.blue, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appState.isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: (val) => appState.setSearchQuery(val),
        style: TextStyle(color: appState.isDarkMode ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: 'Filter by books...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.filter_list, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBookList(BuildContext context) {
    // Filter Logic
    final filteredBooks = LocalBibleDatabase.books.where((book) {
      final matchesTestament = book.testament == appState.selectedTestament;
      final matchesSearch = book.name.toLowerCase().contains(appState.searchQuery.toLowerCase()) ||
          book.abbreviation.toLowerCase().contains(appState.searchQuery.toLowerCase());
      return matchesTestament && matchesSearch;
    }).toList();

    // Group by Category
    final groupedBooks = <String, List<BibleBook>>{};
    for (var book in filteredBooks) {
      if (!groupedBooks.containsKey(book.category)) {
        groupedBooks[book.category] = [];
      }
      groupedBooks[book.category]!.add(book);
    }

    if (groupedBooks.isEmpty) {
      return const Center(child: Text("No books found."));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedBooks.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                entry.key,
                style: TextStyle(
                  color: appState.isDarkMode ? Colors.grey[400] : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            ...entry.value.map((book) => _buildBookItem(context, book)),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildBookItem(BuildContext context, BibleBook book) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReadingScreen(book: book, initialChapter: 1),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: appState.isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              book.id.toString().padLeft(2, '0'),
              style: TextStyle(
                color: appState.isDarkMode ? Colors.grey[500] : Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${book.name} (${book.abbreviation})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: appState.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${book.totalChapters} CHAPTERS',
                    style: TextStyle(
                      fontSize: 12,
                      color: appState.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: appState.isDarkMode ? Colors.grey[400] : Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildTestamentToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: appState.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: Row(
        children: [
          _buildToggleButton('Old Testament', 'Old', context),
          const SizedBox(width: 8),
          _buildToggleButton('New Testament', 'New', context),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, String value, BuildContext context) {
    final isSelected = appState.selectedTestament == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => appState.setTestament(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : (appState.isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey[200]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : (appState.isDarkMode ? Colors.white : Colors.black),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 6. SCREEN: READING VIEW
// ==========================================

class ReadingScreen extends StatefulWidget {
  final BibleBook book;
  final int initialChapter;

  const ReadingScreen({super.key, required this.book, required this.initialChapter});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  late int _currentChapter;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.initialChapter;
    // Update "Continue Reading" state
    LocalBibleDatabase.lastReadBookId = widget.book.id;
    LocalBibleDatabase.lastReadChapter = _currentChapter;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chapterText = widget.book.chapters[_currentChapter - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.book.name} $_currentChapter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              // Show Chapter Selector Modal
              showModalBottomSheet(
                context: context,
                builder: (context) => ListView.builder(
                  itemCount: widget.book.totalChapters,
                  itemBuilder: (context, index) => ListTile(
                    title: Text('Chapter ${index + 1}'),
                    onTap: () {
                      setState(() => _currentChapter = index + 1);
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chapter $_currentChapter',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    chapterText,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      color: isDark ? Colors.grey[300] : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Chapter Navigation
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentChapter > 1
                      ? () => setState(() => _currentChapter--)
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
                ElevatedButton.icon(
                  onPressed: _currentChapter < widget.book.totalChapters
                      ? () => setState(() => _currentChapter++)
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 7. SCREEN: LOCAL AI CHAT (Simulated)
// ==========================================

class LocalAIChatScreen extends StatefulWidget {
  const LocalAIChatScreen({super.key});

  @override
  State<LocalAIChatScreen> createState() => _LocalAIChatScreenState();
}

class _LocalAIChatScreenState extends State<LocalAIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'role': 'ai', 'text': 'Hello! I am your local offline Bible assistant. Ask me anything about scripture.'}
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': _controller.text});
      _controller.clear();
      
      // Simulate Local RAG AI Processing
      _messages.add({
        'role': 'ai',
        'text': 'Based on my local search of the Bible, I found relevant verses. However, running a 2GB local LLM requires significant device resources. This is a simulated response to demonstrate the UI.'
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Local AI Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isUser 
                          ? Colors.blue 
                          : (isDark ? const Color(0xFF2C2C2C) : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser 
                            ? Colors.white 
                            : (isDark ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Ask about the Bible...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 8. SCREEN: DAILY VERSES
// ==========================================

class DailyVersesScreen extends StatelessWidget {
  const DailyVersesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Deterministic "Daily" Verse based on day of year
    final dayOfYear = int.parse(DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays.toString()) + 1;
    final verseIndex = (dayOfYear * 7) % LocalBibleDatabase.books.length;
    final book = LocalBibleDatabase.books[verseIndex];
    
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Verses')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.format_quote, size: 60, color: Colors.blue),
              const SizedBox(height: 20),
              Text(
                '"This is a simulated daily verse from ${book.name} Chapter 1. The actual text would be pulled dynamically from the local database."',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '- ${book.name} 1:1',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share),
                label: const Text('Share Verse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 9. SCREEN: AUDIO BIBLE (Simulated TTS)
// ==========================================

class AudioBibleScreen extends StatefulWidget {
  const AudioBibleScreen({super.key});

  @override
  State<AudioBibleScreen> createState() => _AudioBibleScreenState();
}

class _AudioBibleScreenState extends State<AudioBibleScreen> {
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Bible')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.headphones, size: 80, color: Colors.blue),
              ),
              const SizedBox(height: 40),
              Text(
                'Genesis Chapter 1',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Offline Text-to-Speech Engine',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              
              // Playback Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 40),
                    onPressed: () {},
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  const SizedBox(width: 20),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 40, color: Colors.white),
                      onPressed: () => setState(() => _isPlaying = !_isPlaying),
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 40),
                    onPressed: () {},
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              // Speed Control
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Speed: '),
                  DropdownButton<double>(
                    value: _playbackSpeed,
                    items: const [
                      DropdownMenuItem(value: 0.5, child: Text('0.5x')),
                      DropdownMenuItem(value: 1.0, child: Text('1.0x')),
                      DropdownMenuItem(value: 1.5, child: Text('1.5x')),
                      DropdownMenuItem(value: 2.0, child: Text('2.0x')),
                    ],
                    onChanged: (val) => setState(() => _playbackSpeed = val!),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 10. SCREEN: READING PLAN
// ==========================================

class ReadingPlanScreen extends StatelessWidget {
  const ReadingPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Simulate a 365-day plan progress
    final currentDay = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays + 1;
    final progress = currentDay / 365;

    return Scaffold(
      appBar: AppBar(title: const Text('Reading Plan')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your 365-Day Journey',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            
            // Progress Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Overall Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Day $currentDay of 365', style: const TextStyle(color: Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                    color: Colors.blue,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 8),
                  Text('${(progress * 100).toStringAsFixed(1)}% Complete', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Today's Reading
            Text(
              "Today's Reading",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Text('$currentDay', style: const TextStyle(color: Colors.white)),
              ),
              title: const Text('Genesis 1 - 3', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('The Beginning & The Fall'),
              trailing: const Icon(Icons.check_circle_outline, color: Colors.grey),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: Text('${currentDay + 1}', style: const TextStyle(color: Colors.black)),
              ),
              title: const Text('Genesis 4 - 6', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Cain, Abel, and Noah'),
              trailing: const Icon(Icons.lock_outline, color: Colors.grey),
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 11. SEARCH DELEGATE
// ==========================================

class BibleSearchDelegate extends SearchDelegate {
  final List<BibleBook> books;

  BibleSearchDelegate(this.books);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = books.where((book) =>
        book.name.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final book = results[index];
        return ListTile(
          title: Text(book.name),
          subtitle: Text('${book.totalChapters} Chapters'),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReadingScreen(book: book, initialChapter: 1),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}