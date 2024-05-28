import 'dart:math';


import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../../models/track_model.dart';
import '../../../view_models/track_provide.dart';
import '../../../view_models/user_provider.dart';




class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final trackProvider = Provider.of<TrackProvider>(context);

    String? userId = userProvider.getCurrentUser.idUser;
    List<String>? favoriteTrackIds =
        userId != null ? userProvider.getFavoriteTrackIds(userId) : [];

    debugPrint('Favorite Track IDs: $favoriteTrackIds');

    TextEditingController playlistNameController = TextEditingController();

    void showCreatePlaylistDialog(BuildContext context) {
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
                      decoration: const InputDecoration(
                        hintText: 'Enter playlist name',
                      ),
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
    Future<void> handlePopupMenuSelection(int value, trackId) async {
      switch (value) {
        case 1:
          bool isFavorite = userProvider.isFavoriteTrack(trackId);
          if (isFavorite) {
            userProvider.removeFavoriteTrackId(trackId);
          } else {
            userProvider.addFavoriteTrackId(trackId);
          }
          break;
        case 2:
          final userProvider =
          Provider.of<UserProvider>(context, listen: false);
          List<Map<String, dynamic>> playlists = await userProvider
              .getPlaylistDataList(userProvider.currentUser.idUser);

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Add to Playlist'),
                content: SizedBox(
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
                                String? playlistId =
                                await userProvider.getPlaylistIdAtIndex(
                                    userProvider.currentUser.idUser, index);
                                userProvider.addToPlaylist(
                                    playlistId!, trackId);
                                Fluttertoast.showToast(
                                  msg: 'Song added to playlist successfully!',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                );
                                Navigator.pop(context);
                              },
                            );
                          },
                        )
                      else
                        const Text('No playlists available'),
                      ElevatedButton(
                        onPressed: () {
                          showCreatePlaylistDialog(context);
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
          break;
        default:
          break;
      }
    }
    return Scaffold(
      appBar: AppBar(
          // title: Text('Favorite Songs'),
          ),
      body: FutureBuilder<List<Track>>(
        future: trackProvider.getTracksByIdList(favoriteTrackIds!),
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
          List<Track> favoriteTracks = snapshot.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Favorite Songs",
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
                      Text('${favoriteTracks.length} Songs - Saved to library',
                          style: Theme.of(context).textTheme.bodyLarge!),
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
                          final random = Random();
                          final userProvider =
                              Provider.of<UserProvider>(context, listen: false);
                          final int index =
                              random.nextInt(favoriteTracks.length);
                          final Track randomTrack = favoriteTracks[index];
                          userProvider.setCurrentTrackId(randomTrack.id ?? "");
                          userProvider.notifyTrackListChanged(favoriteTracks);
                        },
                        child: Container(
                          width: 140,
                          height: 40,
                          decoration: BoxDecoration(
                              // color: Color(0xB7DEDFF6),
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(100)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Shuffle",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.shuffle,
                                color: Colors.white,
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
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: favoriteTracks.length,
                  itemBuilder: (context, index) {
                    final Track track = favoriteTracks[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(track.image),
                      ),
                      title: Text(track.title),
                      subtitle: Text(track.singerId),
                      trailing: SizedBox(
                        width: 25,
                        height: 25,
                        child: PopupMenuButton<int>(
                          color: Colors.grey,
                          offset: const Offset(-10, 15),
                          elevation: 1,
                          onSelected: (value) {
                            handlePopupMenuSelection(value, track.id);
                          },
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Colors.black,
                          ),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context) {
                            bool isFavorite = userProvider.isFavoriteTrack(track.id);
                            return [
                              PopupMenuItem(
                                value: 1,
                                height: 30,
                                child: Text(
                                  isFavorite
                                      ? "Remove from Favorites"
                                      : "Add to Favorite",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 2,
                                height: 30,
                                child: Text(
                                  "Add to Playlist",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ];
                          },
                        ),
                      ),
                      onTap: () {
                        final userProvider =
                            Provider.of<UserProvider>(context, listen: false);
                        final trackId = track.id ?? "";
                        userProvider.setCurrentTrackId(trackId);
                        userProvider.notifyTrackListChanged(favoriteTracks);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 60,
              )
            ],
          );
        },
      ),
    );
  }
}
