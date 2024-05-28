import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:app/models/track_model.dart';

class TrackProvider with ChangeNotifier {
  List<Track> listTrack = [];
  List<Track> listNewTrack = [];
  Track? currentTrack;
  final audioPlayer = AudioPlayer();

  Future<void> getTrackData() async {
    try {
      QuerySnapshot trackSnapshot =
          await FirebaseFirestore.instance.collection("track").get();
      final trackData =
          trackSnapshot.docs.map((e) => Track.fromSnapshot(e)).toList();

      listTrack = trackData;
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching track data: $error');
      }
    }
  }

  Future<void> getNewReleaseData() async {
    try {
      QuerySnapshot trackSnapshot = await FirebaseFirestore.instance
          .collection("track")
          .orderBy("dateEnter", descending: true)
          .get();
      final trackData =
          trackSnapshot.docs.map((e) => Track.fromSnapshot(e)).toList();

      listNewTrack = trackData;
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching track data: $error');
      }
    }
  }

  List<Track> get getListTrack {
    return listTrack;
  }

  List<Track> get getNewListTrack {
    return listNewTrack;
  }

  Track? getCurrentTrack() {
    return currentTrack;
  }

  Future<void> playTrack(trackId) async {
    try {
      Track? track = listTrack.firstWhere((track) => track.id == trackId);
      currentTrack = track;
      notifyListeners();
        } catch (error) {
      if (kDebugMode) {
        print('Not found $trackId');
      }
    }
  }

  Future<Track?> getTrackById(trackId) async {
    try {
      return listTrack.firstWhere((track) => track.id == trackId);
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching track by ID: $error');
      }
      return null;
    }
  }

  Future<List<Track>> getTracksByIdList(List<String> trackIds) async {
    try {
      List<Track> tracks = [];
      for (String id in trackIds) {
        Track? track = await getTrackById(id);
        if (track != null) {
          tracks.add(track);
        }
      }
      return tracks;
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching tracks by ID list: $error');
      }
      return [];
    }
  }

  Future<List<Track>> getTracksByPlaylistId(playlistId) async {
    try {
      QuerySnapshot trackSnapshot = await FirebaseFirestore.instance
          .collection("track")
          .where('playlistId', isEqualTo: playlistId)
          .get();
      final trackData =
          trackSnapshot.docs.map((e) => Track.fromSnapshot(e)).toList();

      return trackData;
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching tracks by playlist ID: $error');
      }
      return [];
    }
  }
  Future<List<Track>> getTracksBySingerId(singerId) async {
    try {
      QuerySnapshot trackSnapshot = await FirebaseFirestore.instance
          .collection("track")
          .where('singerId', isEqualTo: singerId)
          .get();
      final trackData =
      trackSnapshot.docs.map((e) => Track.fromSnapshot(e)).toList();

      return trackData;
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching tracks by playlist ID: $error');
      }
      return [];
    }
  }
  Future<int> getTrackCountBySingerId(singerId) async {
    try {
      QuerySnapshot trackSnapshot = await FirebaseFirestore.instance
          .collection("track")
          .where('singerId', isEqualTo: singerId)
          .get();

      return trackSnapshot.size;
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching track count by singer ID: $error');
      }
      return 0;
    }
  }
}
