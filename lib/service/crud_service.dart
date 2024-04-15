import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/post.dart';

final crudService = Provider((ref) => CrudService());
final postsStream = StreamProvider((ref) => CrudService.getPosts);
class CrudService {
  static final postDb = FirebaseFirestore.instance.collection('posts');

  static Stream<List<Post>> get getPosts {
    return postDb.snapshots().map((event) => event.docs.map((e) {
          final json = e.data();
          return Post(
              like: Like.fromJson(json['like']),
              imageUrl: e['imageUrl'],
              id: e.id,
              userId: e['userId'],
              imageId: e['imageId'],
              title: e['title'],
              detail: e['detail'],
              comments: (json['comments'] as List).map((e) => Comment.fromJson(e)).toList()
          );
        }).toList());
  }

  Future<Either<String, bool>> createPost(
      {required String title,
      required String detail,
      required String userId,
      required XFile image}) async {
    try {
      final ref =
          FirebaseStorage.instance.ref().child('postImage/${image.name}');
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      await postDb.add({
        'userId': userId,
        'title': title,
        'detail': detail,
        'imageId': image.name,
        'imageUrl': url,
        'like': {'likes': 0, 'usernames': []},
        'comments': []
      });
      return Right(true);
    } on FirebaseException catch (err) {
      return Left(err.message.toString());
    } catch (err) {
      return Left(err.toString());
    }
  }

  Future<Either<String, bool>> updatePost(
      {required String title,
      required String detail,
      required String id,
      XFile? image,
      String? imageId}) async {
    try {
      if (image == null) {
        await postDb.doc(id).update({
          'title': title,
          'detail': detail,
        });
      } else {
        final ref =
            FirebaseStorage.instance.ref().child('postImage/${imageId}');
        await ref.delete();
        final ref1 =
            FirebaseStorage.instance.ref().child('postImage/${image.name}');
        await ref1.putFile(File(image.path));
        final url = await ref1.getDownloadURL();
        await postDb.doc(id).update({
          'title': title,
          'detail': detail,
          'imageUrl': url,
          'imageId': image.name,
        });
      }
      return Right(true);
    } on FirebaseException catch (err) {
      return Left(err.message.toString());
    } catch (err) {
      return Left(err.toString());
    }
  }

  Future<Either<String, bool>> removePost({
    required String postId,
    required String imageId,
  }) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('postImage/${imageId}');
      await ref.delete();
      await postDb.doc(postId).delete();
      return Right(true);
    } on FirebaseException catch (err) {
      return Left(err.message.toString());
    } catch (err) {
      return Left(err.toString());
    }
  }




  Future<Either<String, bool>> likePost({
    required String postId,
    required int like,
    required String name
  }) async {
    try {
      await postDb.doc(postId).update({
        'like': {
          'likes': like,
          'usernames':  FieldValue.arrayUnion([name])
        }
      });
      return Right(true);
    } on FirebaseException catch (err) {
      return Left(err.message.toString());
    } catch (err) {
      return Left(err.toString());
    }
  }





  Future<Either<String, bool>> commentPost({
    required String postId,
    required Comment comment,
  }) async {
    try {
      await postDb.doc(postId).update({
          'comments':  FieldValue.arrayUnion([comment.toJson()])
      });
      return Right(true);
    } on FirebaseException catch (err) {
      return Left(err.message.toString());
    } catch (err) {
      return Left(err.toString());
    }
  }




}
