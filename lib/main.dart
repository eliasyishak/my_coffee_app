import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

import 'src/constants.dart';
import 'src/data/coffee_api.dart';
import 'src/ui/coffee_image_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final CoffeeAPI coffeeAPI = CoffeeAPI(
    documentsDirectory: await getApplicationDocumentsDirectory(),
  );
  await coffeeAPI.init();

  // Configure the logger to print to the console
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) =>
      // ignore: avoid_print
      print('${record.level.name}: ${record.time} - ${record.message}'));

  // Retrieve the bytes for the no internet image
  final asset = await rootBundle.load('assets/$kNoInternetFilename');
  final noInternetImage = CoffeeImage(
    basename: kNoInternetFilename,
    bodyBytes: asset.buffer.asUint8List(),
  );

  runApp(MyApp(
    coffeeAPI: coffeeAPI,
    noInternetImage: noInternetImage,
  ));
}

class MyApp extends StatelessWidget {
  final CoffeeAPI coffeeAPI;
  final CoffeeImage noInternetImage;

  const MyApp({
    super.key,
    required this.coffeeAPI,
    required this.noInternetImage,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        coffeeAPI: coffeeAPI,
        noInternetImage: noInternetImage,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final CoffeeAPI coffeeAPI;
  final CoffeeImage noInternetImage;

  const MyHomePage({
    super.key,
    required this.title,
    required this.coffeeAPI,
    required this.noInternetImage,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffee by Elias'),
      ),
      body: CoffeeImageWidget(
        coffeeAPI: widget.coffeeAPI,
        noInternetImage: widget.noInternetImage,
      ),
    );
  }
}
