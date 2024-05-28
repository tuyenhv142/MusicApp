import 'package:app/models/singer_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SingerProvider with ChangeNotifier {
  List<Singer> listSinger = [];
  Singer? currentSinger;

  Future<void> getSingerData() async {
    try {
      QuerySnapshot singerSnapshot =
          await FirebaseFirestore.instance.collection("singer").get();
      final singerData =
          singerSnapshot.docs.map((e) => Singer.fromSnapshot(e)).toList();

      listSinger = singerData;
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching singer data: $error');
      }
    }
  }

  List<Singer> get getListSinger {
    return listSinger;
  }

  Singer? getCurrentSinger() {
    return currentSinger;
  }

  Future<void> singerDetail(id) async {
    Singer? singer = listSinger.firstWhere((singer) => singer.id == id);
    currentSinger = singer;
    notifyListeners();
    }

  Future<Singer?> getSingerById(artistId) async {
    try {
      return listSinger.firstWhere((artist) => artist.id == artistId);
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching artist by ID: $error');
      }
      return null;
    }
  }

  Future<List<Singer>> getArtistsByIdList(List<String> artistIds) async {
    try {
      List<Singer> artists = [];
      for (String id in artistIds) {
        Singer? artist = await getSingerById(id);
        if (artist != null) {
          artists.add(artist);
        }
      }
      return artists;
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching artists by ID list: $error');
      }
      return [];
    }
  }
}
