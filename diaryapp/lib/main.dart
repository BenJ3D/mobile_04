import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:github_sign_in/github_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'DiaryPage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Chargez les variables d'environnement
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiaryApp',
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginPage(),
        '/diary': (context) => DiaryPage(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasData) {
          return DiaryPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Diary App 42',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                User? user = await signInWithGoogle();
                if (user != null) {
                  Navigator.pushReplacementNamed(context, '/diary');
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColorLight,
                backgroundColor: Theme.of(context).primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Login with Google',
                style: TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                User? user = await signInWithGitHub(context);
                if (user != null) {
                  Navigator.pushReplacementNamed(context, '/diary');
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColorLight,
                backgroundColor: Theme.of(context).primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Login with GitHub',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<User?> signInWithGitHub(BuildContext context) async {
    try {
      // Create a GitHubSignIn instance
      final GitHubSignIn gitHubSignIn = GitHubSignIn(
        clientId: dotenv.env['GITHUB_CLIENT_ID']!,
        clientSecret: dotenv.env['GITHUB_CLIENT_SECRET']!,
        redirectUrl: dotenv.env['GITHUB_REDIRECT_URL']!,
      );

      // Trigger the sign-in flow
      final result = await gitHubSignIn.signIn(context);

      if (result.status == GitHubSignInResultStatus.ok) {
        // Create a credential from the access token
        final githubAuthCredential =
            GithubAuthProvider.credential(result.token!);

        // Sign in to Firebase with the GitHub credential
        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(githubAuthCredential);
        return userCredential.user;
      }
    } catch (e) {
      print('Erreur lors de l\'authentification GitHub: $e');
      // Affichez un message d'erreur à l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur d\'authentification: $e')),
      );
    }
    return null;
  }
}
