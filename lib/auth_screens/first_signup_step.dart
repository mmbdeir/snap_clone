import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snap_clone/auth_screens/second_signup_screen.dart';

final _firebase = FirebaseAuth.instance;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override 
  State<SignUpScreen> createState() => AuthScreenState();
}

class AuthScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();

  bool _passwordIsVisible = false;

  late String _enteredEmail = '';
  late String _enteredPassword = '';
  late String _enteredUsername = '';

  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _passwordIsVisible = false;
  }

  void _onNext() async{
    _form.currentState?.save();
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => FinalSignUpScreen(enteredEmail: _enteredEmail, enteredPassword: _enteredPassword, enteredUsername: _enteredUsername),
      ),
    );
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
            Text(
              'Sign Up',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 130),
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
                          if (value == null || value.trim().length < 3 || value.contains('@')) {
                            return 'Username must be 3 characters long and cannot contain the \'@\' symbol';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: Text('Username', style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                color: Colors.blueAccent,
                              ),
                          ),
                        ),
                        onChanged: (value) {
                          _enteredUsername = value;
                          setState(() {
                            _isFormValid = _form.currentState?.validate() ?? false;
                          });
                        },
                      ),
                      const SizedBox(height: 12,),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.trim().isEmpty || !value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: Text(
                            'Email',
                            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                  color: Colors.blueAccent,
                                ),
                          ),
                        ),
                        onSaved: (value) {
                          _enteredEmail = value!;
                        },
                      ),
                      const SizedBox(height: 12,),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty || value.trim().length < 6) {
                            return 'Password enter at least 6 characters';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _enteredPassword = value;
                          setState(() {
                            _isFormValid = _form.currentState?.validate() ?? false;
                          });
                        },
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: !_passwordIsVisible,
                        decoration: InputDecoration(
                          label: Text('Password', style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                color: Colors.blueAccent,
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
                              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 11),
                              backgroundColor: _isFormValid
                                    ? Colors.blueAccent
                                    : Colors.grey[350],
                            ),
                            onPressed: _isFormValid
                              ? _onNext
                              : null,
                            child: Text(
                              'Next',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20,)
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
