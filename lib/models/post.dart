

class Like{
  final int likes;
  final List<String> usernames;

  Like({
    required this.likes,
    required this.usernames
});

  factory Like.fromJson(Map<String, dynamic> json){
    return Like(likes: json['likes'],
        usernames: (json['usernames'] as List).map((e) => e as String).toList()
    );
  }

  Map<String, dynamic> toJson(){
    return {
    'likes': this.likes,
    'usernames': this.usernames
    };
  }

}


class Comment{
  final String userName;
  final String userImage;
  final String comment;
  Comment({
    required this.userName,
    required this.comment,
    required this.userImage
});
  factory Comment.fromJson(Map<String, dynamic> json){
    return Comment(
        userName: json['userName'],
        comment: json['comment'],
        userImage: json['userImage']
    );
  }
  Map<String, dynamic> toJson(){
    return {
    'userName': this.userName,
    'comment': this.comment,
    'userImage': this.userImage
    };
  }
}



class Post{
  final String id;
  final String userId;
  final String title;
  final String detail;
  final String imageUrl;
  final String imageId;
  final Like like;
  final List<Comment> comments;

  Post({
    required this.like,
    required this.imageUrl,
    required this.id,
    required this.userId,
    required this.title,
    required this.detail,
    required this.comments,
    required this.imageId
});


}