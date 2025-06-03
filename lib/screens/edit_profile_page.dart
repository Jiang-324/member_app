import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<StatefulWidget> createState() => _EditProfilePageState();

}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _newProfileImage;
  String? _existingImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if(user != null) {
      final doc = await FirebaseFirestore.instance.collection('membership_application').doc(user.uid).get();
      final data = doc.data();
      if(data != null) {
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _existingImageUrl = data['imageUrl'];
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path);
      });
    }
  }
  
  Future<String?> _uploadNewImage(String uid) async {
    if(_newProfileImage == null) return _existingImageUrl;
    final ref = FirebaseStorage.instance.ref().child('profile_images').child('$uid.jpg');
    await ref.putFile(_newProfileImage!);
    return await ref.getDownloadURL();
  }
  
  Future<void> _submitChanges() async {
    if(!_formKey.currentState!.validate()) return;
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if( user == null) throw Exception("User not logged in");
      final imageUrl = await _uploadNewImage(user.uid);

      await FirebaseFirestore.instance.collection('membership_application').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'imageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if(_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _newProfileImage != null
                    ? FileImage(_newProfileImage!)
                    : (_existingImageUrl != null
                        ? NetworkImage(_existingImageUrl!)
                        : const AssetImage('assets/default_avatar.png')) as ImageProvider,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter your Name' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value != null && value.length >= 10 ? null : 'Enter valid phone Number',
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                    onPressed: _submitChanges,
                    child: const Text('Save Changes'),
                )
              ],
            )),
      ),
    );
  }
}