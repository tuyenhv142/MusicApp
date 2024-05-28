import 'package:app/views/pages/search_pages.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:provider/provider.dart';

import '../../models/track_model.dart';
import '../../view_models/user_provider.dart';
import 'account_page.dart';

import 'favorite_pages/favorite_song_page.dart';
import 'home_page.dart';

class NavPage extends StatefulWidget {
  const NavPage({Key? key}) : super(key: key);

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  static const double playerMinHeight = 60.0;
  late AudioPlayer audioPlayer;
  bool isPlaying = false;
  int currentIndex = 0;
  List<Track> playlist = [];
  Track? currentTrack;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  int selectedItem = 0;

  final pages = [
    HomePage(),
    FavoritePage(),
    SearchPage(),
    AccountPage(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    audioPlayer = AudioPlayer();
    fetchCurrentTrackSelect();
    setupAudioListeners();
  }

  void playSelectedTrack(Track track) async {
    final trackIndex = playlist.indexWhere((element) => element.id == track.id);
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

  void fetchCurrentTrackSelect() async {
    final userProvider = Provider.of<UserProvider>(context);
    if (userProvider.currentTrackId != null &&
        userProvider.trackList.isNotEmpty) {
      await stopAudio();

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

  void playCurrentTrack() async {
    final track = playlist[currentIndex];
    await audioPlayer.stop();
    await audioPlayer.setSourceUrl(track.source);
    await audioPlayer.resume();
    setState(() {
      position = Duration.zero;
      isPlaying = true;
      currentTrack = track;
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Current playing source: ${currentTrack?.source ?? 'None'}');

    return Scaffold(
      body: Builder(builder: (context) {
        return Stack(
          children: pages
              .asMap()
              .map((key, value) => MapEntry(
                    key,
                    Offstage(
                      offstage: selectedItem != key,
                      child: value,
                    ),
                  ))
              .values
              .toList()
            ..add(
              Offstage(
                offstage: currentTrack == null,
                child: Miniplayer(
                    minHeight: playerMinHeight,
                    maxHeight: MediaQuery.of(context).size.height,
                    builder: (height, percentage) {
                      if (currentTrack == null) return const SizedBox.shrink();
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                        icon: Icon(isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          await stopAudio();
                                          setState(() {
                                            currentTrack = null;
                                            isPlaying = false;
                                          });
                                        },
                                        icon: Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return SafeArea(
                          child: Container(),
                          // MusicDetailWidget(
                          //   track: currentTrack!,
                          //   isPlaying: isPlaying,
                          //   currentIndex: currentIndex,
                          //   playlist: playlist,
                          //   onPlayPause: () async {
                          //     if (isPlaying) {
                          //       await audioPlayer.pause();
                          //       setState(() {
                          //         isPlaying = false;
                          //       });
                          //     } else {
                          //       await audioPlayer.resume();
                          //       setState(() {
                          //         isPlaying = true;
                          //       });
                          //     }
                          //   },
                          //   onStop: () async {
                          //     await stopAudio();
                          //     setState(() {
                          //       currentTrack = null;
                          //       isPlaying = false;
                          //     });
                          //   },
                          //   onNext: () {
                          //     if (currentIndex < playlist.length - 1) {
                          //       currentIndex++;
                          //       playCurrentTrack();
                          //     }
                          //   },
                          //   onPrevious: () {
                          //     if (currentIndex > 0) {
                          //       currentIndex--;
                          //       playCurrentTrack();
                          //     }
                          //   },
                          //   currentPosition: position,
                          //   totalDuration: duration,
                          //   onSeek: (value) async {
                          //     if (!value.isNaN &&
                          //         !value.isInfinite) {
                          //       final newPosition =
                          //           Duration(seconds: (value ?? 0).toInt());
                          //       setState(() {
                          //         position = newPosition;
                          //       });
                          //       await audioPlayer.seek(newPosition);
                          //       if (isPlaying) {
                          //         await audioPlayer.resume();
                          //       }
                          //     }
                          //   },
                          //   playSelectedTrack: playSelectedTrack,
                          // ),
                        );
                      }
                    }),
              ),
            ),
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff80221e),
        selectedFontSize: 20,
        elevation: 0.0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: selectedItem,
        selectedIconTheme: const IconThemeData(
          color: Color(0xff80221e),
        ),
        backgroundColor: const Color(0x00ffffff),
        items: _bottomNavigationBarItems,
        onTap: (index) {
          setState(() {
            selectedItem = index;
          });
        },
      ),
    );
  }
}

final _bottomNavigationBarItems = <BottomNavigationBarItem>[
  const BottomNavigationBarItem(
    backgroundColor: Color(0x00ffffff),
    activeIcon: Icon(
      Icons.home,
      color: Color(0xff80221e),
    ),
    icon: Icon(
      Icons.home_outlined,
      color: Colors.black,
    ),
    label: "Home",
  ),
  const BottomNavigationBarItem(
    backgroundColor: Color(0x00ffffff),
    icon: Icon(Icons.grid_view_outlined, color: Colors.black),
    activeIcon: Icon(
      Icons.grid_view_rounded,
      color: Color(0xff80221e),
    ),
    label: "Library",
  ),
  const BottomNavigationBarItem(
    backgroundColor: Color(0x00ffffff),
    icon: Icon(Icons.search_outlined, color: Colors.black),
    activeIcon: Icon(
      Icons.search,
      color: Color(0xff80221e),
    ),
    label: "Search",
  ),
  const BottomNavigationBarItem(
    backgroundColor: Color(0x00ffffff),
    icon: Icon(Icons.account_circle_outlined, color: Colors.black),
    activeIcon: Icon(
      Icons.account_circle,
      color: Color(0xff80221e),
    ),
    label: "Account",
  ),
];
