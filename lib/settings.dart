import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? currentUser;
  String? firstName, lastName, gender, role;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (currentUser != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      setState(() {
        firstName = userDoc['firstName'];
        lastName = userDoc['lastName'];
        gender = userDoc['gender'];
        role = userDoc['role'];
      });
    }
  }

  Future<void> _updatePassword(BuildContext context) async {
    String oldPassword = '';
    String newPassword = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Old Password'),
              onChanged: (value) => oldPassword = value,
            ),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
              onChanged: (value) => newPassword = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                // Re-authenticate the user
                final cred = EmailAuthProvider.credential(
                  email: currentUser!.email!,
                  password: oldPassword,
                );
                await currentUser!.reauthenticateWithCredential(cred);

                // Update password
                await currentUser!.updatePassword(newPassword);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Password updated successfully!'),
                ));
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Error: ${e.toString()}'),
                ));
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePersonalInfo(BuildContext context) async {
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Personal Info'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: firstName,
                decoration: const InputDecoration(labelText: 'First Name'),
                onSaved: (value) => firstName = value,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your first name' : null,
              ),
              TextFormField(
                initialValue: lastName,
                decoration: const InputDecoration(labelText: 'Last Name'),
                onSaved: (value) => lastName = value,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your last name' : null,
              ),
              DropdownButtonFormField<String>(
                value: gender,
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Gender'),
                onChanged: (value) => gender = value,
                validator: (value) =>
                    value == null ? 'Please select your gender' : null,
              ),
              TextFormField(
                initialValue: role,
                decoration: const InputDecoration(labelText: 'Role'),
                onSaved: (value) => role = value,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your role' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                if (currentUser != null) {
                  await _firestore
                      .collection('users')
                      .doc(currentUser!.uid)
                      .update({
                    'firstName': firstName,
                    'lastName': lastName,
                    'gender': gender,
                    'role': role,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Profile updated successfully!'),
                  ));
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _updatePassword(context),
              icon: const Icon(Icons.lock),
              label: const Text('Update Password'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _updatePersonalInfo(context),
              icon: const Icon(Icons.person),
              label: const Text('Update Personal Info'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.red, // Red color for logout button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
