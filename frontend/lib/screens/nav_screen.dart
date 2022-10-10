import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:myflix/cubits/cubits.dart";
import "package:myflix/screens/screens.dart";
import 'package:myflix/spinners/fading_circle.dart';
import "package:myflix/widgets/widgets.dart";
import "package:myflix/server/server.dart";

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});

  @override
  NavScreenState createState() => NavScreenState();
}

class NavScreenState extends State<NavScreen> {
  late Future<bool> serverOk;

  final List<Widget> _screens = [
    const HomeScreen(key: PageStorageKey("homeScreen")),
    const Scaffold(),
    const Scaffold(),
    const Scaffold(),
    const Scaffold(),
  ];

  final Map<String, IconData> _icons = const {
    "Home": Icons.home,
    "Search": Icons.search,
    "Coming Soon": Icons.queue_play_next,
    "Downloads": Icons.file_download,
    "More": Icons.menu,
  };

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    serverOk = Config.shared.testServerConnection();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: serverOk,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: (Container(
              color: Colors.black,
              child: Center(
                  child: SpinKitFadingCircle(
                color: Colors.blueAccent,
                size: Responsive.isMobile(context) ? 80.0 : 120.0,
              )),
            )),
          );
        }
        return snapshot.data != true || snapshot.hasError
            ? const ServerSetupScreen()
            : Scaffold(
                body: BlocProvider<AppBarCubit>(
                  create: (_) => AppBarCubit(),
                  child: _screens[_currentIndex],
                ),
                bottomNavigationBar: !Responsive.isDesktop(context)
                    ? BottomNavigationBar(
                        type: BottomNavigationBarType.fixed,
                        backgroundColor: Colors.black,
                        items: _icons
                            .map((title, icon) => MapEntry(
                                title,
                                BottomNavigationBarItem(
                                  icon: Icon(icon, size: 30.0),
                                  label: title,
                                )))
                            .values
                            .toList(),
                        currentIndex: _currentIndex,
                        selectedItemColor: Colors.white,
                        selectedFontSize: 11.0,
                        unselectedItemColor: Colors.grey,
                        unselectedFontSize: 11.0,
                        onTap: (index) => setState(() => _currentIndex = index),
                      )
                    : null,
              );
      },
    );
  }
}
