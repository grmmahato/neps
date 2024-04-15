import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:get/get.dart';
import '../constants/sizes.dart';
import '../providers/room_provider.dart';
import '../service/crud_service.dart';
import 'chat_page.dart';


class UserDetail extends ConsumerWidget {
final types.User user;
UserDetail(this.user);
  @override
  Widget build(BuildContext context, ref) {
    final posts = ref.watch(postsStream);
    return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(user.imageUrl!),
                    ),
                    gapW12,
                    Expanded(
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.firstName!),
                        Text(user.metadata!['email']),
                        ElevatedButton(
                            onPressed: () async{
                             final response = await ref.read(roomProvider).createRoom(user);
                             if(response != null){
                               final users = response.users;
                               final otherUser = users.firstWhere((element) => element.id != FirebaseAuth.instance.currentUser!.uid);
                               final currentUser =  users.firstWhere((element) => element.id == FirebaseAuth.instance.currentUser!.uid);
                               Get.to(() => ChatPage(response,  currentUser.firstName!, otherUser.metadata!['token']));
                             }

                            }, child: Text('Chatttng'))
                      ],
                    ))
                  ],
                ),
                gapH20,
                Expanded(
                    child: posts.maybeWhen(orElse: () => Container(),
                    data: (data){
                      final userPost = data.where((element) => element.userId == user.id).toList();
                      return GridView.builder(
                        itemCount: userPost.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 3/2,
                              crossAxisCount: 3),
                          itemBuilder: (context, index){
                            return Image.network(userPost[index].imageUrl);
                          }
                      );
                    }
                    )
                ),
              ],
            ),
          ),
        )
    );
  }
}
