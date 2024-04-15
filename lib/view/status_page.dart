import 'package:neps_chat_project/view/auth_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'home_page.dart';



class StatusPage extends StatelessWidget {
  const StatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer(
            builder: (context, ref, child) {
              final authData =ref.watch(userStream);
              return  authData.when(
                  data: (data){
                    if(data == null){
                      return AuthPage();
                    }else{
                      return HomePage();
                      if(data.emailVerified){
                        return HomePage();
                      }else{
                     return   Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                         TextButton(onPressed: (){
                           data.sendEmailVerification();
                         },child: Text('Send Verify'),),
                         TextButton(onPressed: () async{
                           await FirebaseAuth.instance.currentUser!.reload();
                         },child: Text('check Verify'),),
                       ],
                     );
                      }
                      data.sendEmailVerification();

                    }
                  },
                  error: (err, stack) => Center(child: Text('$err')),
                  loading: () => Center(child: CircularProgressIndicator())
              );
            }
        )
    );
  }
}
