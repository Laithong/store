// screens/logout.dart
import 'package:flutter/material.dart';

class LogoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logout'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Are you sure you want to log out?',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // ทำการลบข้อมูล session หรือ token
                    // และนำผู้ใช้กลับไปยังหน้าล็อกอิน
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login', // เปลี่ยนเป็นชื่อ Route ของหน้า Login
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Text('Yes, Log out'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // กลับไปที่หน้าก่อนหน้า
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
