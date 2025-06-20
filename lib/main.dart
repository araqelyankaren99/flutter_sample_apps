import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _items = [];
  int _page = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  int _fetchCount = 0;

  @override
  void initState() {
    _getPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NotificationListener<ScrollEndNotification>(
          onNotification: (notification) {
            if (notification.metrics.maxScrollExtent ==
                notification.metrics.pixels) {
              _getPosts();
              return true;
            }
            return false;
          },
          child:
              _items.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: _items.length + 1,
                    itemBuilder: (context, index) {
                      if (index < _items.length) {
                        final item = _items[index];
                        return ListTile(title: Text(item));
                      } else {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Center(
                            child:
                                _hasMore
                                    ? const CircularProgressIndicator()
                                    : Text('No more data to load'),
                          ),
                        );
                      }
                    },
                  ),
        ),
      ),
    );
  }

  Future<void> _getPosts() async {
    _fetchCount++;
    print('fetchCount = $_fetchCount');
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    setState(() {});
    const limit = 25;
    final url = Uri.parse(
      'https://jsonplaceholder.typicode.com/posts?_limit=$limit&_page=$_page',
    );
    final response = await http.get(
      url,
      headers: {'User-Agent': 'FlutterApp/1.0', 'Accept': 'application/json'},
    );

    final statusCode = response.statusCode;
    final body = response.body;
    if (statusCode == 200) {
      final List newItems = json.decode(body);
      if (newItems.length < limit) {
        _hasMore = false;
      }
      setState(() {
        _page++;
        _isLoading = false;
      });
      _items.addAll(
        newItems.map<String>((item) {
          final number = item['id'];
          return 'Item $number';
        }),
      );
      setState(() {});
    }
  }
}
