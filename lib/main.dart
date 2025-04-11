// main.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // นำเข้าหน้าจอล็อกอิน
import 'screens/dashboard_screen.dart'; // นำเข้าหน้าจอ Dashboard
import 'screens/products_page.dart'; // นำเข้า ProductScreen
import 'screens/SalesForm.dart'; 
import 'screens/logout.dart';
import 'screens/product_details.dart';
import 'package:shared_preferences/shared_preferences.dart'; // นำเข้า SharedPreferences

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Store App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return DashboardScreen(
            storeId: args['storeId'].toString(),
            storeName: args['storeName'],
          );
        },
         '/logout': (context) => LogoutPage(),
        '/products': (context) => ProductScreen(),
        '/Form': (context) => SalesForm(),
        '/product_details': (context) {
          final productId = ModalRoute.of(context)!.settings.arguments as int;
          return ProductDetailsPage(productId: productId);
        },
      },
    );
  }
}