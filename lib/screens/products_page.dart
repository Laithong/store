// screens/products_page.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // ✅ เพิ่ม intl

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    final int? categoryId = arguments is int ? arguments : null;

    if (categoryId == null || categoryId <= 0) {
      return Scaffold(
        appBar: AppBar(title: Text('Products')),
        body: Center(
          child: Text('Invalid category ID. Please provide a valid ID.'),
        ),
      );
    }

    Future<List<dynamic>> fetchProducts() async {
      final String apiUrl =
          'https://www.laiksv.com/store/api/product_get_productid.php?category_id=$categoryId';

      try {
        final response = await http.get(Uri.parse(apiUrl));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            return data['data'];
          } else {
            throw Exception(data['message'] ?? 'Unknown error occurred.');
          }
        } else {
          throw Exception("Failed to load products. Status Code: ${response.statusCode}");
        }
      } catch (error) {
        throw Exception("Error: $error");
      }
    }

    return Scaffold(
        appBar: AppBar(),
      body: FutureBuilder<List<dynamic>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final products = snapshot.data!;
            if (products.isEmpty) {
              return Center(child: Text("No products found."));
            }

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ຊື່ສິນຄ້າ')),
                    DataColumn(label: Text('ລາຄາ')),
                  ],
                  rows: products.map((product) {
                    final double price = double.tryParse(product['price_out']?.toString() ?? '0') ?? 0;
                    final String formattedPrice = NumberFormat("#,###", "en_US")
                        .format(price)
                        .replaceAll(",", ".");

                    return DataRow(cells: [
                      DataCell(
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/product_details',
                              arguments: product['product_id'],
                            );
                          },
                          child: Text(
                            product['product_name'] ?? 'N/A',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(formattedPrice),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            );
          } else {
            return Center(child: Text("No data available."));
          }
        },
      ),
    );
  }
}
