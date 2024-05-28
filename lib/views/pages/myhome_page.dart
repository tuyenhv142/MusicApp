import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:provider/provider.dart';

import '../../models/track_model.dart';
import '../../view_models/user_provider.dart';
import '../widgets/musicdetail_widget.dart';

import 'home_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

UserProvider userProvider = UserProvider();

class _MyHomePageState extends State<MyHomePage> {
  bool isFavorite = false;
  static const double playerMinHeight = 60.0;
  late AudioPlayer audioPlayer;
  bool isPlaying = false;
  int currentIndex = 0;
  List<Track> playlist = [];
  Track? currentTrack;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  List<Map<String, dynamic>> playlistDataList = [];

  int selectedItem = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    audioPlayer = AudioPlayer();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    fetchCurrentTrackSelect(context);
    setupAudioListeners();
    userProvider.addListener(() {
      if (userProvider.currentTrackId != null &&
          currentTrack != null &&
          userProvider.currentTrackId != currentTrack!.id) {
        stopAudio();
      }
    });
  }

  void playSelectedTrack(Track track) async {
    final trackIndex = playlist.indexWhere((element) => element.id == track.id);
    final userProvider = Provider.of<UserProvider>(context,
        listen: false); // Gán giá trị cho userProvider
    final trackId = track.id ?? "";
    userProvider.setCurrentTrackId(trackId);
    if (trackIndex != -1) {
      final selectedTrack = playlist[trackIndex];
      if (currentTrack != null && currentTrack!.id != selectedTrack.id) {
        await stopAudio();
      }
      currentIndex = trackIndex;
      await audioPlayer.setSourceUrl(selectedTrack.source);
      setState(() {
        position = Duration.zero;
        isPlaying = true;
        currentTrack = selectedTrack;
      });
      await audioPlayer.resume();
    }
  }

  void fetchCurrentTrackSelect(BuildContext context) async {
    Provider.of<UserProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    List<Map<String, dynamic>> playlists =
        await userProvider.getPlaylistDataList(userProvider.currentUser.idUser);

    playlistDataList = playlists;

    if (userProvider.currentTrackId != null &&
        userProvider.trackList.isNotEmpty) {
      if (currentTrack != null &&
          isPlaying &&
          userProvider.currentTrackId != currentTrack!.id) {
        await stopAudio();
      }
      currentIndex = userProvider.trackList
          .indexWhere((track) => track.id == userProvider.currentTrackId);
      if (currentIndex != -1) {
        setState(() {
          currentTrack = userProvider.trackList[currentIndex];
          audioPlayer.setSourceUrl(currentTrack?.source ?? '');
        });
      }
      playlist = userProvider.trackList;
    } else {
      if (currentTrack != null) {
        await stopAudio();
        setState(() {
          currentTrack = null;
        });
      }
    }
  }

  Future<void> stopAudio() async {
    // if (audioPlayer.state == PlayerState.playing) {
    await audioPlayer.stop();
    setState(() {
      isPlaying = false;
    });
  }

  void setupAudioListeners() {
    audioPlayer.onPlayerStateChanged.listen((playerState) {
      if (playerState == PlayerState.stopped && isPlaying) {
        setState(() {
          isPlaying = false;
        });
      }
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
    audioPlayer.onPlayerComplete.listen((event) {
      if (currentIndex < playlist.length - 1) {
        currentIndex++;
        playCurrentTrack();
      } else {
        stopAudio();
      }
    });
  }

  Future<void> playCurrentTrack() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final track = playlist[currentIndex];
    final trackId = track.id ?? "";
    userProvider.setCurrentTrackId(trackId);
    await audioPlayer.stop();
    await audioPlayer.setSourceUrl(track.source);
    await audioPlayer.resume();
    setState(() {
      position = Duration.zero;
      isPlaying = true;
      currentTrack = track;
    });
  }

  TextEditingController playlistNameController = TextEditingController();

  void _showPlaylistDialog(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    List<Map<String, dynamic>> playlists =
    await userProvider.getPlaylistDataList(userProvider.currentUser.idUser);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add to Playlist'),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (playlists.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return ListTile(
                        title: Text(playlist['name']),
                        onTap: () async {
                          try {
                            String? playlistId = await userProvider.getPlaylistIdAtIndex(
                                userProvider.currentUser.idUser, index);
                            if (kDebugMode) {
                              print(playlistId);
                            }
                            if (playlistId != null && currentTrack != null) {
                              await userProvider.addToPlaylist(playlistId, currentTrack!.id);
                              Fluttertoast.showToast(
                                msg: 'Song added to playlist successfully!',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                              );
                            } else {
                              Fluttertoast.showToast(
                                msg: 'Failed to add song to playlist!',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                            }
                            Navigator.pop(context);
                          } catch (e) {
                            Fluttertoast.showToast(
                              msg: 'Error: ${e.toString()}',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          }
                        },
                      );
                    },
                  )
                else
                  const Text('No playlists available'),
                ElevatedButton(
                  onPressed: () {
                    _showCreatePlaylistDialog(context);
                  },
                  child: const Text('Create Playlist'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isDuplicate = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Create Playlist'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: playlistNameController,
                    decoration:
                        const InputDecoration(hintText: 'Enter playlist name'),
                  ),
                  if (isDuplicate)
                    const Text(
                      'Playlist name already exists. Please enter a different name.',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    String playlistName = playlistNameController.text;
                    isDuplicate = await userProvider.checkDuplicatePlaylist(
                        userProvider.currentUser.idUser, playlistName);
                    if (!isDuplicate) {
                      await userProvider.createPlaylist(
                          userProvider.currentUser.idUser, playlistName);
                      Fluttertoast.showToast(
                        msg: 'Playlist created successfully!',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                      );
                      Navigator.of(context).pop();
                      playlistNameController.clear();
                    } else {
                      setState(() {});
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void addPlaylist() {
    _showPlaylistDialog(context);
  }

  Future<void> onNext() async {
    if (currentIndex < playlist.length - 1) {
      currentIndex++;
    } else {
      currentIndex = 0;
    }
    await playCurrentTrack();
    setState(() {});
  }

  Future<void> onPrevious() async {
    if (currentIndex > 0) {
      currentIndex--;
    } else {
      currentIndex = playlist.length - 1;
    }
    await playCurrentTrack();
    setState(() {});
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Navigator(
            onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
              settings: settings,
              builder: (BuildContext context) => HomePage(),
            ),
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              if (userProvider.currentTrackId != null &&
                  userProvider.currentTrackId != currentTrack?.id) {
                currentIndex = userProvider.trackList.indexWhere(
                    (track) => track.id == userProvider.currentTrackId);
                if (currentIndex != -1) {
                  currentTrack = userProvider.trackList[currentIndex];
                  audioPlayer.setSourceUrl(currentTrack?.source ?? '');
                }
                playlist = userProvider.trackList;
                isFavorite = userProvider.getCurrentUser.favoriteTrackId
                        ?.contains(userProvider.currentTrackId) ??
                    false;
              }
              if (currentTrack == null) {
                return const SizedBox.shrink();
              }
              return Miniplayer(
                minHeight: playerMinHeight,
                maxHeight: MediaQuery.of(context).size.height,
                builder: (height, percentage) {
                  if (height <= playerMinHeight + 50.0) {
                    return SingleChildScrollView(
                      child: Container(
                        color: Colors.grey,
                        child: Center(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Image.network(
                                    currentTrack!.image,
                                    width: 100.0,
                                    height: playerMinHeight - 4.0,
                                    fit: BoxFit.cover,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              currentTrack!.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption!
                                                  .copyWith(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 16.0),
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              currentTrack!.singerId,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption!
                                                  .copyWith(fontSize: 12.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      if (isPlaying) {
                                        await audioPlayer.pause();
                                      } else {
                                        await audioPlayer.resume();
                                      }
                                      setState(() {
                                        isPlaying = !isPlaying;
                                      });
                                    },
                                    icon: Icon(
                                      isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await stopAudio();
                                      setState(() {
                                        currentTrack = null;
                                        Provider.of<UserProvider>(context,
                                            listen: false);
                                        userProvider.setCurrentTrackIdToNull();
                                        isPlaying = false;
                                      });
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return MusicDetailWidget(
                      track: currentTrack!,
                      isPlaying: isPlaying,
                      currentIndex: currentIndex,
                      playlist: playlist,
                      onPlayPause: () async {
                        if (isPlaying) {
                          await audioPlayer.pause();
                          setState(() {
                            isPlaying = false;
                          });
                        } else {
                          await audioPlayer.resume();
                          setState(() {
                            isPlaying = true;
                          });
                        }
                      },
                      onStop: () async {
                        await stopAudio();
                        setState(() {
                          currentTrack = null;
                          isPlaying = false;
                        });
                      },
                      onNext: () async {
                        await onNext();
                      },
                      onPrevious: () async {
                        await onPrevious();
                      },
                      currentPosition: position,
                      totalDuration: duration,
                      onSeek: (value) async {
                        if (!value.isNaN && !value.isInfinite) {
                          final newPosition =
                              Duration(seconds: (value).toInt());
                          setState(() {
                            position = newPosition;
                          });
                          await audioPlayer.seek(newPosition);
                          if (isPlaying) {
                            await audioPlayer.resume();
                          }
                        }
                      },
                      playSelectedTrack: playSelectedTrack,
                      addPlaylist: addPlaylist,
                      isFavorite: isFavorite,
                      onFavoriteChanged: (bool newFavoriteState) {
                        setState(() {
                          isFavorite = newFavoriteState;
                          if (isFavorite) {
                            userProvider.addFavoriteTrackId(
                                userProvider.currentTrackId ?? "");
                            Fluttertoast.showToast(
                              msg: 'Add to library successfully!',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                            );
                          } else {
                            userProvider.removeFavoriteTrackId(
                                userProvider.currentTrackId ?? "");
                            Fluttertoast.showToast(
                              msg: 'Delete to library successfully!',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                            );
                          }
                        });
                      },
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
