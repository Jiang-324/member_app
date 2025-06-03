import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'thank_you_page.dart';
import 'dart:io';

class MembershipFormPage extends StatefulWidget {
  const MembershipFormPage({super.key});

  @override
  State<StatefulWidget> createState() => _MembershipFormPageState();

}

class _MembershipFormPageState extends State<MembershipFormPage>{
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _hasSubmitted = false;
  File? _profileImage;
  String? _uploadedImageUrl;

  final ImagePicker _picker = ImagePicker();




  Future<void> _pickImage() async {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return SafeArea(
              child: Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Take a photo'),
                    onTap: () async {
                      Navigator.pop(context);
                      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                      if(pickedFile != null) {
                        setState(() => _profileImage = File(pickedFile.path));
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo),
                    title: const Text('Choose from gallery'),
                    onTap: () async {
                      Navigator.pop(context);
                      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                      if( pickedFile != null) {
                        setState(() => _profileImage = File(pickedFile.path));
                      }
                    },
                  ),
                ],
              ),
          );
        });
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if(pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }




  Future<void> _submitForm() async {

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      try {
        final user = FirebaseAuth.instance.currentUser;

        if( user == null) throw Exception('User not logged in');
        final docRef = FirebaseFirestore.instance.collection('membership_application').doc(user?.uid);
        final existingDoc = await docRef.get();
        if( existingDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You have already submitted your application.')),
          );
          return;
        }
        if(_profileImage != null ) {
          final snapshot = await FirebaseStorage.instance
              .ref('profile_images/${user.uid}.jpg')
              .putFile(_profileImage!);
          _uploadedImageUrl = await snapshot.ref.getDownloadURL();
        }
        await docRef.set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'imageUrl': _uploadedImageUrl ?? '',
          'submittedAt': FieldValue.serverTimestamp(),
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ThankYouPage(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              phone: _phoneController.text.trim(),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }

    }
  }



    Future<void> _loadExistingApplication() async {
      final user = FirebaseAuth.instance.currentUser;
      if( user == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('membership_application')
          .doc(user.uid)
          .get();
      if(doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        setState(() {
          _hasSubmitted = true;
          _uploadedImageUrl = data['imageUrl'] ?? '';
        });
      }
    }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadExistingApplication();
    final user = FirebaseAuth.instance.currentUser;
    if( user == null) {
      Future.microtask(() =>
        Navigator.pushReplacementNamed(context, '/')
      );
    } else {
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Application'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/editProfile');
              },
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null ? Icon(Icons.add_a_photo, size:50) : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                readOnly: _hasSubmitted,
                validator: (value) => value == null || value!.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                readOnly: _hasSubmitted,
                validator: (value) =>
                  value != null && value.contains('@')  ? null : 'Enter a valid email',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                readOnly: _hasSubmitted,
                validator: (value) =>
                  value != null && value.length >= 10 ? null : 'Enter a valid phone number',
              ),
              const SizedBox(height: 24),
              !_hasSubmitted ?
                _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Apply for Membership'))
                  :  Text("You have already applied for membership.",
                      style: TextStyle(color: Colors.green)),
            ],
          ),
        ),
      ),
    );
    // TODO: implement build
    throw UnimplementedError();
  }
}

