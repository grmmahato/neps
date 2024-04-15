import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/room_provider.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class ChatPage extends ConsumerStatefulWidget {
final types.Room room;
final String name;
final String token;
ChatPage(this.room, this.name, this.token);
  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  @override
  Widget build(BuildContext context) {
    final msg = ref.watch(messageStream(widget.room));
    return Scaffold(
        body: msg.when(
            data: (data){
              return Chat(
                messages: data,
                onAttachmentPressed: () async{
                  final ImagePicker picker = ImagePicker();

                  picker.pickImage(source: ImageSource.gallery).then((val) async{
                    if(val != null){

                      final ref =  FirebaseStorage.instance.ref().child('chatImage/${val.name}');
                      await ref.putFile(File(val.path));
                      final url = await ref.getDownloadURL();
                      final bytes = File(val.path).lengthSync();
                      final imageData = types.PartialImage(
                          uri: url,
                          size: bytes,
                          name: val.name
                      );

                      FirebaseChatCore.instance.sendMessage(
                          imageData,widget.room.id);
                    }
                  });

                },
                onSendPressed: (val) async{

                  try{
                    FirebaseChatCore.instance.sendMessage(
                        types.PartialText(text: val.text),widget.room.id);
                    final dio = Dio();
                    final response = await dio.post('https://fcm.googleapis.com/fcm/send',
                        data: {
                          "notification": {
                            "title": widget.name,
                            "body": val.text,
                            "android_channel_id": "High_importance_channel"
                          },
                          "to": widget.token

                        }, options: Options(
                            headers: {
                              HttpHeaders.authorizationHeader : 'key=AAAAyR3B5O4:APA91bH4mQYqY_71-s8Us7lugNNWDlGobOUuRMTPIzKNTMVaLc1B6f5KjIvLV6YLIvbg6o6IrLzoSUFEG9nPgOQTYBpXXy1ZUIQFJ26J5AMkQs_JvGgFNzVIuc8aT0IkPbxcFeAhMRS4'
                            }
                        )
                    );
                    print(response.data);

                  }on FirebaseException catch (err){
                    print(err);
                  } catch(err){
                    print(err);
                  }





                }, user: types.User(
                  id: FirebaseAuth.instance.currentUser!.uid
              ),
                showUserAvatars: true,
                showUserNames: true,
              );
            },
            error: (err,s) => Container(),
            loading: () => Center(child: CircularProgressIndicator())
        )
    );
  }
}
