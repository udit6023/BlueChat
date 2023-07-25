
import 'package:chat_app/api_func.dart';
import 'package:chat_app/chat_card.dart';
import 'package:chat_app/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/src/widgets/framework.dart';


import 'model/chat_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    // TODO: implement initState
    APIFunc.getSelfInfo();
    super.initState();
  }


  List list=[];
//     //so currently this statment will show all the data from the data but we didnt want to show our data,
//     //cause we didnt want chat with ourself so we can change this statement with a where clause like,
//     // .collection('users').where('id',isNotEqualTo: FirebaseAuth.instance.currentUser!.uid);
    final Stream<QuerySnapshot> users=APIFunc.getAllUsers();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: CupertinoColors.black,
        centerTitle: true,
        title: const Text("Hook",style: TextStyle(fontSize: 30),),
        leading: IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(user: APIFunc.me,)));
        },icon:const Icon(Icons.account_box_outlined)),
        actions: [
          const Icon(Icons.search),
          SizedBox(width:MediaQuery.of(context).size.width*.05),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
      children:[ 
        StreamBuilder<QuerySnapshot>(
          stream:users,builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot,){
        if(snapshot.connectionState==ConnectionState.waiting)
        {
          return const CircularProgressIndicator();
        }
        if(snapshot.hasError)
        {
          return const Text("Something went wrong");
        }

        final dynamic data=snapshot.data?.docs;

        list=data?.map((e)=> ChatModel.fromJson(e.data())).toList();
        if(list.isNotEmpty)
        {
            return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: list.length
         
        ,itemBuilder:(context,index){
          return chatCard(chatModel: list[index],);
          //Text("My name is ${data.docs[index]['name']} and i am ${data.docs[index]['age']} years old}");
        });
        }else{
          return const Center(child: Text("No users found",style: TextStyle(fontSize: 20),));
        }
        
      },)
      ]
    ),
    floatingActionButton: FloatingActionButton(
        onPressed: () async{
          

        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.navigation),
      ),);
  }
}


// class HomePage extends StatelessWidget {
//   const HomePage({super.key});


  
//   @override
//   Widget build(BuildContext context) {
//     

//     return Scaffold(
//       appBar: AppBar(
//         elevation: 1,
//         backgroundColor: CupertinoColors.black,
//         centerTitle: true,
//         title: const Text("Hook",style: TextStyle(fontSize: 30),),
//         leading: IconButton(onPressed: (){
//           Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(user: APIFunc.me,)));
//         },icon:const Icon(Icons.account_box_outlined)),
//         actions: [
//           const Icon(Icons.search),
//           SizedBox(width:MediaQuery.of(context).size.width*.05),
//         ],
//       ),
//       backgroundColor: Colors.white,
//       body: Column(
//       children:[ 
//         StreamBuilder<QuerySnapshot>(
//           stream:users,builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot,){
//         if(snapshot.connectionState==ConnectionState.waiting)
//         {
//           return const CircularProgressIndicator();
//         }
//         if(snapshot.hasError)
//         {
//           return const Text("Something went wrong");
//         }

//         final dynamic data=snapshot.data?.docs;

//         list=data?.map((e)=> ChatModel.fromJson(e.data())).toList();
//         if(list.isNotEmpty)
//         {
//             return ListView.builder(
//           scrollDirection: Axis.vertical,
//           shrinkWrap: true,
//           itemCount: list.length
         
//         ,itemBuilder:(context,index){
//           return chatCard(chatModel: list[index],);
//           //Text("My name is ${data.docs[index]['name']} and i am ${data.docs[index]['age']} years old}");
//         });
//         }else{
//           return const Center(child: Text("No users found",style: TextStyle(fontSize: 20),));
//         }
        
//       },)
//       ]
//     ),
//     floatingActionButton: FloatingActionButton(
//         onPressed: () async{
          

//         },
//         backgroundColor: Colors.green,
//         child: const Icon(Icons.navigation),
//       ),);
//   }
// }