class MsgModel {
  MsgModel({
    required this.msg,
    required this.toID,
    required this.typeMsg,
    required this.readTime,
    required this.sentTime,
    required this.fromID,
  });
  late final String msg;
  late final String toID;
  late final Type typeMsg;
  late final String readTime;
  late final String sentTime;
  late final String fromID;
  
  MsgModel.fromJson(Map<String, dynamic> json){
    msg = json['msg'];
    toID = json['toID'];
    typeMsg = json['typeMsg']==Type.image.name?Type.image:Type.text;
    readTime = json['readTime'];
    sentTime = json['sentTime'];
    fromID = json['fromID'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['toID'] = toID;
    data['typeMsg'] = typeMsg.name;
    data['readTime'] = readTime;
    data['sentTime'] = sentTime;
    data['fromID'] = fromID;
    return data;
  }
  
}
//since the msg type can be a normal text or it can be any image so in order to avoid any confusion we defined an enum
enum Type{ text,image}