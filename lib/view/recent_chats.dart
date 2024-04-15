import 'package:neps_chat_project/view/chat_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../providers/room_provider.dart';



class RecentChats extends ConsumerWidget {

  @override
  Widget build(BuildContext context, ref) {
    final roomData = ref.watch(rooms);
    return Scaffold(
        body: SafeArea(
            child: roomData.when(
                data: (data){
                  return ListView.builder(
                      itemCount: data.length,
                      itemBuilder:(context, index){
                        final users = data[index].users;
                        final otherUser = users.firstWhere((element) => element.id != FirebaseAuth.instance.currentUser!.uid);
                        final currentUser =  users.firstWhere((element) => element.id == FirebaseAuth.instance.currentUser!.uid);
                        return ListTile(
                          onTap: (){
                            Get.to(() => ChatPage(data[index], currentUser.firstName!, otherUser.metadata!['token']));
                          },
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(data[index].imageUrl!),
                          ),
                          title: Text(data[index].name!),
                        );
                      }
                  );
                },
                error: (err, sta) => Container(),
                loading: () => CircularProgressIndicator()
            )
        )
    );
  }
}
