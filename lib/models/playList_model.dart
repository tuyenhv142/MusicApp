import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PlayList extends Equatable {
  final String? id;
  final String img;
  final String name;
  final String dateEnter;
  final String content;
  final List<String>? tracks;

  const PlayList(
      {this.id,
      required this.img,
      required this.name,
      required this.dateEnter,
      required this.content,
      required this.tracks});

  factory PlayList.fromSnapshot(QueryDocumentSnapshot<Object?> document) {
    final data = document.data() as Map<String, dynamic>;
    return PlayList(
      id: document.id,
      img: data['img'] ?? '',
      name: data['name'] ?? '',
      dateEnter: data['dateEnter'] ?? "",
      content: data['content'] ?? "",
      tracks: (data['tracks'] as List<dynamic>?)
          ?.map((dynamic item) => item.toString())
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, img, name, dateEnter, content, tracks];
}
