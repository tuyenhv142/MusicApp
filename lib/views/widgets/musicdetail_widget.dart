import 'package:flutter/material.dart';
import '../../models/track_model.dart';



class MusicDetailWidget extends StatelessWidget {
  final Track track;
  final bool isPlaying;
  final int currentIndex;
  final List<Track> playlist;
  final Function() onPlayPause;
  final Function() onStop;
  final Function() onNext;
  final Function() onPrevious;
  final Duration currentPosition;
  final Duration totalDuration;
  final Function(double) onSeek;
  final void Function(Track track) playSelectedTrack;
  final Function() addPlaylist;
  final bool isFavorite;
  final Function(bool) onFavoriteChanged;

  const MusicDetailWidget({
    super.key,
    required this.track,
    required this.isPlaying,
    required this.currentIndex,
    required this.playlist,
    required this.onPlayPause,
    required this.onStop,
    required this.onNext,
    required this.onPrevious,
    required this.currentPosition,
    required this.totalDuration,
    required this.onSeek,
    required this.playSelectedTrack,
    required this.addPlaylist,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: const [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 30,
                    icon: Icon(Icons.keyboard_arrow_down_sharp),
                    onPressed: null,
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      track.image,
                      height: MediaQuery.of(context).size.height / 2.75,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    track.title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.singerId,
                    style: TextStyle(fontSize: 20),
                  ),
                  Slider(
                    value: currentPosition.inSeconds.toDouble().clamp(
                          0.0,
                          totalDuration.inSeconds.toDouble(),
                        ),
                    min: 0,
                    activeColor: Colors.black,
                    max: totalDuration.inSeconds.toDouble(),
                    onChanged: (value) => onSeek(value),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatTime(currentPosition)),
                        Text(formatTime(totalDuration - currentPosition)),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: onPrevious,
                        icon: Icon(Icons.skip_previous),
                        iconSize: 36,
                      ),
                      CircleAvatar(
                        radius: 35,
                        child: IconButton(
                          onPressed: onPlayPause,
                          icon:
                              Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                          iconSize: 40,
                        ),
                      ),
                      IconButton(
                        onPressed: onNext,
                        icon: Icon(Icons.skip_next),
                        iconSize: 36,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return ListView.builder(
                                itemCount: playlist.length,
                                itemBuilder: (context, index) {
                                  final track = playlist[index];
                                  return ListTile(
                                    leading: Text(
                                      '${index + 1}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    title: Text(track.title),
                                    subtitle: Text(track.singerId),
                                    onTap: () {
                                      playSelectedTrack(track);
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.playlist_play),
                        iconSize: 36,
                      ),
                      IconButton(
                        onPressed: addPlaylist,
                        icon: const Icon(Icons.add),
                        iconSize: 36,
                      ),
                      IconButton(
                        onPressed: () {
                          bool newFavoriteState = !isFavorite;
                          onFavoriteChanged(newFavoriteState);
                        },
                        icon: Icon(
                          Icons.favorite,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        iconSize: 36,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, twoDigitMinutes, twoDigitSeconds]
        .join(':');
  }
}
