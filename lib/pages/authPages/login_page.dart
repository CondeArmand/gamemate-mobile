import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gamemate_mobile/components/my_button.dart';
import 'package:gamemate_mobile/components/my_textfield.dart';
import 'package:gamemate_mobile/components/square_tile.dart';
import 'package:gamemate_mobile/pages/authPages/forgot_password_page.dart';
import 'package:gamemate_mobile/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
    );

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Navigator.pop(context);
      showErrorMessage('Preencha todos os campos');
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      Navigator.pop(context);
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

  void showErrorMessage(text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(text),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
                      const SizedBox(
                        height: 50,
                      ),
                      // Logo
                      Image.asset(
                        'lib/images/gamemate-logo-white.png',
                        height: 50,
                      ),
                      const SizedBox(
                        height: 50,
                      ),

                      // Welcome Text
                      const Text(
                        'Bem vindo (a)',
                        style: TextStyle(color: Colors.white),
                      ),

                      const SizedBox(
                        height: 50,
                      ),

                      // username Textfield
                      MyTextField(
                        controller: emailController,
                        hintText: 'Email',
                        obscureText: false,
                        validator: (value) {
                          final emailRegex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                          if (value!.isEmpty) {
                            return 'Este campo é obrigatorio';
                          }
                          if (!emailRegex.hasMatch(value)) {
                            return 'Por favor, insira um email válido';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // password TextField
                      MyTextField(
                        controller: passwordController,
                        hintText: 'Senha',
                        obscureText: false,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Este campo é obrigatorio';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 10,
                      ),

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
                                    builder: (context) =>
                                        const ForgotPasswordPage(),
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

                      const SizedBox(
                        height: 25,
                      ),

                      //Sign in button
                      MyButton(
                          text: 'Entrar',
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              signUserIn();
                            }
                          }),

                      const SizedBox(
                        height: 50,
                      ),

                      // or continue with
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          children: [
                            Expanded(
                                child: Divider(
                              thickness: 0.8,
                              color: Colors.white,
                            )),
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
                            )),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 25,
                      ),
                      // Google button
                      SquareTile(
                        imagePath: 'lib/images/google.png',
                        onTap: () => AuthService().signInWithGoogle(),
                      ),

                      const SizedBox(
                        height: 25,
                      ),
                      // not a member?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Não está inscrito?',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(
                            width: 4,
                            height: 4,
                          ),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: const Text(
                              'Registre-se agora',
                              style: TextStyle(
                                  color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
    throw UnimplementedError();
  }
}
