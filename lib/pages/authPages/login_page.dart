import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamemate_mobile/components/my_button.dart';
import 'package:gamemate_mobile/components/my_textfield.dart';
import 'package:gamemate_mobile/components/square_tile.dart';
import 'package:gamemate_mobile/pages/authPages/forgot_password_page.dart';
import 'package:gamemate_mobile/pages/home_page.dart';
import 'package:gamemate_mobile/services/auth_service.dart';
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late final LocalAuthentication auth;
  bool _supportState = false;
  bool _isBiometricAuthAvailable = false;
  final snapshot = FirebaseAuth.instance.authStateChanges();

  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // AuthInitialization
  @override
  void initState() {
    super.initState();
    auth = LocalAuthentication();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() {
        _supportState = isSupported;
      }),
    );
    _checkExistingUser();
  }

  Future<void> _checkExistingUser() async {
    final user = FirebaseAuth.instance.currentUser;
    print(user);
    if (user != null) {
      _checkBiometrics();
    }
  }

  Future<void> _checkBiometrics() async {
    final availableBiometrics = await _getAvailableBiometrics();
    if (availableBiometrics.isNotEmpty) {
      setState(() {
        _isBiometricAuthAvailable = true;
      });
      _authenticate();
    }
  }

  Future<List<BiometricType>> _getAvailableBiometrics() async {
    final availableBiometrics = await auth.getAvailableBiometrics();
    return availableBiometrics;
  }

  Future<void> _authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (authenticated) {
        // Biometric authentication successful, proceed to the main app
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false
        );
      }
    } on PlatformException catch (e) {
      print(e);
    }
  }

  void signUserIn() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Navigator.pop(context);
      showErrorMessage('Preencha todos os campos');
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.pop(context);
      if (_supportState && !_isBiometricAuthAvailable) {
        _checkBiometrics();
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'user-not-found') {
        showErrorMessage('No user found for that email');
      } else if (e.code == 'wrong-password') {
        showErrorMessage('Wrong password');
      } else if (e.code == 'invalid-credential') {
        showErrorMessage('Incorrect email or password, try again.');
      }
    }
  }

  void showErrorMessage(String text) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(text),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.grey.shade900,
            ],
          ),
        ),
        height: double.maxFinite,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    // Logo
                    Image.asset(
                      'lib/images/gamemate-logo-white.png',
                      height: 50,
                    ),
                    const SizedBox(height: 50),
                    // Welcome Text
                    const Text(
                      'Bem vindo (a)',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 50),
                    // username Textfield
                    MyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                      validator: (value) {
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (value!.isEmpty) {
                          return 'Este campo é obrigatorio';
                        }
                        if (!emailRegex.hasMatch(value)) {
                          return 'Por favor, insira um email válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // password TextField
                    MyTextField(
                      controller: passwordController,
                      hintText: 'Senha',
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Este campo é obrigatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    //forgot password?
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Esqueceu sua senha?',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    //Sign in button
                    MyButton(
                      text: 'Entrar',
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          signUserIn();
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    // Biometric login button
                    if (_supportState)
                      ElevatedButton(
                        onPressed: _isBiometricAuthAvailable ? _authenticate : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Customize button color
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Adjust padding
                          textStyle: TextStyle(fontSize: 16), // Customize text style
                        ),
                        child: const Text(
                          'Entre com a biometria',
                          style: TextStyle(color: Colors.white), // Customize text color
                        ),
                      ),
                    const SizedBox(height: 20),
                    // or continue with
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.8,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              'Ou continue com',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.8,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Google button
                    SquareTile(
                      imagePath: 'lib/images/google.png',
                      onTap: () => AuthService().signInWithGoogle(),
                    ),
                    const SizedBox(height: 25),
                    // not a member?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Não está inscrito?',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 4, height: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            'Registre-se agora',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
