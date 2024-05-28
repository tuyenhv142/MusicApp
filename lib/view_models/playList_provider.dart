import 'package:app/models/playList_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlayListProvider with ChangeNotifier {
  List<PlayList> listPlayList = [];
  PlayList? currentPlaylist;

  Future<void> getPlayListData() async {
    try {
      QuerySnapshot playlistSnapshot = await FirebaseFirestore.instance
          .collection("playlist")
          .orderBy('dateEnter', descending: true)
          .get();
      final playlistData =
          playlistSnapshot.docs.map((e) => PlayList.fromSnapshot(e)).toList();

      listPlayList = playlistData;
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching playlist data: $error');
      }
    }
  }

  List<PlayList> get getListPlayList {
    return listPlayList;
  }

  PlayList? getCurrentPlaylist() {
    return currentPlaylist;
  }

  Future<void> playlistDetail(id) async {
    PlayList? playlist =
        listPlayList.firstWhere((playlist) => playlist.id == id);
    currentPlaylist = playlist;
    notifyListeners();
    }

  Future<PlayList?> getPlaylistById(playlistId) async {
    try {
      return listPlayList.firstWhere((playlist) => playlist.id == playlistId);
    } catch (error) {
      print('Error fetching track by ID: $error');
      return null;
    }
  }

  Future<List<PlayList>> getPlaylistsByIdList(List<String> playlistIds) async {
    try {
      List<PlayList> playlists = [];
      for (String id in playlistIds) {
        PlayList? playList = await getPlaylistById(id);
        if (playList != null) {
          playlists.add(playList);
        }
      }
      return playlists;
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching tracks by ID list: $error');
      }
      return [];
    }
  }
}
