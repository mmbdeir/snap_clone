import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snap_clone/screens/tabs.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();

  bool _passwordIsVisible = false;

  var _enteredEmail = '';
  var _enteredPassword = '';

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _passwordIsVisible = false;
  }

  void _submit() async {
    _form.currentState!.save();
    try {
      await _firebase.signInWithEmailAndPassword(
        email: _enteredEmail,
        password: _enteredPassword,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Tabs(),
          ),
        );
      }
    } 
    on FirebaseAuthException catch (error) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: ((BuildContext context) {
          return AlertDialog.adaptive(
            content: Text(
              error.message ?? '',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            actions: [
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 200,),
            Text(
              'Log In',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Form(
                  key: _form,
                  onChanged: () {
                    // Trigger a rebuild when form fields change
                    setState(() {
                      _isFormValid = _form.currentState?.validate() ?? false;
                    });
                  },
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: Text(
                            'Email',
                            style:
                                Theme.of(context).textTheme.labelLarge!.copyWith(
                                      color: Colors.lightBlueAccent.shade400,
                                    ),
                          ),
                        ),
                        onSaved: (value) {
                          _enteredEmail = value!;
                        },
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.trim().length < 4) {
                            return 'Password enter at least 6 characters';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _enteredPassword = value;
                          setState(() {
                            _isFormValid =
                                _form.currentState?.validate() ?? false;
                          });
                        },
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: !_passwordIsVisible,
                        decoration: InputDecoration(
                          label: Text(
                            'Password',
                            style:
                                Theme.of(context).textTheme.labelLarge!.copyWith(
                                      color: Colors.lightBlueAccent.shade400,
                                    ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordIsVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordIsVisible = !_passwordIsVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 80, vertical: 11),
                              backgroundColor: _isFormValid
                                  ? Colors.lightBlueAccent
                                  : Colors.grey[350],
                            ),
                            onPressed: _submit,
                            child: Text(
                              'Log In',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
