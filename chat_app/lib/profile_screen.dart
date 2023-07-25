import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api_func.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/src/widgets/framework.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import 'package:chat_app/loginScreen.dart';
import 'package:chat_app/model/chat_model.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  ChatModel user;
  ProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
String? _image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: CupertinoColors.black,
        centerTitle: true,
        title: const Text("Profile Screen",style: TextStyle(fontSize: 20),),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        },icon:const Icon(Icons.arrow_back)),
      ),


      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.logout),
        onPressed: ()async{
            await FirebaseAuth.instance.signOut().then((value) async => {
                await GoogleSignIn().signOut().then((value) => {
                  //it will move you back to homescreen
                  Navigator.pop(context),
                  //and this will move you to login screen
                  Navigator.pop(context),
                  //now we need to remove the homescreeen from the backtrack or when we do a back from our devices
                  //so for that
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>loginscreen()))
                })
            });
          

        }, label: const Text("Logout")),


      body: Column(children: [
         SizedBox(width:MediaQuery.of(context).size.width,height:MediaQuery.of(context).size.height*.03),


        Stack(
          children: [
            (_image!=null)?(
             
                ClipRRect(
                      borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height*.1),
                      child: Image.file(
                        File(_image!),
                        fit: BoxFit.fill,
                        width: MediaQuery.of(context).size.height*.2,
                        height: MediaQuery.of(context).size.height*.2,
                         ),
                    )
                
              
            ):ClipRRect(
                    borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height*.1),
                    child: CachedNetworkImage(
                      fit: BoxFit.fill,
                      width: MediaQuery.of(context).size.height*.2,
                      height: MediaQuery.of(context).size.height*.2,
                          imageUrl: widget.user.image,
                       ),
                  ),
                  Positioned
                  (
                    
                    bottom: 0,
                    left: 70,
                    child: MaterialButton(onPressed: (){
                      _showBottomSheet(context);
                    },
                    elevation: 1,
                    shape: const CircleBorder(),
                    color: Colors.white,
                    child: const Icon(Icons.edit,color: Colors.black,),),
                  )
          ],
        ),
            SizedBox(width:MediaQuery.of(context).size.width,height:MediaQuery.of(context).size.height*.03),
            Text(widget.user.email,style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold),)   ,
            SizedBox(width:MediaQuery.of(context).size.width,height:MediaQuery.of(context).size.height*.05),
             Padding(
               padding: const EdgeInsets.only(left:20.0,right:20.0),
               child: TextFormField(
                initialValue: widget.user.name,
                      decoration: InputDecoration(
                      prefixIcon:const Icon(Icons.person,color: Colors.black,),
                        hintText: 'Your name',
                        hintStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        label: Text("Name")
                      ),
                    ),
             ),
               SizedBox(width:MediaQuery.of(context).size.width,height:MediaQuery.of(context).size.height*.03),
             Padding(
               padding: const EdgeInsets.only(left:20.0,right:20.0),
               child: TextFormField(
                initialValue: widget.user.about,
                      decoration: InputDecoration(
                      prefixIcon:const Icon(Icons.info_outline,color: Colors.black,),
                        hintText: 'Your about',
                        hintStyle: const TextStyle(color: Colors.black),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        label: Text("About")
                      ),
                    ),
             ),
              SizedBox(width:MediaQuery.of(context).size.width,height:MediaQuery.of(context).size.height*.03),
             ElevatedButton.icon(
              
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                          shape: const StadiumBorder(),
                          minimumSize: Size(MediaQuery.of(context).size.width * .5, MediaQuery.of(context).size.height * .06)),
                      onPressed: () {
                        // if (_formKey.currentState!.validate()) {
                        //   _formKey.currentState!.save();
                        //   APIs.updateUserInfo().then((value) {
                        //     Dialogs.showSnackbar(
                        //         context, 'Profile Updated Successfully!');
                        //   });
                        // }
                      },
                      icon: const Icon(Icons.edit, size: 28),
                      label:
                          const Text('UPDATE', style: TextStyle(fontSize: 16)),
                    )
      ]),
    );
  }
  //     // bottom sheet for picking a profile picture for user
  void _showBottomSheet(BuildContext context){
    showModalBottomSheet(
        
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * .03, bottom: MediaQuery.of(context).size.height * .05),
            children: [
              //pick profile picture label
              const Text('Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

              //for adding some space
              SizedBox(height: MediaQuery.of(context).size.height * .02),

              //buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(MediaQuery.of(context).size.width * .3, MediaQuery.of(context).size.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });
                          
                          log('counter: ${ _image}');
                          

                          APIFunc.updateProfilePicture(widget.user,File(_image!));
                          // for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/images/gallery.png')),

                  //take picture from camera button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(MediaQuery.of(context).size.width * .3, MediaQuery.of(context).size.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                            _image = image.path;
                          });

                        APIFunc.updateProfilePicture(widget.user,File(_image!));
                          // for hiding bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/images/camera.png')),
                ],
              )
            ],
          );
        }, context: context);
  }
}

// // ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable




// class ProfileScreen extends HookWidget {
//   ChatModel user;
//   ProfileScreen({
//     Key? key,
//     required this.user,
//   }) : super(key: key);


//   //String? _image;
  
//  final _image=useState("");
//   @override
//   Widget build(BuildContext context) {
    
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 1,
//         backgroundColor: CupertinoColors.black,
//         centerTitle: true,
//         title: const Text("Profile Screen",style: TextStyle(fontSize: 20),),
//         leading: IconButton(onPressed: (){
//           Navigator.pop(context);
//         },icon:const Icon(Icons.arrow_back)),
//       ),


//       floatingActionButton: FloatingActionButton.extended(
//         backgroundColor: Colors.redAccent,
//         icon: const Icon(Icons.logout),
//         onPressed: ()async{
//             await FirebaseAuth.instance.signOut().then((value) async => {
//                 await GoogleSignIn().signOut().then((value) => {
//                   //it will move you back to homescreen
//                   Navigator.pop(context),
//                   //and this will move you to login screen
//                   Navigator.pop(context),
//                   //now we need to remove the homescreeen from the backtrack or when we do a back from our devices
//                   //so for that
//                   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>loginscreen()))
//                 })
//             });
          

//         }, label: const Text("Logout")),


//       body: Column(children: [
//          SizedBox(width:MediaQuery.of(context).size.width,height:MediaQuery.of(context).size.height*.03),


//         Stack(
//           children: [
//             (_image.value!="")?(
             
//                 ClipRRect(
//                       borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height*.1),
//                       child: Image.file(
//                         File(_image.value.toString()),
//                         fit: BoxFit.fill,
//                         width: MediaQuery.of(context).size.height*.2,
//                         height: MediaQuery.of(context).size.height*.2,
//                          ),
//                     )
                
              
//             ):ClipRRect(
//                     borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height*.1),
//                     child: CachedNetworkImage(
//                       fit: BoxFit.fill,
//                       width: MediaQuery.of(context).size.height*.2,
//                       height: MediaQuery.of(context).size.height*.2,
//                           imageUrl: user.image,
//                        ),
//                   ),
//                   Positioned
//                   (
                    
//                     bottom: 0,
//                     left: 70,
//                     child: MaterialButton(onPressed: (){
//                       _showBottomSheet(context);
//                     },
//                     elevation: 1,
//                     shape: const CircleBorder(),
//                     color: Colors.white,
//                     child: const Icon(Icons.edit,color: Colors.black,),),
//                   )
//           ],
//         ),
//             SizedBox(width:MediaQuery.of(context).size.width,height:MediaQuery.of(context).size.height*.03),
//             Text(user.email,style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold),)   ,
//             SizedBox(width:MediaQuery.of(context).size.width,height:MediaQuery.of(context).size.height*.05),
//              Padding(
//                padding: const EdgeInsets.only(left:20.0,right:20.0),
//                child: TextFormField(
//                 initialValue: user.name,
//                       decoration: InputDecoration(
//                       prefixIcon:const Icon(Icons.person,color: Colors.black,),
//                         hintText: 'Your name',
//                         hintStyle: const TextStyle(color: Colors.black),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                         label: Text("Name")
//                       ),
//                     ),
//              ),
//                SizedBox(width:MediaQuery.of(context).size.width,height:MediaQuery.of(context).size.height*.03),
//              Padding(
//                padding: const EdgeInsets.only(left:20.0,right:20.0),
//                child: TextFormField(
//                 initialValue: user.about,
//                       decoration: InputDecoration(
//                       prefixIcon:const Icon(Icons.info_outline,color: Colors.black,),
//                         hintText: 'Your about',
//                         hintStyle: const TextStyle(color: Colors.black),
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                         label: Text("About")
//                       ),
//                     ),
//              ),
//               SizedBox(width:MediaQuery.of(context).size.width,height:MediaQuery.of(context).size.height*.03),
//              ElevatedButton.icon(
              
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.black,
//                           shape: const StadiumBorder(),
//                           minimumSize: Size(MediaQuery.of(context).size.width * .5, MediaQuery.of(context).size.height * .06)),
//                       onPressed: () {
//                         // if (_formKey.currentState!.validate()) {
//                         //   _formKey.currentState!.save();
//                         //   APIs.updateUserInfo().then((value) {
//                         //     Dialogs.showSnackbar(
//                         //         context, 'Profile Updated Successfully!');
//                         //   });
//                         // }
//                       },
//                       icon: const Icon(Icons.edit, size: 28),
//                       label:
//                           const Text('UPDATE', style: TextStyle(fontSize: 16)),
//                     )
//       ]),
//     );
//   }


// }
