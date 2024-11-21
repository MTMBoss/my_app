import 'package:flutter/material.dart';
import 'biglietti/biglietti.dart';
import 'time/time.dart';
import 'news/news.dart';
import 'pass/pass.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const BigliettiPage(),
    const TimePage(),
    const NewsPage(),
    const PassPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number, color: Colors.white),
            label: 'Biglietti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time, color: Colors.white),
            label: 'Time',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article, color: Colors.white),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock, color: Colors.white),
            label: 'Pass',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
