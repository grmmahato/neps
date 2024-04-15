
import 'dart:async';
import 'package:neps_chat_project/models/common_state.dart';
import 'package:neps_chat_project/service/crud_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/post.dart';


final crudProvider = StateNotifierProvider<CrudProvider, CommonState>((ref) => CrudProvider(CommonState.empty(),ref.watch(crudService)));

class CrudProvider extends StateNotifier<CommonState>{
  final CrudService service;
  CrudProvider(super.state, this.service);

  Future<void> createPost({
    required String title,
    required String detail,
    required String userId,
    required XFile  image
  }) async{

    state = state.copyWith(isLoad: true, errText: '', isError: false, isSuccess: false);
    final response = await service.createPost(title: title, detail: detail, userId: userId, image: image);
    response.fold(
            (l) {
          state = state.copyWith(isLoad: false, errText: l, isError: true, isSuccess: false);
        },
            (r) {
          state = state.copyWith(isLoad: false, errText: '', isError: false, isSuccess: r);
        }
    );
  }



  Future<void> updatePost({
    required String title,
    required String detail,
    required String id,
    XFile?  image,
    String?  imageId
  }) async{
    state = state.copyWith(isLoad: true, errText: '', isError: false, isSuccess: false);
    final response = await service.updatePost(title: title, detail: detail, id: id, image: image, imageId: imageId);
    response.fold(
            (l) {
          state = state.copyWith(isLoad: false, errText: l, isError: true, isSuccess: false);
        },
            (r) {
          state = state.copyWith(isLoad: false, errText: '', isError: false, isSuccess: r);
        }
    );
  }

  Future<void> removePost({
    required String postId,
    required String imageId,
  }) async{
    state = state.copyWith(isLoad: true, errText: '', isError: false, isSuccess: false);
    final response = await service.removePost(postId: postId, imageId: imageId);
    response.fold(
            (l) {
          state = state.copyWith(isLoad: false, errText: l, isError: true, isSuccess: false);
        },
            (r) {
          state = state.copyWith(isLoad: false, errText: '', isError: false, isSuccess: r);
        }
    );
  }


  Future<void> likePost({
    required String postId,
    required int like,
    required String name
  }) async {
    state = state.copyWith(isLoad: true, errText: '', isError: false, isSuccess: false);
    final response = await service.likePost(postId: postId, like: like, name: name);
    response.fold(
            (l) {
          state = state.copyWith(isLoad: false, errText: l, isError: true, isSuccess: false);
        },
            (r) {
          state = state.copyWith(isLoad: false, errText: '', isError: false, isSuccess: r);
        }
    );
    }

  Future<void> commentPost({
    required String postId,
    required Comment comment,
  }) async {
    state = state.copyWith(isLoad: true, errText: '', isError: false, isSuccess: false);
    final response = await service.commentPost(postId: postId, comment: comment);
    response.fold(
            (l) {
          state = state.copyWith(isLoad: false, errText: l, isError: true, isSuccess: false);
        },
            (r) {
          state = state.copyWith(isLoad: false, errText: '', isError: false, isSuccess: r);
        }
    );
  }




  }
