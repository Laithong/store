// screens/SalesForm.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SalesForm extends StatefulWidget {
  @override
  _SalesFormState createState() => _SalesFormState();
}

class _SalesFormState extends State<SalesForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers สำหรับเก็บค่าจาก TextFormField
  final TextEditingController _productIdController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceIntController = TextEditingController();
  final TextEditingController _priceOutController = TextEditingController();
  final TextEditingController _commissionController = TextEditingController();
  final TextEditingController _storeIdController = TextEditingController();

  Future<void> _submitData() async {
    // ตรวจสอบว่าแบบฟอร์มถูกต้อง
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('https://www.laiksv.com/store/api/insert.php');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "product_id": int.parse(_productIdController.text),
          "employee_id": int.parse(_employeeIdController.text),
          "quantity": int.parse(_quantityController.text),
          "price_int": double.parse(_priceIntController.text),
          "price_out": double.parse(_priceOutController.text),
          "commission": double.parse(_commissionController.text),
          "store_id": int.parse(_storeIdController.text),
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${result['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Sale'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _productIdController,
                decoration: InputDecoration(labelText: 'Product ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Product ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _employeeIdController,
                decoration: InputDecoration(labelText: 'Employee ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Employee ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Quantity';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceIntController,
                decoration: InputDecoration(labelText: 'Price (Int)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Price (Int)';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceOutController,
                decoration: InputDecoration(labelText: 'Price (Out)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Price (Out)';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _commissionController,
                decoration: InputDecoration(labelText: 'Commission'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Commission';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _storeIdController,
                decoration: InputDecoration(labelText: 'Store ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Store ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
