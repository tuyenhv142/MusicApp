import 'package:app/models/playList_model.dart';
import 'package:app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../models/track_model.dart';
import 'package:intl/intl.dart';

class UserProvider extends ChangeNotifier {
  UserModel currentUser = UserModel(
    idUser: "",
    fullname: "",
    email: "",
    img: "",
    dateEnter: "",
    favoriteTrackId: [],
    favoriteArtistId: [],
    favoritePlaylistId: [],
  );
  bool _shouldPlayNextSong = false;

  String? currentTrackId;
  PlayList? currentFavoritePlaylist;
  List<Track> trackList = [];

  void notifyTrackListChanged(List<Track> newList) {
    trackList = newList;
    notifyListeners();
  }

  bool get shouldPlayNextSong => _shouldPlayNextSong;

  void requestNextSong() {
    _shouldPlayNextSong = true;
    notifyListeners();
  }

  Future<void> getDocCurrentUser(String? id) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('user').doc(id).get();
    var us = UserModel(
      idUser: documentSnapshot['idUser'],
      fullname: documentSnapshot['fullname'],
      email: documentSnapshot['email'],
      img: documentSnapshot['img'],
      dateEnter: documentSnapshot['dateEnter'],
      favoriteTrackId:
          (documentSnapshot['favoriteTrackId'] as List<dynamic>).cast<String>(),
      favoriteArtistId: (documentSnapshot['favoriteArtistId'] as List<dynamic>)
          .cast<String>(),
      favoritePlaylistId:
          (documentSnapshot['favoritePlaylistId'] as List<dynamic>)
              .cast<String>(),
    );
    currentUser = us;
    notifyListeners();
  }

  void setCurrentTrackId(String trackId) {
    currentTrackId = trackId;
    notifyListeners();
  }

  void setCurrentTrackIdToNull() {
    currentTrackId = null;
    notifyListeners();
  }

  void addFavoriteTrackId(trackId) {
    currentUser.favoriteTrackId?.add(trackId);
    notifyListeners();
    updateFavoriteTrackIds();
  }

  List<String>? getFavoriteTrackIds(userId) =>
      currentUser.idUser == userId ? currentUser.favoriteTrackId : null;

  void removeFavoriteTrackId(trackId) {
    currentUser.favoriteTrackId?.remove(trackId);
    notifyListeners();
    updateFavoriteTrackIds();
  }

  void addFavoriteArtistId(artistId) {
    currentUser.favoriteArtistId?.add(artistId);
    notifyListeners();
    updateFavoriteArtistIds();
  }

  List<String>? getFavoriteArtistIds(userId) =>
      currentUser.idUser == userId ? currentUser.favoriteArtistId : null;

  void removeFavoriteArtistId(artistId) {
    currentUser.favoriteArtistId?.remove(artistId);
    notifyListeners();
    updateFavoriteArtistIds();
  }

  void addFavoritePlaylistId(playlistId) {
    if (!currentUser.favoritePlaylistId!.contains(playlistId)) {
      currentUser.favoritePlaylistId!.add(playlistId);
      notifyListeners();
      updateFavoritePlaylistIds();
    } else {
      if (kDebugMode) {
        print('Playlist ID already exists in favorites');
      }
    }
  }

  List<String>? getFavoritePlaylistIds(userId) =>
      currentUser.idUser == userId ? currentUser.favoritePlaylistId : null;

  void removeFavoritePlaylistId(playlistId) {
    currentUser.favoritePlaylistId?.remove(playlistId);
    notifyListeners();
    updateFavoritePlaylistIds();
  }

  bool isFavoriteTrack(trackId) {
    return currentUser.favoriteTrackId?.contains(trackId) ?? false;
  }

  bool isFavoriteArtist(trackId) {
    return currentUser.favoriteArtistId?.contains(trackId) ?? false;
  }

  bool isFavoritePlaylist(trackId) {
    return currentUser.favoritePlaylistId?.contains(trackId) ?? false;
  }

  Future<void> updateFavoriteTrackIds() async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser.idUser)
          .update({'favoriteTrackId': currentUser.favoriteTrackId});
    } catch (error) {
      if (kDebugMode) {
        print('Error updating favorite track IDs: $error');
      }
    }
  }

  Future<void> updateFavoriteArtistIds() async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser.idUser)
          .update({'favoriteArtistId': currentUser.favoriteArtistId});
    } catch (error) {
      if (kDebugMode) {
        print('Error updating favorite artist IDs: $error');
      }
    }
  }

  Future<void> updateFavoritePlaylistIds() async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser.idUser)
          .update({'favoritePlaylistId': currentUser.favoritePlaylistId});
    } catch (error) {
      if (kDebugMode) {
        print('Error updating favorite playlist IDs: $error');
      }
    }
  }

  Future<void> updateUser(UserModel user) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user.idUser)
        .set(user.toFirestore());
    getDocCurrentUser(user.idUser);
  }

  UserModel get getCurrentUser {
    return currentUser;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> createPlaylist(userId, String playlistName) async {
    try {
      bool isDuplicate = await checkDuplicatePlaylist(userId, playlistName);
      if (isDuplicate) {
        throw Exception('Playlist name is already taken');
      }
      String currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
      await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .collection('playlists')
          .doc()
          .set({
        'name': playlistName,
        'dateEnter': currentDate,
        'img':
            'https://i.pinimg.com/564x/01/37/d7/0137d782153a7a446e79c404d43fcc33.jpg',
        'content': '',
        'tracks': [],
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error creating playlist: $error');
      }
    }
  }

  Future<void> deletePlaylist(userId, playlistId) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .collection('playlists')
          .doc(playlistId)
          .delete();
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting playlist: $error');
      }
    }
  }



  Future<List<Map<String, dynamic>>> getPlaylistDataList(userId) async {
    try {
      List<Map<String, dynamic>> playlistDataList = [];
      QuerySnapshot playlistsSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .collection('playlists')
          .get();

      for (var playlist in playlistsSnapshot.docs) {
        final playlistData = playlist.data() as Map<String, dynamic>;
        playlistDataList.add({
          'id': playlist.id,
          'img': playlistData['img'],
          'name': playlistData['name'],
          'dateEnter': playlistData['dateEnter'],
          'content': playlistData['content'],
          'tracks': playlistData['tracks'],
        });
      }

      return playlistDataList;
    } catch (error) {
      if (kDebugMode) {
        print('Error getting playlists: $error');
      }
      return [];
    }
  }

  Future<void> setCurrentFavoritePlaylist(String? playlistId) async {
    if (playlistId != null) {
      try {
        DocumentSnapshot playlistSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(currentUser.idUser)
            .collection('playlists')
            .doc(playlistId)
            .get();

        if (playlistSnapshot.exists) {
          Map<String, dynamic>? playlistData =
              playlistSnapshot.data() as Map<String, dynamic>?;

          if (playlistData != null) {
            currentFavoritePlaylist = PlayList(
              id: playlistSnapshot.id,
              name: playlistData['name'] ?? '',
              img: playlistData['img'] ?? '',
              dateEnter: playlistData['dateEnter'] ?? '',
              content: playlistData['content'] ?? '',
              tracks: List<String>.from(playlistData['tracks'] ?? []),
            );
            notifyListeners();
          } else {
            if (kDebugMode) {
              print('Playlist data is null');
            }
          }
        } else {
          if (kDebugMode) {
            print('Playlist with ID $playlistId does not exist');
          }
        }
      } catch (error) {
        if (kDebugMode) {
          print('Error setting current favorite playlist: $error');
        }
      }
    } else {
      currentFavoritePlaylist = null;
      notifyListeners();
    }
  }

  Future<void> removeTrackFromPlaylist(
      String playlistId, String trackId) async {
    try {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('user').doc(currentUser.idUser);

      DocumentReference playlistDocRef =
          userDocRef.collection('playlists').doc(playlistId);

      DocumentSnapshot playlistSnapshot = await playlistDocRef.get();

      if (playlistSnapshot.exists) {
        List<String> tracks = List.from(playlistSnapshot['tracks']);
        tracks.remove(trackId);

        await playlistDocRef.update({'tracks': tracks});

        print('Track removed from playlist successfully.');
      } else {
        print('Playlist does not exist.');
      }
    } catch (error) {
      print('Error removing track from playlist: $error');
    }
  }

  PlayList? getCurrentFavoritePlaylist() {
    return currentFavoritePlaylist;
  }

  Future<bool> checkDuplicatePlaylist(userId, playlistName) async {
    QuerySnapshot playlistsSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .collection('playlists')
        .where('name', isEqualTo: playlistName)
        .get();

    return playlistsSnapshot.docs.isNotEmpty;
  }

  Future<void> renamePlaylist(String playlistId,String playlistName) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser.idUser)
          .collection('playlists')
          .doc(playlistId)
          .update({'name': playlistName});
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error rename  playlist: $e');
      }
    }
  }

  Future<void> updatePlaylistImage(playlistId, img) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser.idUser)
          .collection('playlists')
          .doc(playlistId)
          .update({'img': img});
    } catch (e) {
      if (kDebugMode) {
        print('Error rename  playlist: $e');
      }
    }
  }

  Future<void> addToPlaylist(String playlistId, trackId) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser.idUser)
          .collection('playlists')
          .doc(playlistId)
          .update({
        'tracks': FieldValue.arrayUnion([trackId]),
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error adding track to playlist: $error');
      }
    }
  }

  Future<String?> getPlaylistIdAtIndex(userId, int index) async {
    try {
      QuerySnapshot<Map<String, dynamic>> playlistsSnapshot =
          await FirebaseFirestore.instance
              .collection('user')
              .doc(userId)
              .collection('playlists')
              .get();

      if (index >= 0 && index < playlistsSnapshot.docs.length) {
        DocumentSnapshot<Map<String, dynamic>> playlistDoc =
            playlistsSnapshot.docs[index];

        return playlistDoc.id;
      } else {
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error getting playlist id at index: $error');
      }
      return null;
    }
  }
}
