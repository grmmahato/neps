import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final auth = Provider((ref) => FirebaseAuth.instance);
final cloud = Provider((ref) => FirebaseFirestore.instance);
final chatCore = Provider((ref) => FirebaseChatCore.instance);
final storage = Provider((ref) => FirebaseStorage.instance);
final msg = Provider((ref) => FirebaseMessaging.instance);
