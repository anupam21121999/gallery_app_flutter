import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_flutter/pages/home_page.dart';
import 'package:image_flutter/pages/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login() async{
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email == "" || password == ""){
      log("Please fill all the details!");
    }
    else{
      try{
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
        if(userCredential != null){
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(context, CupertinoPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        }
      } on FirebaseAuthException catch(ex) {
        log(ex.code.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/login3.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(25.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage("assets/images/login1.jpg"),
                        radius: 45,
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Text("GALLERY APP",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          hintText: "Enter the email",
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "Enter the password",
                        ),
                      ),
                      SizedBox(
                        height: 50.0,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            login();
                          },
                          child: Text('LOGIN')
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, CupertinoPageRoute(
                              builder: (context) => Signup(),
                            ),
                          );
                        },
                        child: Text("Create an account?",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.cyan
                        ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
