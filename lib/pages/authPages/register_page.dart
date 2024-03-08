import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gamemate_mobile/components/my_button.dart';
import 'package:gamemate_mobile/components/my_textfield.dart';
import 'package:gamemate_mobile/components/square_tile.dart';
import 'package:gamemate_mobile/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUserUp() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    try {
      if (emailController.text.isEmpty || passwordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
        Navigator.pop(context);
        showErrorMessage('Preencha todos os campos!');
      }
      else if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text
        );
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        showErrorMessage('As senhas não coincidem! Tente novamente');
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'user-not-found') {
        showErrorMessage('No user found for that email');
      } else if (e.code == 'wrong-password') {
        showErrorMessage('Wrong password');
      } else if (e.code == 'invalid-credential') {
        showErrorMessage('Email ou senha incorretos, tente novamente.');
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
        }
      );
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
                        'Vamos criar uma conta para você.',
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
                          if (value!.isEmpty) {
                            return 'Este campo é obrigatorio';
                          }
                          final emailRegex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
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
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo é obrigatório';
                          }
                          if (value.length < 8) {
                            return 'A senha deve ter pelo menos 8 caracteres';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      MyTextField(
                        controller: confirmPasswordController,
                        hintText: 'Confirmar senha',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Este campo é obrigatório';
                          }
                          if (value.length < 8) {
                            return 'A senha deve ter pelo menos 8 caracteres';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      //Sign in button
                      MyButton(
                          text: 'Cadastrar',
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              signUserUp();
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
                        onTap: () {
                          AuthService().signInWithGoogle();
                        },
                      ),

                      const SizedBox(
                        height: 25,
                      ),
                      // not a member?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Já é inscrito?',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(
                            width: 4,
                            height: 4,
                          ),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: const Text(
                              'Entre agora',
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
  }
}
