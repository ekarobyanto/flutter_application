import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (context) => HttpClientNotifier(
            baseUrl: "https://base-url",
            client: http.Client(),
          ),
        ),
        ChangeNotifierProxyProvider<HttpClientNotifier, UserProvider>(
          create: (context) =>
              UserProvider(client: context.read<HttpClientNotifier>()),
          update: (_, httpClientNotifier, userProvider) => UserProvider(
            client: httpClientNotifier,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class UserProvider extends ChangeNotifier {
  final HttpClientNotifier client;
  UserProvider({required this.client});

  User? _user;
  User? get user => _user;
  bool isLoading = false;
  String? errorMessage;

  getUser() async {
    isLoading = true;
    notifyListeners();
    try {
      _user = await client.get("/", (json) => User.fromJson(json)) ?? null;
    } catch (err) {
      print(err);
      errorMessage = "Gagal mendapatkan data User";
    }
    isLoading = false;
    notifyListeners();
  }
}

class User {
  final String id;
  final String username;

  User({required this.id, required this.username});
  User.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        username = json["username"];
}

class HttpClientNotifier extends ChangeNotifier {
  final String baseUrl;
  final http.Client client;
  HttpClientNotifier({required this.client, required this.baseUrl});

  Uri parseUri(String url) {
    return Uri.parse("$baseUrl$url");
  }

  Future<T?> get<T>(
    String url,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      Uri uri = parseUri(url);
      http.Response response = await client.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return fromJson(jsonData);
      } else {
        debugPrint("❌ Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Exception: $e");
      return null;
    }
  }

  Future<T?> post<T>(
    String url,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson, {
    Map<String, String>? headers,
  }) async {
    try {
      Uri uri = parseUri(url);
      headers ??= {"Content-Type": "application/json"};
      http.Response response = await client.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return fromJson(jsonData);
      } else {
        debugPrint("❌ Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Exception: $e");
      return null;
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ScaffoldExample(),
    );
  }
}

class ScaffoldExample extends StatefulWidget {
  const ScaffoldExample({super.key});

  @override
  State<ScaffoldExample> createState() => _ScaffoldExampleState();
}

class _ScaffoldExampleState extends State<ScaffoldExample> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const Center(child: Text('Home Page', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Search Page', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Profile Page', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Title Appbar"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print("floating action button onpress"),
        child: const Icon(
          Icons.add,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class PaddingExample extends StatelessWidget {
  const PaddingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class OverflowErrorExample extends StatelessWidget {
  const OverflowErrorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Overflow Error")),
      body: SizedBox(
        height: 100,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: List.generate(
            10,
            (index) => Container(
              width: 100,
              height: 100,
              color: index.isEven ? Colors.blue : Colors.green,
              margin: const EdgeInsets.all(4),
              child: Center(child: Text("Item $index")),
            ),
          ),
        ),
      ),
    );
  }
}

class CrossAxisAlignmentExample extends StatelessWidget {
  const CrossAxisAlignmentExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CrossAxisAlignment Example")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Column Example
            const Text(
              "Column - crossAxisAlignment: start",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              color: Colors.grey[300],
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Sejajar ke kiri
                children: [
                  Container(color: Colors.red, width: 100, height: 50),
                  Container(color: Colors.green, width: 150, height: 50),
                  Container(color: Colors.blue, width: 200, height: 50),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Row Example
            const Text(
              "Row - crossAxisAlignment: start",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              color: Colors.grey[300],
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Sejajar ke atas
                children: [
                  Container(color: Colors.red, width: 50, height: 100),
                  Container(color: Colors.green, width: 50, height: 150),
                  Container(color: Colors.blue, width: 50, height: 200),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '$_counter',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 200,
          height: 200,
          color: Colors.red,
          alignment: Alignment.center,
          child: Text(
            'Hello World',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }
}

class MyWidget2 extends StatelessWidget {
  const MyWidget2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.red,
              child: const Center(child: Text('Expanded 1')),
            ),
          ),
          Flexible(
            child: Container(
              color: Colors.green,
              height: 100,
              child: const Center(child: Text('Flexible (Default)')),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.blue,
              child: const Center(child: Text('Expanded 2 (Flex: 2)')),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Container(
              color: Colors.orange,
              child: const Center(child: Text('Flexible (Tight)')),
            ),
          ),
        ],
      ),
    );
  }
}

class InteractionExample extends StatefulWidget {
  const InteractionExample({super.key});
  @override
  _InteractionExampleState createState() => _InteractionExampleState();
}

class _InteractionExampleState extends State<InteractionExample> {
  String _text = "Tap the button!";

  void _changeText() {
    setState(() {
      _text = "Button Clicked!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Interaction Widget Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _text = "Container Tapped!";
                });
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.blue,
                child: Text(
                  _text,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changeText,
              child: const Text("Click Me"),
            ),
          ],
        ),
      ),
    );
  }
}

