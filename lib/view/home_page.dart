import 'package:neps_chat_project/export_widgets.dart';
import 'package:neps_chat_project/view/recent_chats.dart';
import 'package:neps_chat_project/view/user_detail.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../constants/sizes.dart';
import '../main.dart';
import '../notification_service.dart';
import '../providers/crud_provider.dart';
import '../service/crud_service.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  types.User? logUser;

  @override
  void initState() {
    super.initState();

    // 1. This method call when app in terminated state and you get a notification
    // when you click on notification app open from terminated state and you can get notification data in this method

    FirebaseMessaging.instance.getInitialMessage().then(
      (message) async {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          LocalNotificationService.createanddisplaynotification(message);
          await flutterLocalNotificationsPlugin.cancelAll();
        }
      },
    );

    //2. This method only call when App in forground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
      (message) {
        print("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data11 ${message.data}");
          LocalNotificationService.createanddisplaynotification(message);
        }
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) async {
        print("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          LocalNotificationService.createanddisplaynotification(message);
          await flutterLocalNotificationsPlugin.cancelAll();
        }
      },
    );

    getToken();
  }

  Future<void> getToken() async {
    final response = await FirebaseMessaging.instance.getToken();
    print(response);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final us = ref.watch(auth);
      final users = ref.watch(usersStream);
      final user = ref.watch(singeUser(us.currentUser!.uid));
      final posts = ref.watch(postsStream);
      return Scaffold(
          appBar: AppBar(
            title: const Text('Sample Social'),
          ),
          drawer: Drawer(child: user.whenOrNull(data: (data) {
            logUser = data;
            return ListView(
              children: [
                DrawerHeader(
                    child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(data.imageUrl!),
                          fit: BoxFit.cover)),
                )),
                ListTile(
                  onTap: () {
                    ref.read(authProvider.notifier).userLogOut();
                  },
                  leading: const Icon(Icons.person),
                  title: Text(data.firstName!),
                ),
                ListTile(
                  onTap: () {
                    ref.read(authProvider.notifier).userLogOut();
                  },
                  leading: const Icon(Icons.mail),
                  title: Text(data.metadata!['email']),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.to(() => AddPage());
                  },
                  leading: const Icon(Icons.add),
                  title: const Text('create Post'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.to(() => RecentChats());
                  },
                  leading: const Icon(Icons.chat),
                  title: const Text('Recent Chats'),
                ),
                ListTile(
                  onTap: () {
                    ref.read(authProvider.notifier).userLogOut();
                  },
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Sign Out'),
                )
              ],
            );
          })),
          body: Column(
            children: [
              SizedBox(
                height: 170,
                width: double.infinity,
                child: users.when(
                    data: (data) {
                      return ListView.builder(
                          itemCount: data.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Get.to(() => UserDetail(data[index]));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          NetworkImage(data[index].imageUrl!),
                                    ),
                                    gapH12,
                                    Text(data[index].firstName!)
                                  ],
                                ),
                              ),
                            );
                          });
                    },
                    error: (err, stack) => Center(child: Text('$err')),
                    loading: () => Container()),
              ),
              Expanded(
                  child: posts.when(
                      data: (data) {
                        return Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    Get.to(() =>
                                        DetailPage(data[index], logUser!));
                                  },
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(data[index].title),
                                            const Spacer(),
                                            if (us.currentUser!.uid ==
                                                data[index].userId)
                                              IconButton(
                                                  onPressed: () {
                                                    Get.defaultDialog(
                                                        title: 'Customize Post',
                                                        content: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            _buildIconButton(
                                                                onpress: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  Get.to(() =>
                                                                      UpdatePage(
                                                                          data[
                                                                              index]));
                                                                },
                                                                iconData:
                                                                    Icons.edit),
                                                            _buildIconButton(
                                                                onpress: () {},
                                                                iconData: Icons
                                                                    .delete),
                                                            _buildIconButton(
                                                                onpress: () {},
                                                                iconData: Icons
                                                                    .close),
                                                          ],
                                                        ));
                                                  },
                                                  icon: const Icon(
                                                      Icons.more_horiz))
                                          ],
                                        ),
                                        Image.network(
                                          data[index].imageUrl,
                                          height: 200,
                                        ),
                                        if (us.currentUser!.uid !=
                                            data[index].userId)
                                          Row(
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    if (data[index]
                                                        .like
                                                        .usernames
                                                        .contains(logUser!
                                                            .firstName)) {
                                                      SnackShow.showError(
                                                          'you have already like this post');
                                                    } else {
                                                      ref
                                                          .read(crudProvider
                                                              .notifier)
                                                          .likePost(
                                                              postId:
                                                                  data[index]
                                                                      .id,
                                                              like: data[index]
                                                                      .like
                                                                      .likes +
                                                                  1,
                                                              name: logUser!
                                                                  .firstName!);
                                                    }
                                                  },
                                                  icon: const Icon(Icons
                                                      .thumb_up_alt_outlined)),
                                              Text(data[index].like.likes == 0
                                                  ? ''
                                                  : data[index]
                                                      .like
                                                      .likes
                                                      .toString())
                                            ],
                                          )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        );
                      },
                      error: (err, stack) => Text('$err'),
                      loading: () =>
                          const Center(child: CircularProgressIndicator())))
            ],
          ));
    });
  }

  IconButton _buildIconButton(
      {required VoidCallback onpress, required IconData iconData}) {
    return IconButton(onPressed: onpress, icon: Icon(iconData));
  }
}
