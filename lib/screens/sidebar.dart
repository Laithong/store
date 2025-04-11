// screens/sidebar.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Sidebar extends StatefulWidget {
  final String storeId;

  Sidebar({required this.storeId});

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  List categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final url ='https://www.laiksv.com/store/api/sidebar_get_categories.php?store_id=${widget.storeId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['categories'] != null) {
          setState(() {
            categories = data['categories'];
          });
        } else {
          print('No categories found or success is false.');
        }
      } else {
        print('Failed to load categories. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching categories: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("LaiThong"),
            accountEmail: Text("thonglai768@gmail.com"),
          ),
          ...categories.map((category) {
            return ListTile(
              title: Text(category['category_name']),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/products',
                  arguments: category['category_id'], // ส่ง category_id
                );
              },
            );
          }).toList(),
          Divider(),
          ListTile(
            title: Text('Go to logout'),
            leading: Icon(Icons.note_add),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/logout',
              );
            },
          ),
        ],
      ),
    );
  }
}
