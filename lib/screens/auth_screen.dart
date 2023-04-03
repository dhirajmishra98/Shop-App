import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../models/http_exception.dart';

enum AuthMode { loginMode, signUpMode }

class AuthScreen extends StatelessWidget {
  static const String routeName = '/auth-screen';
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //This method is used to hide softkeyboard if touched anywhere on screen
//     GestureDetector(
//   onTap: () {
//         FocusScope.of(context).requestFocus(FocusNode());
//   },
//   behavior: HitTestBehavior.translucent,
//   child: rootWidget
// )
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/register.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(top: 170, left: 15),
                  child: const Text(
                    'Shop App',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  width: 130,
                  child: const Text(
                    'Missing You!',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.4),
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      child: const Text(
                        'Welcome',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const AuthCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  AuthMode _authMode = AuthMode.loginMode;
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _passwordController = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _isLoading = false;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  void _errorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('An Error Occured!'),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Okay')),
              ],
            ));
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) return;
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.loginMode) {
        //login mode
        await Provider.of<Auth>(context, listen: false)
            .logIn(_authData['email']!, _authData['password']!);
      } else {
        //signup mode
        await Provider.of<Auth>(context, listen: false)
            .signUp(_authData['email']!, _authData['password']!);
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication Failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'Email already in use';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'Invalid Email';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid Password';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'Password is too weak';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Couldt\'t find a user with that email';
      }
      _errorDialog(errorMessage);
    } catch (error) {
      //this error may happen due firebase server down, network issue or any other issue firebase cannot reflect
      var errorMessage = 'Couldn\'t Authenticate You. Please try again later';
      _errorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.loginMode) {
      setState(() {
        _authMode = AuthMode.signUpMode;
      });
    } else {
      setState(() {
        _authMode = AuthMode.loginMode;
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.black),
                    contentPadding: EdgeInsets.all(15),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      borderSide: BorderSide(color: Colors.black),
                    )),
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocus),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return "Invalid email";
                  }
                  return null;
                },
                onSaved: (value) {
                  _authData['email'] = value.toString();
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black),
                  contentPadding: EdgeInsets.all(15),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      borderSide: BorderSide(color: Colors.black)),
                ),
                controller: _passwordController,
                textInputAction: _authMode == AuthMode.loginMode
                    ? TextInputAction.done
                    : TextInputAction.next,
                focusNode: _passwordFocus,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_confirmPasswordFocus),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                validator: (value) {
                  if (value!.length < 8) {
                    return "password too short";
                  }
                  return null;
                },
                onSaved: (value) {
                  _authData['password'] = value.toString();
                },
              ),
              if (_authMode == AuthMode.loginMode)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot password',
                        textAlign: TextAlign.end,
                        style: TextStyle(color: Colors.black),
                      )),
                ),
              const SizedBox(
                height: 20,
              ),
              if (_authMode == AuthMode.signUpMode)
                Column(
                  children: [
                    TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          labelStyle: TextStyle(color: Colors.black),
                          contentPadding: EdgeInsets.all(15),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                              borderSide: BorderSide(color: Colors.black)),
                        ),
                        textInputAction: TextInputAction.done,
                        focusNode: _confirmPasswordFocus,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return "password didn't matched!";
                          }
                          return null;
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: _saveForm,
                  child: _authMode == AuthMode.signUpMode
                      ? const Text('SIGN UP')
                      : const Text('LOGIN'),
                ),
              const SizedBox(
                height: 50,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _authMode == AuthMode.loginMode
                        ? 'I don\'t have an account ?'
                        : 'I already have an account ?',
                    style: const TextStyle(
                        color: Color.fromARGB(255, 110, 108, 108)),
                  ),
                  TextButton(
                    onPressed: () {
                      _switchAuthMode();
                      // print(_passwordController.text);
                    },
                    child: Text(
                      _authMode == AuthMode.loginMode ? 'Create New' : 'Login',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
