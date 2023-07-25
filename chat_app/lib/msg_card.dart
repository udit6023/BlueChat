import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/utility.dart';
import 'package:chat_app/model/msg_model.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'api_func.dart';


class MsgCard extends StatefulWidget {
  final MsgModel msg;  
  const MsgCard({super.key, required this.msg});

  @override
  State<MsgCard> createState() => _MsgCardState();
}

class _MsgCardState extends State<MsgCard> {
  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser!.uid==widget.msg.fromID? reciverUi():senderUi();
  }
//this is the chat interface of the user you are talking to
  Widget senderUi(){

    if(widget.msg.readTime.isEmpty){
      APIFunc.updateReadTime(widget.msg);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        
      Flexible(
        child: Container(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width*.04),
          margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.04,vertical: MediaQuery.of(context).size.height*.01),
          decoration: BoxDecoration(
            color: Colors.white24,
            border: Border.all(color: Colors.black87),
      
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(30),topRight:Radius.circular(30),bottomLeft: Radius.circular(30)),
            
          ),
          child: 
          widget.msg.typeMsg==Type.text?
          //show text
          Text(widget.msg.msg,style: TextStyle(fontSize: 15,color: Colors.black),)
          //show image
          :ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  placeholder: (context,url){
                    return CircularProgressIndicator();
                  },
                      imageUrl: widget.msg.msg,
                   ),
              ),
        ),
      ),
      Padding(
          padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*.04),
          child: Text(Utility.formatTime(context:context, msg: widget.msg.sentTime) ,style: TextStyle(fontSize: 13,color: Colors.black),),
          ),

      ],
    );
  }
  //this is your chat interface
  Widget reciverUi(){
    
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
         SizedBox(width: MediaQuery.of(context).size.width*.04),
         (widget.msg.readTime.isNotEmpty)?const Icon(Icons.done_all_outlined,color: Colors.blueAccent,):const Icon(Icons.done_all_outlined),
          
         Text(Utility.formatTime(context:context, msg: widget.msg.sentTime),style: TextStyle(fontSize: 13,color: Colors.black),),
          
          SizedBox(width: MediaQuery.of(context).size.width*.46,),
      Flexible(
        child: Container(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width*.04),
          margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*.04,vertical: MediaQuery.of(context).size.height*.01),
          decoration: BoxDecoration(
            color: Colors.white24,
            border: Border.all(color: Colors.black87),
      
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight:Radius.circular(30),bottomLeft: Radius.circular(30)),
            
          ),
          child:  widget.msg.typeMsg==Type.text?
          //show text
          Text(widget.msg.msg,style: TextStyle(fontSize: 15,color: Colors.black),)
          //show image
          :ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  placeholder: (context,url){
                      return CircularProgressIndicator();
                  },
                      imageUrl: widget.msg.msg,
                   ),
              ),
        ),
        ),

      ],
    );
  }
 
}