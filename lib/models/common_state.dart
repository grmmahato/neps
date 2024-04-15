import 'package:freezed_annotation/freezed_annotation.dart';
part 'common_state.freezed.dart';



@freezed
class CommonState with _$CommonState{
const factory CommonState ({
  required bool isLoad,
  required bool isError,
  required bool isSuccess,
  required String errText
}) = _CommonState;


factory CommonState.empty(){
  return CommonState(isLoad: false, isError: false, isSuccess: false, errText: '');
}

}


