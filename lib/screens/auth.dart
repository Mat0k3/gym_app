import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/widgets/user_image_picker.dart';
import 'package:glass/glass.dart';

final auth = FirebaseAuth.instance;
final firestore = FirebaseFirestore.instance;
final storage = FirebaseStorage.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formkey = GlobalKey<FormState>();
  File? _selectedImage;
  var _selectedName = '';
  var _selectedEmail = '';
  var _selectedPassword = '';
  var _isLogin = false;
  var _isLoading = false;

  void _onSelectImage(File pickedImage) {
    _selectedImage = pickedImage;
  }

  void _onSubmit() async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    currentFocus.unfocus();
    final isValid = _formkey.currentState!.validate();

    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _formkey.currentState!.save();

    try {
      if (_isLogin) {
        await auth.signInWithEmailAndPassword(
          email: _selectedEmail,
          password: _selectedPassword,
        );
      } else {
        final user = await auth.createUserWithEmailAndPassword(
          email: _selectedEmail,
          password: _selectedPassword,
        );

        var url = 'default';
        if (_selectedImage != null) {
          final storageRef =
              storage.ref().child('user_images').child('${user.user!.uid}.jpg');

          await storageRef.putFile(_selectedImage!);
          url = await storageRef.getDownloadURL();
        }

        await firestore.collection('users').doc(user.user!.uid).set({
          'email': _selectedEmail,
          'name': _selectedName,
          'image': url,
        });
      }
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message!),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Image.asset(
                  'assets/images/background.jpg',
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.transparent.withOpacity(0.5),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isLogin)
                      UserImagePicker(
                        onSelectImage: _onSelectImage,
                      ),
                    Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                contentPadding: EdgeInsets.only(
                                  top: 20.0,
                                  bottom: 10.0,
                                  left: 15.0,
                                  right: 15.0,
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                labelText: 'Name',
                                errorStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                  borderSide: BorderSide(
                                      width: 1.5, color: Colors.grey),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.name,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.words,
                              onSaved: (value) {
                                _selectedName = value!;
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Insert at least 4 characters.';
                                }
                                return null;
                              },
                            ),
                          if (!_isLogin) const SizedBox(height: 16),
                          TextFormField(
                            decoration: const InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              contentPadding: EdgeInsets.only(
                                top: 20.0,
                                bottom: 10.0,
                                left: 15.0,
                                right: 15.0,
                              ),
                              labelText: 'Email',
                              errorStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide:
                                    BorderSide(width: 1.5, color: Colors.grey),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Insert a valid email.';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _selectedEmail = value!;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: const InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              contentPadding: EdgeInsets.only(
                                top: 20.0,
                                bottom: 10.0,
                                left: 15.0,
                                right: 15.0,
                              ),
                              labelText: 'Password',
                              errorStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide:
                                    BorderSide(width: 1.5, color: Colors.grey),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Insert at least 6 characters.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _selectedPassword = value!;
                            },
                          ),
                          const Divider(
                            color: Colors.purple,
                            thickness: 3,
                            height: 40,
                            indent: 20,
                            endIndent: 20,
                          ),
                          if (!_isLoading)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                fixedSize: Size(200, 45),
                              ),
                              onPressed: _onSubmit,
                              icon:
                                  const Icon(Icons.login, color: Colors.white),
                              label: Text(
                                _isLogin ? 'Login' : 'Signup',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          if (!_isLoading)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  _formkey.currentState!.reset();
                                  _selectedImage = null;
                                  FocusScopeNode currentFocus =
                                      FocusScope.of(context);
                                  currentFocus.unfocus();
                                });
                              },
                              child: Text(
                                _isLogin
                                    ? 'Create an account!'
                                    : 'Already registered?',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          if (_isLoading)
                            const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).asGlass(
              tintColor: Colors.transparent,
            )
          ],
        ),
      ),
    );
  }
}
