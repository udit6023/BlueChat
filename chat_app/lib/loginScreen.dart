import 'dart:developer';

import 'package:chat_app/helper/utility.dart';
import 'package:chat_app/homePage.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_sign_in/google_sign_in.dart';



// ignore: camel_case_types
class loginscreen extends HookWidget {


  loginscreen({super.key});

bool flag=false;
  @override
  Widget build(BuildContext context) {
    final username =useTextEditingController();
final password =useTextEditingController();
    return Scaffold(
      body: Center(
        child: Column(children: [
          
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: TextField(
              controller: username,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Enter your E-mail id",
              ),
              
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: TextField(
              controller: password,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "password",
              ),
              
            ),
          ),
           Padding(
            padding: const EdgeInsets.all(18.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueGrey,
                  textStyle: TextStyle(
                  fontSize: 20,
                  )),
              onPressed: () async{ 
                
                 await signIn(username,password,flag);
                
                if(flag==true)
                {
                  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => HomePage()),
  );
                }else{
                   final snackBar = SnackBar(
            content: const Text('Wrong id or pass'),
            action: SnackBarAction(
              label: '',
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          );

          // Find the ScaffoldMessenger in the widget tree
          // and use it to show a SnackBar.
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                  
              print(username.text);
            },
            child: Text("Sign In"),

            ),
          ),
       
        ],
         
        ),
        
      ),
          floatingActionButton: FloatingActionButton(
        onPressed: () async{
          // Add your onPressed code here!
          await _googleSignInbtn();
          if(flag==true)
                {
                        Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const HomePage()),
  );
                }else{
                  
                   //now if an error occurs so we need to show a snackbar for that
                    // ignore: use_build_context_synchronously
                   Utility.showSnackBar(context, 'oops something went wrong');
                }

        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.navigation),
      ),
    );
  }
  
  Future<void> signIn(TextEditingController username,TextEditingController password,bool flag ) async{
    try{
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: username.text.trim(), 
      password: password.text.trim(),
      );
      flag=true;
    }catch(e)
    {
      print(e);
      flag=false;
    }
    
    
  }

  _googleSignInbtn()
  async {
    //since it is a future function so we will wait until we get the user credentials then we will navigate it to another screen
    try{
      await signInWithGoogle().then((value) async => {
        log('${value?.user}'),
      //  these particular statments are throwing some error
        // if(!await userExists()){
        //   await createUser()
        // }
      });
      flag=true;
    }catch(e){
      print(e);
      flag=false;
    }
    

  }

  //? this represents that this function might return a null
  Future<UserCredential?> signInWithGoogle() async {
  try{
    //Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  //Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  //Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  //Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
  }catch(e){
    log('_signInWithGoogle $e');
  return null;

  }
}
  
}