import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text('Profile'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 55,
              backgroundColor: Color(0xFF1565C0),

              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Smart Civic User',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Citizen Account',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            _buildProfileItem(
              Icons.person_outline,
              'Name',
              'Smart Civic User',
            ),

            _buildProfileItem(
              Icons.email_outlined,
              'Email',
              'user@example.com',
            ),

            _buildProfileItem(
              Icons.phone_outlined,
              'Mobile Number',
              'Not added',
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },

                icon: const Icon(Icons.logout),

                label: const Text('Logout'),

                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.all(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(
      IconData icon,
      String title,
      String value,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFF1565C0),
        ),

        title: Text(title),

        subtitle: Text(value),
      ),
    );
  }
}