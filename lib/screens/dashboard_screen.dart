// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 📅 จัดรูปแบบตัวเลข
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shimmer/shimmer.dart'; // ✨ เอฟเฟกต์โหลดข้อมูล
import 'sidebar.dart'; // 📂 Sidebar
import 'SalesForm.dart';

class DashboardScreen extends StatefulWidget {
  final String storeId;
  final String storeName;

  DashboardScreen({required this.storeId, required this.storeName});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> sales = [];
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchSalesData(); // ⏳ โหลดข้อมูล
    startPolling(); // 🔄 ตรวจสอบข้อมูลใหม่
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 🔄 ตรวจสอบข้อมูลใหม่ทุก 10 วินาที
  void startPolling() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchSalesData();
    });
  }

  // 📡 ดึงข้อมูลจาก API
  Future<void> fetchSalesData() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://www.laiksv.com/store/api/sales_today.php?store_id=${widget.storeId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          sales = json.decode(response.body);
        });
      } else {
        throw Exception('❌ Failed to load sales data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🚨 Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // 🎨 พื้นหลังสวย ๆ
      appBar: AppBar(
        title: Text(
          '🏬 ${widget.storeName}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
                actions: [
          IconButton(
            icon: Icon(Icons.visibility),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SalesForm(
                    // employeeId: widget.employeeId,
                    // firstName: widget.firstName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Sidebar(storeId: widget.storeId),
      body: RefreshIndicator(
        onRefresh: fetchSalesData,
        child: isLoading
            ? _buildShimmerEffect() // ⏳ เอฟเฟกต์โหลด
            : sales.isEmpty
                ? Center(child: Text('📉 ไม่มีข้อมูลการขาย', style: TextStyle(fontSize: 18)))
                : ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: sales.length,
                    itemBuilder: (context, index) {
                      return _buildSalesCard(sales[index]);
                    },
                  ),
      ),
    );
  }

  // 🛒 ดีไซน์ Card สำหรับแสดงข้อมูลการขาย
  Widget _buildSalesCard(dynamic sale) {
    final priceOut = NumberFormat("#,##0", "en_US").format(sale['price_out'].toDouble());
    final commission = NumberFormat("#,##0", "en_US").format(sale['commission'].toDouble());

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.shopping_cart, color: Colors.blueAccent, size: 40), // 🛍️ ไอคอนสินค้า
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📦 ${sale['product_name']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '📌 จำนวน: ${sale['quantity']} | 💰 ราคา: ฿$priceOut',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  Text(
                    '💵 ค่าคอมมิชชั่น: ฿$commission',
                    style: TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.grey, size: 18),
                      SizedBox(width: 4),
                      Text('👤 ${sale['first_name'] ?? 'N/A'}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                      SizedBox(width: 4),
                      Text('📅 ${sale['sale_date']}', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✨ Shimmer Effect สำหรับโหลดข้อมูล
  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 5, // แสดง 5 รายการเป็นตัวอย่าง
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.white,
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 40, height: 40, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 20, width: double.infinity, color: Colors.white),
                        SizedBox(height: 8),
                        Container(height: 16, width: 150, color: Colors.white),
                        SizedBox(height: 6),
                        Container(height: 14, width: 100, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
