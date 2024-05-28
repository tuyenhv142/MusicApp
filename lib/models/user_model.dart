import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? idUser;
  final String? fullname;
  final String? email;
  final String? img;
  final String? dateEnter;
  final List<String>? favoriteTrackId;
  final List<String>? favoriteArtistId;
  final List<String>? favoritePlaylistId;

  UserModel({
    this.idUser,
    this.fullname,
    this.email,
    this.img,
    this.dateEnter,
    this.favoriteTrackId,
    this.favoriteArtistId,
    this.favoritePlaylistId,
  });

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return UserModel(
      idUser: data?['idUser'] ?? '',
      fullname: data?['fullname'] ?? '',
      email: data?['email'] ?? '',
      img: data?['img'] ?? '',
      dateEnter: data?['dateEnter'] ?? '',
      favoriteTrackId: (data?['favoriteTrackId'] as List<dynamic>?)
          ?.map((dynamic item) => item.toString())
          .toList(),
      favoriteArtistId: (data?['favoriteArtistId'] as List<dynamic>?)
          ?.map((dynamic item) => item.toString())
          .toList(),
      favoritePlaylistId: (data?['favoritePlaylistId'] as List<dynamic>?)
          ?.map((dynamic item) => item.toString())
          .toList(),
    );
  }

  Map<String, Object?> toFirestore() {
    return {
      'idUser': idUser ?? '',
      'fullname': fullname ?? '',
      'email': email ?? '',
      'img': img ?? '',
      'dateEnter': dateEnter ?? '',
      'favoriteTrackId': favoriteTrackId ?? [],
      'favoriteArtistId': favoriteArtistId ?? [],
      'favoritePlaylistId': favoritePlaylistId ?? [],
    };
  }

  List<Object?> get props => [
        idUser,
        fullname,
        email,
        img,
        dateEnter,
        favoriteTrackId,
        favoriteArtistId,
        favoritePlaylistId
      ];
}
