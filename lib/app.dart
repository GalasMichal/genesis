import 'package:flutter/material.dart';

import 'screens/lernen_screen.dart';
import 'screens/songs_screen.dart';
import 'screens/stimmen_screen.dart';
import 'screens/ueben_screen.dart';
import 'theme.dart';

/// Root-Widget: Material 3, Dark Theme, Bottom Navigation.
class GenesisApp extends StatelessWidget {
  const GenesisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'genesis',
      debugShowCheckedModeBanner: false,
      theme: buildGenesisTheme(),
      themeMode: ThemeMode.dark,
      home: const HomeShell(),
    );
  }
}

/// Mobile-first Shell mit vier Hauptbereichen.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _goToTab(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      LernenScreen(onOpenTuner: () => _goToTab(3)),
      const UebenScreen(),
      const SongsScreen(),
      const StimmenScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Lernen',
          ),
          NavigationDestination(
            icon: Icon(Icons.mic_none_outlined),
            selectedIcon: Icon(Icons.mic),
            label: 'Üben',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_music_outlined),
            selectedIcon: Icon(Icons.library_music),
            label: 'Songs',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Stimmen',
          ),
        ],
      ),
    );
  }
}
