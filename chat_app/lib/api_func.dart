import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/model/msg_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

import 'model/chat_model.dart';

class APIFunc{
//this function will return a true false if a user exists or not by refrencing its uid
  Future<bool> userExists() async {
     log('user exists: ${FirebaseAuth.instance.currentUser!.email}');
    return (await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get()).exists;
  }

  static Future<void> updateActiveStatus(bool isOnline)async {
      FirebaseFirestore.instance.collection('users').doc(userID).update({
          'push_token': me.pushToken,
      });
  }

  //and if the user doesnt exists in our database but he/she is logged in then we have to update our database
  //with a new users data
  static Future<void> createUser() async {
    final auth=FirebaseAuth.instance.currentUser!;
    final time=DateTime.now().millisecondsSinceEpoch.toString();
    final user=ChatModel(image: auth.photoURL.toString(), name: auth.displayName.toString(), about: 'yaaay we are in this together', createdAt: time, lastActive: time, isOnline: false, id: auth.uid, pushToken: '', email: auth.email.toString());

    return await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set(user.toJson());
  }

static var userID=FirebaseAuth.instance.currentUser!.uid;
  //so in order to make do save every convos data separately since we didnt want to data from diff convos get mixed up
  //so for this we have to create a unique id which will work for that particular user and in this way their data will be saved and can be stored separately from others,
  //here we are creating a id that is going be to unique by comparing the two id's fromID and toID
 static String getConvoId(String id)=>userID.hashCode<= id.hashCode? '${userID}_$id':'${id}_$userID';

  //now we want the chats from the firestore database for this particular conversation id we just created
  static Stream<QuerySnapshot<Map<String,dynamic>>> getAllMessages(ChatModel user){
    return FirebaseFirestore.instance.collection('chats/${getConvoId(user.id)}/messages/').snapshots();
  }

  //now we need to send the messages to our database....for that we have to create a send msg api for that
  static Future<void> sendMessage(ChatModel chatuser,String msg,Type type) async {
    //this will work as our doc id
    final time=DateTime.now().millisecondsSinceEpoch.toString();
    final MsgModel message=MsgModel(msg: msg, toID: chatuser.id, typeMsg: type, readTime: '', sentTime: time, fromID: userID);
    final ref=FirebaseFirestore.instance.collection('chats/${getConvoId(chatuser.id)}/messages/');
    ref.doc(time).set(message.toJson()).then((value) => {
            sendPushNotification(chatuser, msg)
    });
  }

   //now this function will update the database with the time when the user hav seen the msg
  static Future<void> updateReadTime(MsgModel msg)async {
    //here we used fromId since we wanna know the user at the other hav seen the msg or not....so it will update that
    FirebaseFirestore.instance.collection('chats/${getConvoId(msg.fromID)}/messages/').doc(msg.sentTime).update({'readTime':DateTime.now().millisecondsSinceEpoch.toString()});
  }
static FirebaseStorage storage = FirebaseStorage.instance;

    // update profile picture of user
  static Future<void> updateProfilePicture(ChatModel user,File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/$userID.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    //this stm will get the image's url from firebase storage
    user.image = await ref.getDownloadURL();
    //and here we will update the image in firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .update({'image': user.image});
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {

    return FirebaseFirestore.instance
        .collection('users')
        .where('id',isNotEqualTo: userID) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  } 
 static late ChatModel me;
   // for getting current user info
  static Future<void> getSelfInfo() async {
    await FirebaseFirestore.instance.collection('users').doc(userID).get().then((user) async {
      if (user.exists) {
        me = ChatModel.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        //for setting user status to active
        APIFunc.updateActiveStatus(true);
        log('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }
//to get the last mesaage of a spcicfic chat so that we can show it in the chat card
  static Stream<QuerySnapshot<Map<String,dynamic>>> getlastMessage(ChatModel user){
    return FirebaseFirestore.instance.collection('chats/${getConvoId(user.id)}/messages/').orderBy('msg',descending: true)
    .limit(1).snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(ChatModel chatuser,File file) async {
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('chat_images/${getConvoId(chatuser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    //this stm will get the image's url from firebase storage
    final imageUrl = await ref.getDownloadURL();
    //and here we will update the image in firestore
    await sendMessage(chatuser, imageUrl, Type.image);
  }


//for firebase mrssaging token
  static FirebaseMessaging fmessage=FirebaseMessaging.instance;
   
static Future<void> getFirebaseMessagingToken() async {
   await fmessage.requestPermission();

    fmessage.getToken().then((token){
      if(token!=null){
        me.pushToken=token;
        log(token);
      }
      
    });
}


static Future<void> sendPushNotification(ChatModel chatuser,String msg)async{
  try{
    final body={
    "to":chatuser.pushToken,
    "notification": {
      "title":chatuser.name,
      "body":msg
    }
  };
var response = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'), 
headers: {
  HttpHeaders.contentTypeHeader:'application/json',
  HttpHeaders.authorizationHeader:
    "key=AAAAS36kVco:APA91bEZ8mMGA4OeM9YCPpMwxxFRUUmy1YNRZMVG7OWBdejO-4KoOt6Dg8GKDvwA6MEWBblU0x8-SxLRpunMthVoDXD_CoyB7v3_FmQEpP2Yeu0-uUUgW45GXC-r4e7ZVG9ubizq-zPK"
  
},
body: jsonEncode(body));
print('Response status: ${response.statusCode}');
print('Response body: ${response.body}');
  }catch(e){
    log("error occure ${e}");
  }
}

}