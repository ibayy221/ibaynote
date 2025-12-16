import 'package:flutter/material.dart';
import 'pages/today_page.dart';
import 'pages/history_page.dart';
import 'pages/daily_detail_page.dart';
import 'services/storage_service.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService().init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final StorageService _store = StorageService();
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = _store.isDark;
  }

  void _toggleTheme() async {
    _isDark = !_isDark;
    await _store.setDark(_isDark);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final light = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
    ).copyWith(textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme));
    final dark = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      cardColor: const Color(0xFF111111),
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.white, brightness: Brightness.dark),
    ).copyWith(textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catatan Ibay',
      theme: _isDark ? dark : light,
      home: HomeRoot(onToggleTheme: _toggleTheme, isDark: _isDark),
    );
  }
}

class HomeRoot extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;
  const HomeRoot({super.key, required this.onToggleTheme, required this.isDark});

  @override
  State<HomeRoot> createState() => _HomeRootState();
}

class _HomeRootState extends State<HomeRoot> {
  int _index = 0;

  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  final pages = const [TodayPage(), HistoryPage()];

  Future<void> _quickAddTask() async {
    final todayKey = StorageService().getToday().dateKey;
    final text = await showDialog<String>(
      context: context,
      builder: (c) => SimpleDialog(
        title: const Text('Tambah Task'),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Tulis tugas...'),
              onSubmitted: (v) => Navigator.of(c).pop(v),
            ),
          )
        ],
      ),
    );
    if (text != null && text.trim().isNotEmpty) {
      await StorageService().addTodo(todayKey, text.trim());
      setState(() {});
    }
  }

  Future<void> _changeProfileImage() async {
    final picker = ImagePicker();
    try {
      final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
      if (file != null) {
        await StorageService().setProfilePath(file.path);
        setState(() {});
      }
    } catch (e) {
      // ignore
    }
  }

  List<DateTime> _datesInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);
    final days = nextMonth.difference(first).inDays;
    return List.generate(days, (i) => DateTime(month.year, month.month, i + 1));
  }


  @override
  Widget build(BuildContext context) {
    final profile = StorageService().profilePath;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Ibay'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          )
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: GestureDetector(
                onTap: _changeProfileImage,
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: profile != null ? Image.file(File(profile)).image : null,
                  child: profile == null ? const Icon(Icons.person_outline, size: 36) : null,
                ),
              ),
              accountName: const Text('Catatan Ibay'),
              accountEmail: const Text('Tap photo to change'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('This month', style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                    onPressed: () => setState(() => _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1)),
                    icon: const Icon(Icons.today))
              ]),
            ),
            SizedBox(
              height: 84,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: _datesInMonth(_focusedMonth).map((d) {
                  final key = DateFormat('yyyy-MM-dd').format(d);
                  final text = DateFormat('dd').format(d);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => DailyDetailPage(dateKey: key)));
                        setState(() {});
                      },
                      child: Chip(label: Column(mainAxisSize: MainAxisSize.min, children: [Text(text), Text(DateFormat('EEE').format(d), style: const TextStyle(fontSize: 10))])),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                TextButton.icon(onPressed: _changeProfileImage, icon: const Icon(Icons.photo_camera), label: const Text('Change photo')),
                TextButton.icon(onPressed: () async {
                  await StorageService().setProfilePath(null);
                  setState(() {});
                }, icon: const Icon(Icons.delete_outline), label: const Text('Remove'))
              ]),
            )
          ]),
        ),
      ),
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: _quickAddTask,
              tooltip: 'Tambah task',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History')
        ],
      ),
    );
  }
}

