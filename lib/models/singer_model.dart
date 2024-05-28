import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Singer extends Equatable {
  final String? id;
  final String img;
  final String name;

  const Singer({
    this.id,
    required this.img,
    required this.name,
  });

  factory Singer.fromSnapshot(QueryDocumentSnapshot<Object?> document) {
    final data = document.data() as Map<String, dynamic>;
    return Singer(
        id: document.id, img: data['img'] ?? '', name: data['name'] ?? '');
  }

  @override
  List<Object?> get props => [id, img, name];
}
