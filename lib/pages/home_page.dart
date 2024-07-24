import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gamemate_mobile/pages/authPages/auth_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'authPages/login_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  signUserOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
    } on FirebaseException catch (e) {
      print(e.code);
    }
  }

  void navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage(onTap: null)),
    );
  }

  void navigateToLoginAndSignOut(BuildContext context) async {

    await signUserOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
          (route) => false
   );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F2FD),
        actions: [
          IconButton(onPressed: signUserOut, icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Logado! como ${user.email!}',
              style: const TextStyle(color: Colors.cyanAccent),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => navigateToLogin(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan, // Customize button color
              ),
              child: const Text(
                'Voltar à tela de login',
                style: TextStyle(color: Colors.white), // Customize text color
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => navigateToLoginAndSignOut(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Customize button color
              ),
              child: const Text(
                'Sair e voltar à tela de login',
                style: TextStyle(color: Colors.white), // Customize text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
