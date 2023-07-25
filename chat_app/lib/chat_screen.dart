import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/model/msg_model.dart';
import 'package:chat_app/msg_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'api_func.dart';
import 'model/chat_model.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel chatModel;
  const ChatScreen({super.key, required this.chatModel});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List list=[];
  final _textController=TextEditingController();
  bool _showEmoji = false;
  bool _isUplodaing=false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: CupertinoColors.white,
        actions: [
        Row(
          children: [
          IconButton(onPressed: ()=>{
            Navigator.pop(context),
          }, icon: Icon(Icons.arrow_back,color: CupertinoColors.black,)),
          SizedBox(width: 100,),
          ClipRRect(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height*.3),
                child: CachedNetworkImage(
                  width: MediaQuery.of(context).size.height*.055,
                  height: MediaQuery.of(context).size.height*.055,
                      imageUrl: widget.chatModel.image,
                   ),
              ),
              SizedBox(width: 50,),
              Text(widget.chatModel.name,style: TextStyle(color: Colors.black),),
              SizedBox(width: 50,),
        ],)
      ]),
      body: Column(
        children: [

          Expanded(
            child: StreamBuilder(
              stream: APIFunc.getAllMessages(widget.chatModel),
                  builder: (BuildContext context, AsyncSnapshot snapshot,){
                  if(snapshot.connectionState==ConnectionState.waiting)
                  {
            return const SizedBox();
                  }
                  if(snapshot.hasError)
                  {
            return const Text("Something went wrong");
                  }
          
          final data=snapshot.data?.docs;
         // print('${jsonEncode(data[0].data())}');
         list=data?.map((e)=> MsgModel.fromJson(e.data())).toList() ??[];
        //  list.clear();
        //  list.add(MsgModel(msg: "hello", toID: "122345", typeMsg: Type.text, readTime: "12:00", sentTime: "09:00", fromID: userID));
        //  list.add(MsgModel(msg: "Shukriya bhai", toID:userID, typeMsg: Type.text, readTime: "12:00", sentTime: "09:00", fromID: "123456"));
        if(list.isNotEmpty)
        {
            return ListView.builder(
              reverse: true,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: list.length
         
        ,itemBuilder:(context,index){
          return MsgCard(msg: list[index],);
          //Text("My name is ${data.docs[index]['name']} and i am ${data.docs[index]['age']} years old}");
        });
        }else{
          return const Center(child: Text("Hiii 👀",style: TextStyle(fontSize: 20),));
        }
            
                  
                  
                },),
          ),
    if(_isUplodaing)
      Align(
            alignment: Alignment.bottomRight,
            child: CircularProgressIndicator()),
    
          
          _chatScreen(),

          if (_showEmoji)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 234, 248, 255),
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )


        ],
      ),
    );
  }
  
  _chatScreen() {
      return Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                IconButton(onPressed: ()=>{
                         FocusScope.of(context).unfocus(),
                        setState(() => _showEmoji = !_showEmoji),

                  }, icon: Icon(Icons.emoji_emotions,color: CupertinoColors.black,)),
            
            
                  Expanded(child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Type Something here....',
                      hintStyle: TextStyle(color: Colors.black),
                      border: InputBorder.none,
                    ),
                  )),
            
                  IconButton(onPressed: () async {
                   
                        final ImagePicker picker = ImagePicker();
                    
                        // Pick an image
                        final List<XFile> image = await picker.pickMultiImage(
                            imageQuality: 70);
                            for(var i in image){
                               log('Image Path: ${i.path}');
                               setState(() {
                                 _isUplodaing=true;
                               });
                               
                              await APIFunc.sendChatImage(widget.chatModel,File(i.path));
                              setState(() {
                                 _isUplodaing=false;
                               });
                            }
                  }, icon: Icon(Icons.image,color: CupertinoColors.black,)),
                  IconButton(onPressed: () async {

                    final ImagePicker picker = ImagePicker();
                    
                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          log('Image Path: ${image.path}');
                          setState(() {
                                 _isUplodaing=true;
                               });

                        await APIFunc.sendChatImage(widget.chatModel,File(image.path));
                        setState(() {
                                 _isUplodaing=false;
                               });
                         

                        }
                    
                  }, icon: Icon(Icons.camera_alt,color: CupertinoColors.black,)),
              ],),
            ),
          ),
          MaterialButton(onPressed: (){
              if(_textController.text.isNotEmpty){
                APIFunc.sendMessage(widget.chatModel, _textController.text,Type.text);
                //and once we sent the value in the controller to the func then clear the data in the controller
                _textController.clear();
              }
          },
          minWidth: 0,
          padding: EdgeInsets.only(top:10,bottom: 10,right: 5,left: 10),
          shape: CircleBorder(),
          color:Colors.green,
            child: Icon(Icons.send,color: Colors.white,),
          )
        ],
      );
  }

  
   
}