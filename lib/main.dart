import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solve Guide',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          background: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        useMaterial3: true,

        // Customizing AppBar Theme
        appBarTheme: const AppBarTheme(
          color: Colors.green,
          elevation: 4,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Customizing Button Theme
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.green,
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        // Other customizations
        // You can add more theme customizations here
      ),
      home: const MyHomePage(title: 'Solve Guide: Resolve Conflicts Faster'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('images/SolveGuideLogo.png', 
              width: 200,
              fit:BoxFit.scaleDown),
              const SizedBox(height: 75), // Adds space between image and text
              const Text(
                'Resolve conflicts faster, for good',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                ),
              const SizedBox(height: 75), // Adds space between image and text
              const Text(
                  'Are you tired of rehashing the same issues with the people in your life?\n\n'
                  'Do you feel like you get caught in the least important aspects of a conflict while the obvious root of the issue goes ignored and unresolved?\n\n'
                  'Do you feel like shared facts keep slipping into contested territory, causing debates to go in circles?\n\n'
                  'SolveGuide is a friendly tool that will guide you to solutions that last. You can use SolveGuide alone or with others to make progress on issues in your relationship, in the workplace or anywhere else you are struggling.\n\n'),
              const Text(
                'You have this many issues:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Create a New Issue',
        child: const Icon(Icons.map_outlined),
      ), 
    );
  }
}
