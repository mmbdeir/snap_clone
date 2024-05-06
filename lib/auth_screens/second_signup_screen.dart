import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:snap_clone/auth_screens/third_signup_screen.dart';

class FinalSignUpScreen extends StatefulWidget {
  const FinalSignUpScreen({super.key, required this.enteredEmail, required this.enteredPassword, required this.enteredUsername});

  final String enteredEmail;
  final String enteredPassword;
  final String enteredUsername;

  @override
  State<FinalSignUpScreen> createState() => _FinalSignUpScreenState();
}

class _FinalSignUpScreenState extends State<FinalSignUpScreen> {
  var phoneController = TextEditingController();
  final _form = GlobalKey<FormState>();

  var birthday;
  var _phoneNumber;
  var displayName;

  bool isValid = false;
  bool phoneIsValid = false;

  @override
  void initState() {
    super.initState();
    phoneIsValid = false; 
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
              'Sign Up',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(8),
                  height: 80,
                  child: IntlPhoneField(
                    validator: (value) {
                      if (value == null || value.number.trim().length < 7) {
                        setState(() {
                          phoneIsValid = false;
                        });
                      }
                      else {
                        setState(() {
                          phoneIsValid = true;
                        });
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      counter: Offstage(),
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                    ),
                  initialCountryCode: 'US',
                  showDropdownIcon: true,
                  dropdownIconPosition:IconPosition.trailing,
                  onChanged: (phone) {
                  setState(() {
                    _phoneNumber = phone.completeNumber;
                  });
                },
              ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Form(
                  key: _form,
                  onChanged: () {
                    setState(() {
                      isValid = _form.currentState!.validate();
                    });
                  },
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.trim().length < 3) {
                        return 'Make your display name more than 3 letters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      label: Text('Display Name', 
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    onSaved: (value) {
                      displayName = value!;
                    },
                    onChanged: (value) {
                      displayName = value;
                      setState(() {
                        isValid = _form.currentState?.validate() ?? false;
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime.now(),
                maximumDate: DateTime.now(),
                onDateTimeChanged: (dateTime) {
                  setState(() {
                    birthday = dateTime;
                  });
                },
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 11),
                    backgroundColor:
                      isValid && phoneIsValid?
                      Colors.blueAccent
                      : Colors.grey[350]
                  ),
                  onPressed: () {
                    isValid && phoneIsValid?
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => GetStartedScreen(displayName: displayName, birthday: birthday, enteredEmail: widget.enteredEmail, enteredPassword: widget.enteredPassword, phoneNumber: _phoneNumber, enteredUsername: widget.enteredUsername),
                      ),
                    ) : null;
                  },
                  child: Text(
                    'Continue',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}