import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_report_app/pages/auth/register_page.dart';
import 'package:financial_report_app/pages/navigation_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerPassword = TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  bool showPassword = true;
  String? username;
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        final String email = controllerEmail.text.trim();
        final String password = controllerPassword.text.trim();

        final UserCredential userCredential = await _firebaseAuth
            .signInWithEmailAndPassword(email: email, password: password);

        final QuerySnapshot userDoc = await _firebaseFirestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        if (userDoc.docs.isNotEmpty) {
          DocumentSnapshot documentSnapshot = userDoc.docs.first;
          setState(() {
            username = documentSnapshot['name'];
          });

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (builder) => const NavigationPage(),
            ),
          );

          controllerEmail.clear();
          controllerPassword.clear();
        } else {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            showCloseIcon: true,
            title: 'Warning',
            desc: 'User not found in collection',
            btnOkOnPress: () {},
          ).show();
        }
      } catch (e) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          showCloseIcon: true,
          title: 'Warning',
          desc: 'Email and Password not registered',
          btnOkOnPress: () {},
        ).show();
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: controllerEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                    label: const Text("Email"),
                    prefixIcon: const Icon(Icons.email),
                    suffixIcon: IconButton(
                      onPressed: () {
                        controllerEmail.clear();
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Email cannot be empty';
                    }
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: controllerPassword,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: showPassword,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                    label: const Text("Password"),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                      icon: Icon(showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email cannot be empty';
                    }
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("Belum Punya Akun ?"),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (builder) => const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text("Buat Akun"))
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _login();
                          }
                        },
                        child: const Text("L O G I N"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
