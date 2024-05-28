import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../../models/track_model.dart';
import '../../../view_models/playList_provider.dart';
import '../../../view_models/track_provide.dart';
import '../../../view_models/user_provider.dart';


class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

PlayListProvider playListProvider = PlayListProvider();

class _PlaylistPageState extends State<PlaylistPage> {
  // bool _isLoaded = false;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await playListProvider.getCurrentPlaylist();
    // setState(() {
    //   _isLoaded = true;
    // });
  }

  void _showModalBottomSheet(BuildContext context) {
    final playListProvider =
        Provider.of<PlayListProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final playlist = playListProvider.getCurrentPlaylist();
    bool isFavorite = userProvider.isFavoritePlaylist(playlist?.id);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black.withOpacity(0.4),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        playlist!.img,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.name,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          playlist.dateEnter,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            // ListTile(
            //   leading: const Icon(Icons.play_circle_outline),
            //   title: const Text('Play'),
            //   onTap: () {
            //     final Track randomTrack = tracks[0];
            //     userProvider.setCurrentTrackId(
            //         randomTrack.id ?? "");
            //     userProvider
            //         .notifyTrackListChanged(tracks);
            //     Navigator.pop(context);
            //   },
            // ),
            ListTile(
              leading: !isFavorite
                  ? const Icon(Icons.favorite_outline)
                  : const Icon(Icons.delete_outline),
              title: !isFavorite
                  ? const Text('Add to library')
                  : const Text('Delete to library'),
              onTap: () {
                if (!isFavorite) {
                  userProvider.addFavoritePlaylistId(playlist.id);
                  Fluttertoast.showToast(
                    msg: 'Add to Library successfully!',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  );
                } else {
                  userProvider.removeFavoritePlaylistId(playlist.id);
                  Fluttertoast.showToast(
                    msg: 'Delete to Library successfully!',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  );
                }

                Navigator.pop(context);
              },
            ),
            const SizedBox(
              height: 50,
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    playListProvider = Provider.of<PlayListProvider>(context);
    final trackProvider = Provider.of<TrackProvider>(context);

    final playlist = playListProvider.getCurrentPlaylist();
    List<String>? trackListId = playlist?.tracks;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              _showModalBottomSheet(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Track>>(
        future: trackProvider.getTracksByIdList(trackListId!),
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Stack(
          //     children: [
          //       Positioned.fill(
          //         child: Center(
          //           child: LoadingAnimationWidget.beat(
          //             color: Colors.black,
          //             size: 50,
          //           ),
          //         ),
          //       ),
          //     ],
          //   );
          // }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }
          List<Track> tracks = snapshot.data ?? [];

          return Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.network(
                            playlist!.img,
                            width: MediaQuery.of(context).size.height * 0.25,
                            height: MediaQuery.of(context).size.height * 0.25,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              playlist.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${tracks.length} Songs',
                              style: Theme.of(context).textTheme.bodyLarge!,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: () {
                                final userProvider = Provider.of<UserProvider>(
                                    context,
                                    listen: false);
                                final Track randomTrack = tracks[0];
                                userProvider
                                    .setCurrentTrackId(randomTrack.id ?? "");
                                userProvider.notifyTrackListChanged(tracks);
                              },
                              child: Container(
                                width: 140,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Play All",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                final random = Random();
                                final userProvider = Provider.of<UserProvider>(
                                    context,
                                    listen: false);
                                final int index = random.nextInt(tracks.length);
                                final Track randomTrack = tracks[index];
                                userProvider
                                    .setCurrentTrackId(randomTrack.id ?? "");
                                userProvider.notifyTrackListChanged(tracks);
                              },
                              child: Container(
                                width: 140,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xB7DEDFF6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Shuffle",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Icon(
                                      Icons.shuffle,
                                      color: Colors.black,
                                      size: 15,
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          playlist.content,
                          maxLines: 1,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tracks.length,
                      itemBuilder: (context, index) {
                        final track = tracks[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              track.image,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            track.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(track.singerId),
                          trailing: const Icon(Icons.play_circle),
                          onTap: () {
                            final userProvider = Provider.of<UserProvider>(
                                context,
                                listen: false);
                            final trackId = track.id ?? "";
                            userProvider.setCurrentTrackId(trackId);
                            userProvider.notifyTrackListChanged(tracks);
                          },
                        );
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
