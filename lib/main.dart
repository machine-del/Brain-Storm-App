import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart' as di;

import 'features/tasks/presentation/bloc/tasks_bloc.dart';
import 'features/statistics/presentation/bloc/stats_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/achievements/presentation/bloc/achievements_bloc.dart';

import 'features/tasks/presentation/pages/home_page.dart';
import 'features/statistics/presentation/pages/stats_overview_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/achievements/presentation/pages/achievements_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<TasksBloc>()..add(LoadDailyTaskEvent())),
        BlocProvider(create: (_) => di.sl<StatsBloc>()..add(LoadStatsEvent())),
        BlocProvider(create: (_) => di.sl<ProfileBloc>()..add(LoadProfileEvent())),
        BlocProvider(create: (_) => di.sl<AchievementsBloc>()..add(LoadAchievementsEvent())),
      ],
      child: MaterialApp(
        title: 'Мозговой штурм',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const StatsOverviewPage(),
    const AchievementsPage(),
    const ProfilePage(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Главная',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bar_chart),
      label: 'Статистика',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.emoji_events),
      label: 'Достижения',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Профиль',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _bottomNavItems,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}