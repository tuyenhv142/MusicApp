import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Track extends Equatable {
  final String? id;
  final String image;
  final String dateEnter;
  final String singerId;
  final String title;
  final String source;

  const Track({
    required this.id,
    required this.image,
    required this.dateEnter,
    required this.singerId,
    required this.title,
    required this.source,
  });

  factory Track.fromSnapshot(QueryDocumentSnapshot<Object?> document) {
    final data = document.data() as Map<String, dynamic>;
    return Track(
      id: document.id,
      image: data['image'] ?? '',
      dateEnter: data['dateEnter'] ?? '',
      singerId: data['singerId'] ?? '',
      title: data['title'] ?? '',
      source: data['source'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
        id,
        image,
        dateEnter,
        singerId,
        title,
        source,
      ];
}