class UIWidget extends StatelessWidget {
  const UIWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("UI Widget Example")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Hello, Flutter!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Image.network(
                "https://picsum.photos/id/1/600/300",
                width: 150,
              ),
              const SizedBox(height: 20),
              const Icon(Icons.star, size: 50, color: Colors.amber),
              const SizedBox(height: 20),
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text("This is a Card Widget"),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text("More Info"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MediaQueryExample extends StatelessWidget {
  const MediaQueryExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          double width = MediaQuery.of(context).size.width;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: width * 0.5, //lebar 50% dari layar
                  height: 100,
                  color: Colors.blue,
                  child: const Center(child: Text("0.5 MediaQuery width Box")),
                ),
                Container(
                  width: width * 0.8, //lebar 80% dari layar
                  height: 100,
                  color: Colors.red,
                  child: const Center(child: Text("0.8 MediaQuery width Box")),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LayoutBuilderExample extends StatelessWidget {
  const LayoutBuilderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Responsive Layout",
        ),
      ),
      body: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          if (constraints.maxWidth > 600) {
            return const Center(
              child: Text(
                "Tablet/Desktop View",
                style: TextStyle(fontSize: 24),
              ),
            );
          } else {
            return const Center(
              child: Text(
                "Mobile View",
                style: TextStyle(fontSize: 18),
              ),
            );
          }
        },
      ),
    );
  }
}

class AspectRatioExample extends StatelessWidget {
  const AspectRatioExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AspectRatio Example')),
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9, // Menjaga rasio aspek gambar
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(
                image: NetworkImage('https://picsum.photos/id/0/500/333'),
                fit: BoxFit.cover, // Mengisi tanpa mengubah rasio aspek
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FlexibleExample extends StatelessWidget {
  const FlexibleExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flexible Example")),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 100,
            color: Colors.red,
          ),
          Row(
            children: [
              Flexible(
                flex: 2,
                child: Container(
                  height: 100,
                  color: Colors.green,
                  child: const Center(child: Text("Flexible 2")),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                  child: const Center(child: Text("Flexible 1")),
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            height: 100,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

class ExpandedExample extends StatelessWidget {
  const ExpandedExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expanded Example")),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 100,
            color: Colors.red,
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 100,
                  color: Colors.green,
                  child: const Center(child: Text("Expanded 2")),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 100,
                  width: 20,
                  color: Colors.blue,
                  child: const Center(child: Text("Expanded 1")),
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            height: 100,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

class MainAxisAlignmentExample extends StatelessWidget {
  const MainAxisAlignmentExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red,
                  border: Border.all(color: Colors.black),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.green,
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  border: Border.all(color: Colors.black),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.green,
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  border: Border.all(color: Colors.black),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.green,
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  border: Border.all(color: Colors.black),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.green,
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.blue,
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  border: Border.all(color: Colors.black),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.green,
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.blue,
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  border: Border.all(color: Colors.black),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.green,
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  border: Border.all(color: Colors.black),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.green,
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.blue,
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
