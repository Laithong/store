// screens/product_details.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductDetailsPage extends StatefulWidget {
  final int productId;

  ProductDetailsPage({required this.productId});

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  Map<String, dynamic>? productDetails;
  bool isLoading = true;

  final _formKey = GlobalKey<FormState>();
  final _productIdController = TextEditingController();
  final _quantityController = TextEditingController(text: "1");
  final _priceIntController = TextEditingController();
  final _priceOutController = TextEditingController();
  final _commissionController = TextEditingController();
  final _storeIdController = TextEditingController();

  List<Map<String, dynamic>> _employeeList = [];
  int? _selectedEmployeeId;

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
    fetchEmployeeList();
  }

  Future<void> fetchProductDetails() async {
    final url = Uri.parse('https://www.laiksv.com/store/api/product_details.php?product_id=${widget.productId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success' && jsonResponse['data'] != null) {
          setState(() {
            productDetails = jsonResponse['data'][0];
            isLoading = false;
            _productIdController.text = productDetails!['product_id'].toString();
            _priceIntController.text = productDetails!['price_int'].toString();
            _priceOutController.text = productDetails!['price_out'].toString();
            _commissionController.text = productDetails!['commission'].toString();
            _storeIdController.text = productDetails!['store_id'].toString();
          });
        } else {
          setState(() {
            productDetails = null;
            isLoading = false;
          });
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchEmployeeList() async {
    final url = Uri.parse('https://www.laiksv.com/store/api/attendance.php?store_id=2');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success' && jsonResponse['data'] != null) {
          setState(() {
            _employeeList = List<Map<String, dynamic>>.from(jsonResponse['data']);
          });
        } else {
          print('No employees found');
        }
      } else {
        print('Failed to fetch employees. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching employees: $e');
    }
  }

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('https://www.laiksv.com/store/api/insert.php');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "product_id": int.parse(_productIdController.text),
          "employee_id": _selectedEmployeeId,
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
          _resetForm();
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

  void _resetForm() {
    setState(() {
      _quantityController.text = "1";
      _priceOutController.text = productDetails!['price_out'].toString();
      _commissionController.text = productDetails!['commission'].toString();
      _selectedEmployeeId = null;
    });
  }

  List<Widget> _generateEmployeeRadioButtons() {
    return [
      Wrap(
        spacing: 10,
        children: _employeeList.map((employee) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<int>(
              value: employee['employee_id'],
              groupValue: _selectedEmployeeId,
              onChanged: (value) {
                setState(() {
                  _selectedEmployeeId = value!;
                });
              },
            ),
            Text(employee['first_name']),
          ],
        )).toList(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Details')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : productDetails == null
              ? Center(child: Text('No details available for this product'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        Visibility(
                          visible: false,
                          child: TextFormField(
                            controller: _productIdController,
                            decoration: InputDecoration(labelText: 'Product ID'),
                            keyboardType: TextInputType.number,
                            readOnly: true,
                          ),
                        ),
                        ..._generateEmployeeRadioButtons(),
                        TextFormField(
                          controller: _quantityController,
                          decoration: InputDecoration(labelText: 'ຈຳນວນ'),
                          keyboardType: TextInputType.number,
                        ),
                        Visibility(
                          visible: false,
                          child: TextFormField(
                            controller: _priceIntController,
                            decoration: InputDecoration(labelText: 'Price (Int)'),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),
                        TextFormField(
                          controller: _priceOutController,
                          decoration: InputDecoration(labelText: 'ລາຄາຂາຍ'),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                        TextFormField(
                          controller: _commissionController,
                          decoration: InputDecoration(labelText: 'ເປີເຊັນ'),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                        ),
                        Visibility(
                          visible: false,
                          child: TextFormField(
                            controller: _storeIdController,
                            decoration: InputDecoration(labelText: 'Store ID'),
                            keyboardType: TextInputType.number,
                          ),
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
