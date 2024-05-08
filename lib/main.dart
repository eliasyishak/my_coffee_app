import 'package:flutter/material.dart';

import 'src/data/coffee_api.dart';
import 'src/ui/coffee_image_widget.dart';

void main() async {
  final CoffeeAPI coffeeAPI = CoffeeAPI();
  WidgetsFlutterBinding.ensureInitialized();
  await coffeeAPI.init();

  runApp(MyApp(
    coffeeAPI: coffeeAPI,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.coffeeAPI,
  });

  final CoffeeAPI coffeeAPI;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        coffeeAPI: coffeeAPI,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final CoffeeAPI coffeeAPI;

  const MyHomePage({
    super.key,
    required this.title,
    required this.coffeeAPI,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coffee by Elias'),),
      body: CoffeeImageWidget(
        coffeeAPI: widget.coffeeAPI,
      ),
    );
  }
}
