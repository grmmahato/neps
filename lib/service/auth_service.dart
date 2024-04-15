import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:neps_chat_project/common_provider/firebase_instances.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;


final usersStream = StreamProvider.autoDispose((ref) => ref.read(chatCore).users());
final singeUser = StreamProvider.family((ref, String id) => AuthService.getUsers(id));

final authService = Provider((ref) => AuthService(
    chatCore: ref.watch(chatCore),
    messaging: ref.watch(msg),
    auth: ref.watch(auth),
    storage: ref.watch(storage),

));


class AuthService {

  final FirebaseAuth auth;
  final FirebaseMessaging messaging;
  final FirebaseChatCore chatCore;
  final FirebaseStorage storage;

  AuthService({
    required this.chatCore,
    required this.messaging,
    required this.auth,
    required this.storage,

});

static final userDb = FirebaseFirestore.instance.collection('users');



 static Stream<types.User> getUsers(String userId){
return userDb.doc(userId).snapshots().map((event) {

  final json = event.data() as Map<String, dynamic>;
  return   types.User(
        id: event.id,
          firstName: json['firstName'],
          metadata: {
            'email': json['metadata']['email'],
            'token': json['metadata']['token']
          },
          imageUrl: json['imageUrl']
         );
});
    // return userDb.snapshots().map((event) {
    //   return event.docs.map((e){
    //     final json = e.data();
    //     return   types.User(
    //       id: e.id,
    //       firstName: json['firstName'],
    //       metadata: {
    //         'email': json['metadata']['email'],
    //         'token': json['metadata']['token']
    //       },
    //       imageUrl: json['imageUrl']
    //     );
    //   }).toList();

    // });
  }





   Future<Either<String, bool>> userLogin({
    required String email,
     required String password
}) async{

     try {
       final token = await messaging.getToken();
      final response = await auth.signInWithEmailAndPassword(
          email: email, password: password);
     await userDb.doc(response.user!.uid).update({
       'metadata': {
         'email': email,
         'token': token
       }
     });

      return Right(true);
    } on FirebaseAuthException catch (err) {
      return Left(err.message.toString());
    }catch (err){
      return Left(err.toString());
    }
  }


  Future<Either<String, bool>> userSignUp({
    required String email,
    required String password,
    required String userName,
    required XFile  image
  }) async{
    try {
   final ref =  storage.ref().child('userImage/${image.name}');
   await ref.putFile(File(image.path));
   final url = await ref.getDownloadURL();
   final token = await messaging.getToken();
   final response = await auth.createUserWithEmailAndPassword(
       email: email, password: password);
   chatCore.createUserInFirestore(
     types.User(
       id: response.user!.uid,
       firstName: userName,
       imageUrl: url,
       metadata: {
         'email': email,
         'token': token
       }
     )
   );

      return Right(true);
    } on FirebaseAuthException catch (err) {
      return Left(err.message.toString());
    }on FirebaseException catch (err){
      return Left(err.message.toString());
    } catch (err){
      return Left(err.toString());
    }
  }




  Future<Either<String, bool>> userLogOut() async{
    try {
      final response = await auth.signOut();
      return Right(true);
    } on FirebaseAuthException catch (err) {
      return Left(err.message.toString());
    }catch (err){
      return Left(err.toString());
    }
  }
}
