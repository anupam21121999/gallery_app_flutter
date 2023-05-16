import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_flutter/pages/login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? profilePic;

  void logout() async{
    await FirebaseAuth.instance.signOut();
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(context, CupertinoPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  void saveData() async{
    if(profilePic != null) {
      UploadTask uploadTask = FirebaseStorage.instance.ref().child(
          "profilePictures").child(Uuid().v1()).putFile(profilePic!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      Map<String, dynamic> userData = {
        "profilepic": downloadUrl,
      };
      await FirebaseFirestore.instance.collection("users").add(userData);
      log("User created");
    }
    else {
      log("Please fill all the fields");
    }
    setState(() {
      profilePic = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                logout();
              },
              icon: Icon(Icons.exit_to_app)
          ),
        ],
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Gallery App"),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/img2.jpg"),
                    fit: BoxFit.cover,
            )
        ),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CupertinoButton(
                onPressed: () async{
                  XFile? selectedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

                  if(selectedImage !=null){
                    File convertedFile = File(selectedImage.path);
                    setState(() {
                      profilePic = convertedFile;
                    });
                    log("Image selected");
                  }
                  else {
                    log("Image not selected");
                  }
                },
              child: CircleAvatar(
                radius: 30,
                backgroundImage: (profilePic != null) ? FileImage(profilePic!) : null,
              ),
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance.collection("users").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Expanded(
                        child: GridView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> userMap = snapshot.data!
                                .docs[index].data() as Map<String, dynamic>;

                            return GridTile(
                                child: Card(
                                  margin: EdgeInsets.all(15.0),
                                  shadowColor: Colors.blueAccent,
                                  child: Container(
                                    height: 30,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(userMap["profilepic"])
                                      )
                                    ),
                                  ),
                                ),
                            );
                          }, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2
                        ),
                        ),
                      );
                    }
                    else {
                      return Text("No data");
                    }
                  }
                  else{
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }
            ),
            ElevatedButton(
                onPressed: () {
                  saveData();
                },
                child: Text("SAVE")
            ),
          ],
        ),
      ),
    );
  }
}
