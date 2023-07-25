
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api_func.dart';
import 'package:chat_app/helper/utility.dart';
import 'package:chat_app/model/chat_model.dart';
import 'package:chat_app/model/msg_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'chat_screen.dart';

class chatCard extends StatelessWidget {
  final ChatModel chatModel;
  chatCard({super.key, required this.chatModel});

  @override
  Widget build(BuildContext context) {
    MsgModel? message;
    return InkWell(
      onTap: () => {
        Navigator.push(context, MaterialPageRoute(builder: (_)=>ChatScreen(chatModel: chatModel,)))
      },
      child: Card(
            child: StreamBuilder(
              stream: APIFunc.getlastMessage(chatModel),
              builder:  (BuildContext context, AsyncSnapshot snapshot) {

                final data=snapshot.data?.docs;
                final list=data?.map((e)=>MsgModel.fromJson(e.data())).toList()??[];
                if(list.isNotEmpty){
                  message=list[0];
                }
              return ListTile(
              //leading: CircleAvatar(child: Icon(Icons.person),),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height*.3),
                child: CachedNetworkImage(
                  width: MediaQuery.of(context).size.height*.055,
                  height: MediaQuery.of(context).size.height*.055,
                      imageUrl: chatModel.image,
                   ),
              ),
              title: Text(chatModel.name),
              subtitle: Text(message!=null?(message!.typeMsg==Type.text?message!.msg:"image"):chatModel.about,maxLines: 1,),
              trailing:message==null?null:message!.readTime.isEmpty && message!.fromID!=APIFunc.userID?Container(width: 15,height: 15,decoration: BoxDecoration(color: Colors.greenAccent.shade400,borderRadius: BorderRadius.circular(10)),):
              Text(Utility.getLastMessageTime(message!.sentTime, context),style: TextStyle(color: Colors.black54),)
            );
            })

      ),
    );
    }
}